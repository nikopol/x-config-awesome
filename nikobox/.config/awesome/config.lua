-- awesome local conf --

-- for gmail dont forget to bash next line
-- echo "machine mail.google.com login yourlogin@gmail.com password yourpassword" > ~/.netrc

-- required --

ALTKEY   = "Mod1"
MODKEY   = "Mod4"
TERM     = "urxvt"
BROWSER  = "chromium"
LOCKER   = "slock"
CHAUDIO  = "Master"          --alsa PCM/Master
NETINT   = "eth0"
SCREENINFO = 1               --screen for system tray & info 0=all

-- optionals (comment it to remove it) --

GMAIL    = 1
--SYSBAT   = "BAT1"          -- ls /sys/class/power_supply/
--SYSTEMP  = "thermal_zone0" -- ls /sys/class/thermal/
FILER    = "pcmanfm"
MOUNTS   = { "/stock2", "/stock", "/home", "/" }
--ORGPATHS = { "~/.org/computers.org", "~/.org/index.org", "~/.org/personal.org" }
