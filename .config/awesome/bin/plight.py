#!/usr/bin/env python

# plight -- Commandline backlight utility
#           with an optional GTK progressbar
# Copyright (C) 2009 Adrian C. <anrxc_sysphere_org>

# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.


import gtk
import gobject
import optparse

import string
import commands
from subprocess import call


appname = "Plight"
appicon = "/usr/share/gtk-doc/html/libgimpwidgets/stock-tool-brightness-contrast-22.png"


class Light():
    def __init__(self, acpi=False, adj=False, arg=None):
        if acpi == True:
            if adj == True:
                # We want to in/de/crement on key press remember, 
                # if controls aren't in hardware, so expand this
                #
                # Todo: users can't write there, deal with it
                #acpiopt = " %f > /proc/acpi/video/GFX0/DD03/brightness" % arg
                #call("echo" + acpiopt, shell=True)
                # Todo: write with python
                #self.light = file("/proc/acpi/video/GFX0/DD03/brightness", 'a')
                #print >>self.light,arg
                pass
            # Todo: this is 2x slower than xbacklight, use a regexp
            self.light = file("/proc/acpi/video/GFX0/DD03/brightness").read()
            self.percent = string.split(self.light, 'current: ')[1].strip()
        else:
            if adj == True:
                # We want to in/de/crement on key press remember, 
                # if controls aren't in hardware, so expand this
                #   $ xbacklight -steps 1 -time 0 -inc 10
                #   $ xbacklight -steps 1 -time 0 -dec 10
                xbopt = " -display :0.0 -time 0 -set %f" % arg
                call("xbacklight" + xbopt, shell=True)
            self.light = commands.getoutput("xbacklight -get -time 0")
            # Todo: splitting is slow, just padd
            self.percent = string.split(self.light, '.')[0]

        self.label = "Brightness: %s%%" % self.percent


class Plight:
    def __init__(self, fraction, label, wmname=appname):
        self.window = gtk.Window(gtk.WINDOW_POPUP)
        self.window.set_title(wmname)
        self.window.set_border_width(1)
        self.window.set_default_size(180, -1)
        self.window.set_position(gtk.WIN_POS_CENTER)

        self.window.connect("destroy", lambda x: gtk.main_quit())
        self.timer = gobject.timeout_add(2000, lambda: gtk.main_quit())

        self.widgetbox = gtk.HBox()

        self.icon = gtk.Image()
        self.icon.set_from_file(appicon)
        self.icon.show()

        self.progressbar = gtk.ProgressBar()
        self.progressbar.set_orientation(gtk.PROGRESS_LEFT_TO_RIGHT)
        self.progressbar.set_fraction(float(fraction) / 100)
        self.progressbar.set_text(label)

        self.widgetbox.pack_start(self.icon)
        self.widgetbox.pack_start(self.progressbar)
        self.window.add(self.widgetbox)
        self.window.show_all()


def main():
    usage = "%prog [-s] [-c PERCENT] [-a] [-q]"
    parser = optparse.OptionParser(usage=usage)
    parser.add_option('-s', '--status', action='store_true', dest='status', help='display current brightness level')
    parser.add_option('-c', '--change', type='int', dest='percent', help='increase or decrease brightness to given percentage')
    parser.add_option('-a', '--acpi', action='store_true', dest='acpi', default=False, help='make use of ACPI (default is xbacklight)')
    parser.add_option('-q', '--quiet', action='store_true', dest='quiet', help='adjust brightness without the progressbar')
    (option, args) = parser.parse_args()

    if option.percent:
        if option.quiet:
            raise SystemExit(Light(option.acpi, True, option.percent).label)
        bright = Light(option.acpi, True, option.percent)
    elif option.status:
        bright = Light(option.acpi)
    else:
        raise SystemExit("Unknown option, use --help to get explanations for these:\n\n\t%s" % parser.get_usage())

    Plight(bright.percent, bright.label)
    gtk.main()
    return 0


if __name__ == "__main__":
    main()
