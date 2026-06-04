#if defined ALERT_SMS_INC
    #endinput
#endif
#define ALERT_SMS_INC

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

calcMagGx10(sumSqHalved)
{
    new magRaw = 2 * isqrt(sumSqHalved)
    return (magRaw * 10) / 8192
}

sendAlertSms(const event[], magGx10)
{
    new phone{SMS_NUM_MAX_LEN + 1}
    new size = ROMRead(KEY_SMSNUM, phone, SMS_NUM_MAX_LEN + 1)
    if (size <= 0 || phone{0} == 0) {
        Diagnostics("SD: SMS skip, no number")
        return
    }

    new cmdBuf{SMS_BUF_SIZE}
    new tmp{32}

    strpack(cmdBuf, "SendSMS ")
    strcat(cmdBuf, phone, SMS_BUF_SIZE)

    strpack(tmp, ", ")
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)
    strpack(tmp, event)
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)

    strpack(tmp, " a=")
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)
    valstr(tmp, magGx10 / 10)
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)
    strpack(tmp, ".")
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)
    valstr(tmp, magGx10 % 10)
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)
    strpack(tmp, "G %IMEI %LAT %LON")
    strcat(cmdBuf, tmp, SMS_BUF_SIZE)

    ExecCommand(cmdBuf)
    Diagnostics("SD: SMS sent a_g_x10=%d", magGx10)
}
