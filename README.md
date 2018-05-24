# fancontrol.sh
adjust fan speed according to CPU temp using smcFanControl (https://github.com/hholtmann/smcFanControl)

one way to use it with crontab, e.g.

*/5 * * * * /Users/chris/bin/fancontrol.sh >> /var/log/fancontrol.log 2>&1
