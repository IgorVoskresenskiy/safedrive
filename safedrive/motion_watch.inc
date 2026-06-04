new gParkedStartUtc = 0
new gWasParked = 0
new gPrevEngineOnAtMotion = 0
new gTowLastUtc = 0

motionWatch(ax, ay, az, gpsSpeed, powerMv, nowUtc)
{
    new engineOn = (powerMv >= HC_V_ENGINE_ON_MV) ? 1 : 0

    if (engineOn && !gPrevEngineOnAtMotion) {
        gWasParked = 0
        gParkedStartUtc = 0
    }
    gPrevEngineOnAtMotion = engineOn

    if (!engineOn && gpsSpeed == 0) {
        if (gParkedStartUtc == 0)
            gParkedStartUtc = nowUtc
        if (!gWasParked && nowUtc - gParkedStartUtc >= GetVar(gT_ParkedMin)) {
            gWasParked = 1
            Diagnostics("SD: parked")
        }
    }

    if (!gWasParked)
        return

    if (gTowLastUtc != 0 && nowUtc - gTowLastUtc < HC_T_TOW_LOCKOUT)
        return

    new ax2 = ax / 2
    new ay2 = ay / 2
    new az2 = (az - GRAVITY_RAW) / 2
    new sumSq = ax2 * ax2 + ay2 * ay2 + az2 * az2

    new mot = GetVar(gA_Motion) / 2
    if (sumSq > mot * mot) {
        motionTrigger(nowUtc, 1, sumSq)
        return
    }

    if (!engineOn && gpsSpeed > HC_V_TOW_MIN) {
        motionTrigger(nowUtc, 2, sumSq)
        return
    }
}

motionTrigger(nowUtc, reason, sumSqHalved)
{
    gTowLastUtc = nowUtc
    TagWriteValue(TAG_TOW, 1)
    SavePoint()
    Diagnostics("SD: TOW! reason=%d", reason)
    sendAlertSms("TOW", calcMagGx10(sumSqHalved))
}
