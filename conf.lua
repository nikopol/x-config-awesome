--font used by the theme
FONT           = 'Envy Code R 10'
TERM           = 'urxvt'
LOCKER         = 'slock'

--comment to disable this widget
CLOCK_FMT      = '%d/%m %R'

--network bandwith, comment to disable
NET_INTERFACE  = 'eno1'

--system temp, comment to disable
THERMAL_SRC    = '/sys/class/thermal/thermal_zone0/temp'

--volume, comment to disable
GET_VOLUME_CMD = 'amixer sget Master'
INC_VOLUME_CMD = 'amixer sset Master 5%+'
DEC_VOLUME_CMD = 'amixer sset Master 5%-'
TOG_VOLUME_CMD = 'amixer sset Master toggle'
MUSIC_PAUSE    = 'cmus-remote --pause'
MUSIC_NEXT     = 'cmus-remote --next'
MUSIC_PREV     = 'cmus-remote --prev'
