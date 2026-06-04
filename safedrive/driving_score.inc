new gAccActive = 0
new gBrkActive = 0
new gTurnActive = 0

scoringTick(ax, ay)
{
    if (!GetVar(gScoringActive))
        return

    new newEpisode = 0
    new anyActive = 0

    new accThr = GetVar(gA_AccHard)
    if (ay > accThr) {
        if (!gAccActive) {
            gAccActive = 1
            newEpisode = 1
        }
        anyActive = 1
    } else {
        gAccActive = 0
    }

    new brkThr = GetVar(gA_BrkHard)
    if (ay < -brkThr) {
        if (!gBrkActive) {
            gBrkActive = 1
            newEpisode = 1
        }
        anyActive = 1
    } else {
        gBrkActive = 0
    }

    new absAx = ax
    if (absAx < 0) absAx = -absAx
    new turnThr = GetVar(gA_TurnHard)
    if (absAx > turnThr) {
        if (!gTurnActive) {
            gTurnActive = 1
            newEpisode = 1
        }
        anyActive = 1
    } else {
        gTurnActive = 0
    }

    if (newEpisode) {
        new e = GetVar(gScoringEpisodes) + 1
        SetVar(gScoringEpisodes, e)
    }
    if (anyActive) {
        new ms = GetVar(gScoringMs) + MAIN_LOOP_MS
        SetVar(gScoringMs, ms)
    }
}
