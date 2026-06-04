#include <string>
#include "safedrive_defs.inc"
#include "alert_sms.inc"
#include "crash_detector.inc"
#include "motion_watch.inc"
#include "road_quality.inc"
#include "driving_score.inc"
#include "thermal_watch.inc"
#include "battery_watch.inc"

main()
{
    Diagnostics("SD: init")

    loadParams()
    restoreState()

    TagWriteValue(TAG_RESTART, 1)
    SavePoint()

    while (true) {
        new nowUtc = GetVar(UNIX_TIME)

        new ax = 0, ay = 0, az = 0
        if (GetVar(gSimAccelEnabled)) {
            ax = GetVar(gSimAx)
            ay = GetVar(gSimAy)
            az = GetVar(gSimAz)
        } else {
            ax = GetVar(ACC_X)
            ay = GetVar(ACC_Y)
            az = GetVar(ACC_Z)
        }

        new powerMv = GetVar(POWER)
        new simPower = GetVar(gSimPowerMv)
        if (simPower >= 0)
            powerMv = simPower

        new coolant = GetVar(ENGINE_COOLANT_TEMPERATURE)
        new simCool = GetVar(gSimCoolant)
        if (simCool != 32767)
            coolant = simCool

        new gpsSpeed = GetVar(SPEED)

        crashDetect(ax, ay, az, nowUtc)
        motionWatch(ax, ay, az, gpsSpeed, powerMv, nowUtc)
        roadAccumulate(az)
        scoringTick(ax, ay)
        thermalWatch(coolant, nowUtc)
        batteryWatch(powerMv, nowUtc)

        processPendingCmd()

        Delay(MAIN_LOOP_MS)
    }
}

processPendingCmd()
{
    new cmd = GetVar(gCmdAction)
    if (cmd == CMD_NONE)
        return
    SetVar(gCmdAction, CMD_NONE)

    if (cmd == CMD_RESET_OVERH)
        thermalResetCounters()
}

loadParams()
{
    new buf[4]
    new needRewrite

    needRewrite = 0
    if (ROMRead(KEY_PARAMS_1, buf, 16) <= 0)
        needRewrite = 1
    else if (buf[2] > 1000 || buf[3] > 200)
        needRewrite = 1
    if (needRewrite) {
        buf[0] = DEF_A_CRASH_MG
        buf[1] = DEF_T_CRASH_LOCKOUT
        buf[2] = DEF_A_MOTION_MG
        buf[3] = DEF_T_PARKED_MIN
        ROMWrite(KEY_PARAMS_1, buf, 16)
    }
    SetVar(gA_Crash, MG_TO_RAW(buf[0]))
    SetVar(gT_CrashLockout, buf[1])
    SetVar(gA_Motion, MG_TO_RAW(buf[2]))
    SetVar(gT_ParkedMin, buf[3])

    needRewrite = 0
    if (ROMRead(KEY_PARAMS_2, buf, 16) <= 0)
        needRewrite = 1
    else if (buf[0] < 50 || buf[0] > 2000)
        needRewrite = 1
    if (needRewrite) {
        buf[0] = DEF_A_ROAD_BUMP_THR_MG
        buf[1] = DEF_A_ACC_HARD_MG
        buf[2] = DEF_A_BRK_HARD_MG
        buf[3] = DEF_A_TURN_HARD_MG
        ROMWrite(KEY_PARAMS_2, buf, 16)
    }
    SetVar(gA_RoadBumpThr, MG_TO_RAW(buf[0]))
    SetVar(gA_AccHard, MG_TO_RAW(buf[1]))
    SetVar(gA_BrkHard, MG_TO_RAW(buf[2]))
    SetVar(gA_TurnHard, MG_TO_RAW(buf[3]))

    needRewrite = 0
    if (ROMRead(KEY_PARAMS_3, buf, 16) <= 0)
        needRewrite = 1
    else if (buf[0] < 50 || buf[0] > 200)
        needRewrite = 1
    if (needRewrite) {
        buf[0] = DEF_T_OVERHEAT_THR_C
        buf[1] = DEF_V_BAT_OK_MV
        buf[2] = DEF_V_BAT_CRIT_MV
        buf[3] = DEF_T_BAT_RESET_SEC
        ROMWrite(KEY_PARAMS_3, buf, 16)
    }
    SetVar(gT_OverheatThr, buf[0])
    SetVar(gV_BatOk, buf[1])
    SetVar(gV_BatCrit, buf[2])
    SetVar(gT_BatResetSec, buf[3])

    Diagnostics("SD: params loaded")
}

restoreState()
{
    new buf[4]

    if (ROMRead(KEY_OVERHEAT, buf, 16) > 0) {
        SetVar(gOverheatCount, buf[0])
        SetVar(gOverheatTotalSec, buf[1])
    }

    if (ROMRead(KEY_BATTERY, buf, 16) > 0) {
        SetVar(gBatColdStartMv, buf[0])
    }
}
