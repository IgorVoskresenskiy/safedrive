#if defined SAFEDRIVE_DEFS_INC
    #endinput
#endif
#define SAFEDRIVE_DEFS_INC

#define TAG_CRASH               0x62
#define TAG_TOW                 0x63
#define TAG_OVERHEAT            0x64
#define TAG_OVERHEAT_REPEATED   0x65
#define TAG_BAT                 0x66
#define TAG_SCORE               0x67
#define TAG_ROAD                0x68
#define TAG_RESTART             0x69

#define KEY_PARAMS_1   1
#define KEY_PARAMS_2   2
#define KEY_PARAMS_3   3
#define KEY_OVERHEAT   5
#define KEY_BATTERY    6
#define KEY_SMSNUM     7

#define PARAM_A_CRASH          1
#define PARAM_T_CRASH_LOCKOUT  2
#define PARAM_A_MOTION         3
#define PARAM_T_PARKED_MIN     4
#define PARAM_A_ROAD_BUMP_THR  5
#define PARAM_A_ACC_HARD       6
#define PARAM_A_BRK_HARD       7
#define PARAM_A_TURN_HARD      8
#define PARAM_T_OVERHEAT_THR   9
#define PARAM_V_BAT_OK         10
#define PARAM_V_BAT_CRIT       11
#define PARAM_T_BAT_RESET_SEC  12
#define PARAM_COUNT            12

#define DEF_A_CRASH_MG          3000
#define DEF_T_CRASH_LOCKOUT     60
#define DEF_A_MOTION_MG         300
#define DEF_T_PARKED_MIN        30
#define DEF_A_ROAD_BUMP_THR_MG  300
#define DEF_A_ACC_HARD_MG       400
#define DEF_A_BRK_HARD_MG       400
#define DEF_A_TURN_HARD_MG      400
#define DEF_T_OVERHEAT_THR_C    105
#define DEF_V_BAT_OK_MV         12400
#define DEF_V_BAT_CRIT_MV       11800
#define DEF_T_BAT_RESET_SEC     600

#define HC_V_TOW_MIN        5
#define HC_T_TOW_LOCKOUT    300
#define HC_V_BAT_LOW_MV     12000
#define HC_V_ENGINE_ON_MV   13000

#define MG_TO_RAW(%1)  (((%1) * 8192) / 1000)
#define RAW_TO_MG(%1)  (((%1) * 1000) / 8192)

#define GRAVITY_RAW    8192

#define CMD_NONE          0
#define CMD_RESET_OVERH   1

#define MAIN_LOOP_MS              50
#define BASELINE_INIT_SAMPLES     20
#define ROAD_SAMPLE_CAP           20000

#define SMS_NUM_MAX_LEN   15
#define SMS_BUF_SIZE      128
