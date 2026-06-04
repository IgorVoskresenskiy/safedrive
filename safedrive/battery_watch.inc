new gEngineOffSinceUtc = 0
new gBatLastUpdateUtc = 0
new gPrevEngineOnAtBat = 0
new gBatRomSaveUtc = 0

batteryWatch(powerMv, nowUtc)
{
    new engineOn = (powerMv >= HC_V_ENGINE_ON_MV) ? 1 : 0

    if (!engineOn) {
        if (gEngineOffSinceUtc == 0)
            gEngineOffSinceUtc = nowUtc
    } else {
        gEngineOffSinceUtc = 0
    }

    new resetSec = GetVar(gT_BatResetSec)
    if (!engineOn && gEngineOffSinceUtc != 0 && nowUtc - gEngineOffSinceUtc >= resetSec) {
        if (gBatLastUpdateUtc == 0 || nowUtc - gBatLastUpdateUtc >= 60) {
            SetVar(gBatColdStartMv, powerMv)
            gBatLastUpdateUtc = nowUtc
            batterySaveRom(nowUtc)
        }
    }

    if (!gPrevEngineOnAtBat && engineOn && GetVar(gBatColdStartMv) > 0) {
        new mv = GetVar(gBatColdStartMv)
        new code = batteryClassify(mv)
        TagWriteValue(TAG_BAT, code)
        SavePoint()
        Diagnostics("SD: BAT start mv=%d code=%d", mv, code)
    }

    gPrevEngineOnAtBat = engineOn
}

batteryClassify(mv)
{
    if (mv >= GetVar(gV_BatOk))   return 0
    if (mv >= HC_V_BAT_LOW_MV)    return 1
    if (mv >= GetVar(gV_BatCrit)) return 2
    return 3
}

batterySaveRom(nowUtc)
{
    if (gBatRomSaveUtc != 0 && nowUtc - gBatRomSaveUtc < 60)
        return
    gBatRomSaveUtc = nowUtc

    new buf[4]
    buf[0] = GetVar(gBatColdStartMv)
    buf[1] = nowUtc
    buf[2] = 0
    buf[3] = 0
    ROMWrite(KEY_BATTERY, buf, 16)
}
