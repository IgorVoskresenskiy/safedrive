new gCrashLastUtc = 0

crashDetect(ax, ay, az, nowUtc)
{
    new lockout = GetVar(gT_CrashLockout)
    if (gCrashLastUtc != 0 && nowUtc - gCrashLastUtc < lockout)
        return

    new ax2 = ax / 2
    new ay2 = ay / 2
    new az2 = az / 2
    new sumSq = ax2 * ax2 + ay2 * ay2 + az2 * az2

    new thr = GetVar(gA_Crash) / 2
    new thrSq = thr * thr

    if (sumSq <= thrSq)
        return

    gCrashLastUtc = nowUtc
    TagWriteValue(TAG_CRASH, 1)
    SavePoint()
    Diagnostics("SD: CRASH! a2=%d thr2=%d", sumSq, thrSq)

    sendAlertSms("CRASH", calcMagGx10(sumSq))
}
