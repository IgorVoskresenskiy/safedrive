new gRoadBaselineInited = 0
new gRoadBaselineSum = 0
new gRoadBaseline = 0

roadAccumulate(az)
{
    if (!GetVar(gRoadActive)) {
        gRoadBaselineInited = 0
        gRoadBaselineSum = 0
        return
    }

    if (!gRoadBaselineInited) {
        gRoadBaselineSum += az
        new cnt = GetVar(gRoadSampleCount) + 1
        SetVar(gRoadSampleCount, cnt)
        if (cnt >= BASELINE_INIT_SAMPLES) {
            gRoadBaseline = gRoadBaselineSum / BASELINE_INIT_SAMPLES
            gRoadBaselineInited = 1
            SetVar(gRoadSampleCount, 0)
        }
        return
    }

    gRoadBaseline = gRoadBaseline + (az - gRoadBaseline) / 256

    new delta = az - gRoadBaseline
    if (delta < 0) delta = -delta

    new sumAbs = GetVar(gRoadSumAbsZ)
    if (sumAbs < (cellmax - delta)) {
        sumAbs += delta
        SetVar(gRoadSumAbsZ, sumAbs)
    }

    new cnt = GetVar(gRoadSampleCount)
    if (cnt < ROAD_SAMPLE_CAP) {
        cnt++
        SetVar(gRoadSampleCount, cnt)
    }

    if (delta > GetVar(gA_RoadBumpThr)) {
        new peaks = GetVar(gRoadPeakCount)
        peaks++
        SetVar(gRoadPeakCount, peaks)
    }
}
