program "safedrive"

import "safedrive_main.p" as safedrive_main
import "cmd_handler.p" as cmd_handler

int gA_Crash = 24576
int gT_CrashLockout = 60
int gA_Motion = 2457
int gT_ParkedMin = 30
int gA_RoadBumpThr = 2457
int gA_AccHard = 3276
int gA_BrkHard = 3276
int gA_TurnHard = 3276
int gT_OverheatThr = 105
int gV_BatOk = 12400
int gV_BatCrit = 11800
int gT_BatResetSec = 600

int gOverheatCount = 0
int gOverheatTotalSec = 0

int gBatColdStartMv = 0

int gRoadActive = 0
int gRoadSumAbsZ = 0
int gRoadSampleCount = 0
int gRoadPeakCount = 0

int gScoringActive = 0
int gScoringEpisodes = 0
int gScoringMs = 0

int gSimAccelEnabled = 0
int gSimAx = 0
int gSimAy = 0
int gSimAz = 0
int gSimPowerMv = -1
int gSimCoolant = 32767

int gCmdAction = 0

page "Main" {
    chain "SafeDriveMain" on device_start {
        delay(3s)
        script(safedrive_main)
    }
    chain "CmdHandler" on incoming_command {
        script(cmd_handler)
    }
}
