new gIsOverheatActive = 0
new gOverheatStartTime = 0
new gThermalLastSecUtc = 0

thermalWatch(coolantTemp, nowUtc)
{
    new threshold = GetVar(gT_OverheatThr)
    new isOver = (coolantTemp > threshold) ? 1 : 0

    if (isOver && !gIsOverheatActive) {
        new c = GetVar(gOverheatCount) + 1
        SetVar(gOverheatCount, c)
        gIsOverheatActive = 1
        gOverheatStartTime = nowUtc
        gThermalLastSecUtc = nowUtc
        TagWriteValue(TAG_OVERHEAT, 1)
        TagWriteValue(TAG_OVERHEAT_REPEATED, c)
        SavePoint()
        thermalSaveRom()
        Diagnostics("SD: overheat #%d t=%d", c, coolantTemp)
        return
    }

    if (isOver && gIsOverheatActive) {
        if (nowUtc != gThermalLastSecUtc) {
            new total = GetVar(gOverheatTotalSec) + (nowUtc - gThermalLastSecUtc)
            SetVar(gOverheatTotalSec, total)
            gThermalLastSecUtc = nowUtc
        }
        return
    }

    if (!isOver && gIsOverheatActive) {
        gIsOverheatActive = 0
        thermalSaveRom()
        Diagnostics("SD: overheat end")
    }

    gThermalLastSecUtc = nowUtc
}

thermalSaveRom()
{
    new buf[4]
    buf[0] = GetVar(gOverheatCount)
    buf[1] = GetVar(gOverheatTotalSec)
    buf[2] = 0
    buf[3] = 0
    ROMWrite(KEY_OVERHEAT, buf, 16)
}

thermalResetCounters()
{
    SetVar(gOverheatCount, 0)
    SetVar(gOverheatTotalSec, 0)
    gIsOverheatActive = 0
    gOverheatStartTime = 0
    thermalSaveRom()
}

thermalIsActive()
{
    return gIsOverheatActive
}
