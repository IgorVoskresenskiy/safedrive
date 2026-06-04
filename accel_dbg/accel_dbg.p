#include <string>

#define DBG_PERIOD_MS 500

main()
{
    Diagnostics("ACC_DBG: started")

    while (true) {
        new ax = GetVar(ACC_X)
        new ay = GetVar(ACC_Y)
        new az = GetVar(ACC_Z)

        new ax2 = ax / 2
        new ay2 = ay / 2
        new az2 = az / 2
        new magRaw = 2 * isqrt(ax2 * ax2 + ay2 * ay2 + az2 * az2)

        new ax_mg = (ax * 1000) / 8192
        new ay_mg = (ay * 1000) / 8192
        new az_mg = (az * 1000) / 8192
        new mag_mg = (magRaw * 1000) / 8192

        Diagnostics("ACC ax=%d ay=%d az=%d |a|=%d mg", ax_mg, ay_mg, az_mg, mag_mg)

        Delay(DBG_PERIOD_MS)
    }
}

isqrt(n)
{
    if (n <= 0) return 0
    if (n < 2) return n
    new x = n
    new y = (x + 1) / 2
    while (y < x) {
        x = y
        y = (x + n / x) / 2
    }
    return x
}
