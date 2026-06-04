#include <string>
#include "safedrive_defs.inc"

new gCmdText{128}
new gAnswer{128}
new gCmdName{16}
new gTmp{32}

main()
{
    GetStringVar(COMMAND_TEXT, gCmdText, 128)
    extractCmdName(gCmdText, gCmdName, 16)

    new connId = GetVar(CONNECTION_ID)
    new cmdNum = GetVar(COMMAND_NUMBER)

    if (strcmp(gCmdName, "STARTROADQ") == 0)
        handleStartRoadQ(connId, cmdNum)
    else if (strcmp(gCmdName, "STOPROADQ") == 0)
        handleStopRoadQ(connId, cmdNum)
    else if (strcmp(gCmdName, "STARTSCORING") == 0)
        handleStartScoring(connId, cmdNum)
    else if (strcmp(gCmdName, "STOPSCORING") == 0)
        handleStopScoring(connId, cmdNum)
    else if (strcmp(gCmdName, "GETSCORE") == 0)
        handleGetScore(connId, cmdNum)
    else if (strcmp(gCmdName, "GETOVERHEAT") == 0)
        handleGetOverheat(connId, cmdNum)
    else if (strcmp(gCmdName, "RESETOVERHEAT") == 0)
        handleResetOverheat(connId, cmdNum)
    else if (strcmp(gCmdName, "GETBATSTAT") == 0)
        handleGetBatStat(connId, cmdNum)
    else if (strcmp(gCmdName, "SETSDPARAM") == 0)
        handleSetParam(connId, cmdNum)
    else if (strcmp(gCmdName, "GETSDPARAM") == 0)
        handleGetParam(connId, cmdNum)
    else if (strcmp(gCmdName, "SETSMSNUM") == 0)
        handleSetSmsNum(connId, cmdNum)
    else if (strcmp(gCmdName, "GETSMSNUM") == 0)
        handleGetSmsNum(connId, cmdNum)
    else if (strcmp(gCmdName, "SIMACCEL") == 0)
        handleSimAccel(connId, cmdNum)
    else if (strcmp(gCmdName, "SIMENV") == 0)
        handleSimEnv(connId, cmdNum)
    else if (strcmp(gCmdName, "SIMOFF") == 0)
        handleSimOff(connId, cmdNum)
}

handleStartRoadQ(connId, cmdNum)
{
    if (GetVar(gRoadActive)) {
        reply(connId, cmdNum, "ERR: road active")
        return
    }
    SetVar(gRoadSumAbsZ, 0)
    SetVar(gRoadSampleCount, 0)
    SetVar(gRoadPeakCount, 0)
    SetVar(gRoadActive, 1)
    reply(connId, cmdNum, "OK: roadq start")
}

handleStopRoadQ(connId, cmdNum)
{
    if (!GetVar(gRoadActive)) {
        reply(connId, cmdNum, "ERR: not active")
        return
    }
    SetVar(gRoadActive, 0)

    new cnt = GetVar(gRoadSampleCount)
    if (cnt < 10) {
        reply(connId, cmdNum, "ERR: too few samples")
        return
    }

    new madRaw = GetVar(gRoadSumAbsZ) / cnt
    new madMg = RAW_TO_MG(madRaw)
    new peaks = GetVar(gRoadPeakCount)
    new peaksPer1000 = peaks * 1000 / cnt

    new score = 5
    if (madMg >= 50 || peaksPer1000 >= 5) score = 4
    if (madMg >= 100 || peaksPer1000 >= 20) score = 3
    if (madMg >= 200 || peaksPer1000 >= 50) score = 2
    if (madMg >= 400 || peaksPer1000 >= 100) score = 1

    TagWriteValue(TAG_ROAD, score)
    SavePoint()

    strpack(gAnswer, "ROAD=")
    appendInt(score)
    appendStr(" mad=")
    appendInt(madMg)
    appendStr("mg peaks=")
    appendInt(peaks)
    sendBuf(connId, cmdNum)
}

handleStartScoring(connId, cmdNum)
{
    if (GetVar(gScoringActive)) {
        reply(connId, cmdNum, "ERR: scoring active")
        return
    }
    SetVar(gScoringEpisodes, 0)
    SetVar(gScoringMs, 0)
    SetVar(gScoringActive, 1)
    reply(connId, cmdNum, "OK: scoring start")
}

handleStopScoring(connId, cmdNum)
{
    if (!GetVar(gScoringActive)) {
        reply(connId, cmdNum, "ERR: not active")
        return
    }
    SetVar(gScoringActive, 0)
    new score = calcDrivingScore()
    TagWriteValue(TAG_SCORE, score)
    SavePoint()
    replyScore(connId, cmdNum, "SCORE=", score)
}

handleGetScore(connId, cmdNum)
{
    if (!GetVar(gScoringActive)) {
        reply(connId, cmdNum, "ERR: not active")
        return
    }
    new score = calcDrivingScore()
    replyScore(connId, cmdNum, "SCORE=", score)
}

calcDrivingScore()
{
    new episodes = GetVar(gScoringEpisodes)
    new ms = GetVar(gScoringMs)
    new penalty = episodes * 10 + ms / 1000

    new score = 5
    if (penalty >= 20) score = 4
    if (penalty >= 60) score = 3
    if (penalty >= 150) score = 2
    if (penalty >= 300) score = 1
    return score
}

replyScore(connId, cmdNum, const prefix[], score)
{
    strpack(gAnswer, prefix)
    appendInt(score)
    appendStr(" ep=")
    appendInt(GetVar(gScoringEpisodes))
    appendStr(" ms=")
    appendInt(GetVar(gScoringMs))
    sendBuf(connId, cmdNum)
}

handleGetOverheat(connId, cmdNum)
{
    strpack(gAnswer, "OVERH cnt=")
    appendInt(GetVar(gOverheatCount))
    appendStr(" sec=")
    appendInt(GetVar(gOverheatTotalSec))
    sendBuf(connId, cmdNum)
}

handleResetOverheat(connId, cmdNum)
{
    SetVar(gCmdAction, CMD_RESET_OVERH)
    reply(connId, cmdNum, "OK: overheat reset")
}

handleGetBatStat(connId, cmdNum)
{
    new mv = GetVar(gBatColdStartMv)
    if (mv <= 0) {
        reply(connId, cmdNum, "BAT no data")
        return
    }
    new code = 0
    if (mv >= GetVar(gV_BatOk))         code = 0
    else if (mv >= HC_V_BAT_LOW_MV)     code = 1
    else if (mv >= GetVar(gV_BatCrit))  code = 2
    else                                code = 3

    strpack(gAnswer, "BAT mv=")
    appendInt(mv)
    appendStr(" code=")
    appendInt(code)
    sendBuf(connId, cmdNum)
}

handleSetParam(connId, cmdNum)
{
    new argPos = findArgPos(gCmdText)
    if (argPos < 0) {
        reply(connId, cmdNum, "ERR: need x,y")
        return
    }

    new vals[2]
    new count = parseCSV(gCmdText, argPos, vals, 2)
    if (count != 2) {
        reply(connId, cmdNum, "ERR: need x,y")
        return
    }

    new idx = vals[0]
    new val = vals[1]
    if (idx < 1 || idx > PARAM_COUNT) {
        reply(connId, cmdNum, "ERR: x=1..12")
        return
    }

    setParamValue(idx, val)
    saveParamToRom(idx)

    strpack(gAnswer, "OK: P")
    appendInt(idx)
    appendStr("=")
    appendInt(val)
    sendBuf(connId, cmdNum)
}

handleGetParam(connId, cmdNum)
{
    new argPos = findArgPos(gCmdText)
    new idx = 0
    if (argPos >= 0) {
        new vals[1]
        new c = parseCSV(gCmdText, argPos, vals, 1)
        if (c > 0) idx = vals[0]
    }
    if (idx < 0 || idx > PARAM_COUNT) {
        reply(connId, cmdNum, "ERR: x=0..12")
        return
    }

    if (idx == 0) {
        strpack(gAnswer, "P:")
        new i
        for (i = 1; i <= PARAM_COUNT; i++) {
            if (i > 1) appendStr(",")
            appendInt(getParamValue(i))
        }
    } else {
        strpack(gAnswer, "P")
        appendInt(idx)
        appendStr("=")
        appendInt(getParamValue(idx))
    }
    sendBuf(connId, cmdNum)
}

getParamValue(idx)
{
    if (idx == PARAM_A_CRASH)          return RAW_TO_MG(GetVar(gA_Crash))
    if (idx == PARAM_T_CRASH_LOCKOUT)  return GetVar(gT_CrashLockout)
    if (idx == PARAM_A_MOTION)         return RAW_TO_MG(GetVar(gA_Motion))
    if (idx == PARAM_T_PARKED_MIN)     return GetVar(gT_ParkedMin)
    if (idx == PARAM_A_ROAD_BUMP_THR)  return RAW_TO_MG(GetVar(gA_RoadBumpThr))
    if (idx == PARAM_A_ACC_HARD)       return RAW_TO_MG(GetVar(gA_AccHard))
    if (idx == PARAM_A_BRK_HARD)       return RAW_TO_MG(GetVar(gA_BrkHard))
    if (idx == PARAM_A_TURN_HARD)      return RAW_TO_MG(GetVar(gA_TurnHard))
    if (idx == PARAM_T_OVERHEAT_THR)   return GetVar(gT_OverheatThr)
    if (idx == PARAM_V_BAT_OK)         return GetVar(gV_BatOk)
    if (idx == PARAM_V_BAT_CRIT)       return GetVar(gV_BatCrit)
    if (idx == PARAM_T_BAT_RESET_SEC)  return GetVar(gT_BatResetSec)
    return 0
}

setParamValue(idx, val)
{
    if (idx == PARAM_A_CRASH)               SetVar(gA_Crash, MG_TO_RAW(val))
    else if (idx == PARAM_T_CRASH_LOCKOUT)  SetVar(gT_CrashLockout, val)
    else if (idx == PARAM_A_MOTION)         SetVar(gA_Motion, MG_TO_RAW(val))
    else if (idx == PARAM_T_PARKED_MIN)     SetVar(gT_ParkedMin, val)
    else if (idx == PARAM_A_ROAD_BUMP_THR)  SetVar(gA_RoadBumpThr, MG_TO_RAW(val))
    else if (idx == PARAM_A_ACC_HARD)       SetVar(gA_AccHard, MG_TO_RAW(val))
    else if (idx == PARAM_A_BRK_HARD)       SetVar(gA_BrkHard, MG_TO_RAW(val))
    else if (idx == PARAM_A_TURN_HARD)      SetVar(gA_TurnHard, MG_TO_RAW(val))
    else if (idx == PARAM_T_OVERHEAT_THR)   SetVar(gT_OverheatThr, val)
    else if (idx == PARAM_V_BAT_OK)         SetVar(gV_BatOk, val)
    else if (idx == PARAM_V_BAT_CRIT)       SetVar(gV_BatCrit, val)
    else if (idx == PARAM_T_BAT_RESET_SEC)  SetVar(gT_BatResetSec, val)
}

saveParamToRom(idx)
{
    new buf[4]
    if (idx >= 1 && idx <= 4) {
        buf[0] = getParamValue(PARAM_A_CRASH)
        buf[1] = getParamValue(PARAM_T_CRASH_LOCKOUT)
        buf[2] = getParamValue(PARAM_A_MOTION)
        buf[3] = getParamValue(PARAM_T_PARKED_MIN)
        ROMWrite(KEY_PARAMS_1, buf, 16)
    } else if (idx >= 5 && idx <= 8) {
        buf[0] = getParamValue(PARAM_A_ROAD_BUMP_THR)
        buf[1] = getParamValue(PARAM_A_ACC_HARD)
        buf[2] = getParamValue(PARAM_A_BRK_HARD)
        buf[3] = getParamValue(PARAM_A_TURN_HARD)
        ROMWrite(KEY_PARAMS_2, buf, 16)
    } else if (idx >= 9 && idx <= 12) {
        buf[0] = getParamValue(PARAM_T_OVERHEAT_THR)
        buf[1] = getParamValue(PARAM_V_BAT_OK)
        buf[2] = getParamValue(PARAM_V_BAT_CRIT)
        buf[3] = getParamValue(PARAM_T_BAT_RESET_SEC)
        ROMWrite(KEY_PARAMS_3, buf, 16)
    }
}

handleSetSmsNum(connId, cmdNum)
{
    new argPos = findArgPos(gCmdText)
    if (argPos < 0) {
        reply(connId, cmdNum, "ERR: need number")
        return
    }

    new phoneBuf{16}
    new i = 0
    while (gCmdText{argPos} != 0 && gCmdText{argPos} != ' ' && i < SMS_NUM_MAX_LEN) {
        phoneBuf{i} = gCmdText{argPos}
        i++
        argPos++
    }
    phoneBuf{i} = 0

    if (i == 0) {
        reply(connId, cmdNum, "ERR: empty number")
        return
    }

    ROMWrite(KEY_SMSNUM, phoneBuf, 16)

    strpack(gAnswer, "OK: SMS=")
    strcat(gAnswer, phoneBuf, 128)
    sendBuf(connId, cmdNum)
}

handleGetSmsNum(connId, cmdNum)
{
    new phoneBuf{16}
    new size = ROMRead(KEY_SMSNUM, phoneBuf, 16)
    if (size <= 0 || phoneBuf{0} == 0) {
        reply(connId, cmdNum, "SMS not set")
        return
    }
    strpack(gAnswer, "SMS=")
    strcat(gAnswer, phoneBuf, 128)
    sendBuf(connId, cmdNum)
}

handleSimAccel(connId, cmdNum)
{
    new argPos = findArgPos(gCmdText)
    if (argPos < 0) {
        reply(connId, cmdNum, "ERR: need ax,ay,az")
        return
    }
    new vals[3]
    new c = parseCSV(gCmdText, argPos, vals, 3)
    if (c != 3) {
        reply(connId, cmdNum, "ERR: need ax,ay,az")
        return
    }
    SetVar(gSimAx, vals[0])
    SetVar(gSimAy, vals[1])
    SetVar(gSimAz, vals[2])
    SetVar(gSimAccelEnabled, 1)
    reply(connId, cmdNum, "OK: sim accel")
}

handleSimEnv(connId, cmdNum)
{
    new argPos = findArgPos(gCmdText)
    if (argPos < 0) {
        reply(connId, cmdNum, "ERR: need power_mv,coolant_c")
        return
    }
    new vals[2]
    new c = parseCSV(gCmdText, argPos, vals, 2)
    if (c != 2) {
        reply(connId, cmdNum, "ERR: need power_mv,coolant_c")
        return
    }
    if (vals[0] < 0) vals[0] = 0
    SetVar(gSimCoolant, vals[1])
    SetVar(gSimPowerMv, vals[0])
    reply(connId, cmdNum, "OK: sim env")
}

handleSimOff(connId, cmdNum)
{
    SetVar(gSimAccelEnabled, 0)
    SetVar(gSimPowerMv, -1)
    SetVar(gSimCoolant, 32767)
    reply(connId, cmdNum, "OK: sim off")
}

appendStr(const s[])
{
    strpack(gTmp, s)
    strcat(gAnswer, gTmp, 128)
}

appendInt(value)
{
    valstr(gTmp, value)
    strcat(gAnswer, gTmp, 128)
}

extractCmdName(const text{}, dest{}, maxLen)
{
    new i = 0
    while (text{i} != 0 && text{i} != ' ' && i < maxLen - 1) {
        dest{i} = text{i}
        i++
    }
    dest{i} = 0
}

findArgPos(const text{})
{
    new i = 0
    while (text{i} != 0 && text{i} != ' ')
        i++
    while (text{i} == ' ')
        i++
    if (text{i} == 0)
        return -1
    return i
}

parseCSV(const text{}, startPos, values[], maxCount)
{
    new pos = startPos
    new count = 0
    while (count < maxCount && text{pos} != 0) {
        new val = 0
        new neg = 0
        new hasDigit = 0
        while (text{pos} == ' ') pos++
        if (text{pos} == '-') {
            neg = 1
            pos++
        }
        while (text{pos} >= '0' && text{pos} <= '9') {
            val = val * 10 + (text{pos} - '0')
            pos++
            hasDigit = 1
        }
        if (!hasDigit) break
        if (neg) val = -val
        values[count] = val
        count++
        if (text{pos} == ',') pos++
        else break
    }
    return count
}

reply(connId, cmdNum, const text[])
{
    strpack(gAnswer, text)
    new len = strlen(gAnswer)
    SendAnswer(connId, cmdNum, gAnswer, len, gAnswer, 0)
}

sendBuf(connId, cmdNum)
{
    new len = strlen(gAnswer)
    SendAnswer(connId, cmdNum, gAnswer, len, gAnswer, 0)
}
