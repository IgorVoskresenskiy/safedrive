program "accel_dbg"

import "accel_dbg.p" as accel_dbg

page "Main" {
    chain "AccelDbg" on device_start {
        delay(2s)
        script(accel_dbg)
    }
}
