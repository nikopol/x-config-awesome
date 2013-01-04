-- {{{ License
-- Awesome configuration, using awesome 3.5 on Arch GNU/Linux
-- by NiKo <nikomomo@GMAIL.com> based on a work from Adrian C. <anrxc@sysphere.org>
-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}

-- Standard awesome library
local gears     = require("gears")
local awful     = require("awful")
awful.rules     = require("awful.rules")
                  require("awful.autofocus")
-- Widget and layout library
local wibox     = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty   = require("naughty")
local menubar   = require("menubar")
-- User libraries
local vicious   = require("vicious")
local scratch   = require("scratch")
                  require("config")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
   naughty.notify({
      preset = naughty.config.presets.critical,
      title  = "Oops, there were errors during startup!",
      text   = awesome.startup_errors
   })
end

-- Handle runtime errors after startup
do
   local in_error = false
   awesome.connect_signal("debug::error", function (err)
      -- Make sure we don't go into an endless error loop
      if in_error then return end
      in_error = true
      naughty.notify({
         preset = naughty.config.presets.critical,
         title  = "Oops, an error happened!",
         text   = err
      })
      in_error = false
   end)
end
-- }}}

-- {{{ Variable definitions
local home    = os.getenv("HOME")
local bin     = home .. "/.config/awesome/bin/"
local exec    = awful.util.spawn
local sexec   = awful.util.spawn_with_shell

if NOTIFYSCREEN then naughty.config.defaults.screen = NOTIFYSCREEN end
if NOTIFYPOS    then naughty.config.defaults.position = NOTIFYPOS end

-- Themes define colours, icons, and wallpapers
beautiful.init(home .. "/.config/awesome/zenburn.lua")

-- Table of layouts to cover with awful.layout.inc, order matters.
local layouts = {
   -- awful.layout.suit.floating,
   awful.layout.suit.tile,
   -- awful.layout.suit.tile.left,
   awful.layout.suit.tile.bottom,
   -- awful.layout.suit.tile.top,
   awful.layout.suit.fair,
   -- awful.layout.suit.fair.horizontal,
   -- awful.layout.suit.spiral,
   -- awful.layout.suit.spiral.dwindle,
   awful.layout.suit.max,
   -- awful.layout.suit.max.fullscreen,
   awful.layout.suit.magnifier
}
-- }}}

-- {{{ Wallpaper
for s = 1, screen.count() do
   if beautiful.wallpaper then
      gears.wallpaper.maximized(beautiful.wallpaper, s, true)
   else
      gears.wallpaper.set(beautiful.bg)
   end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {}
for s = 1, screen.count() do
   -- Each screen has its own tag table.
   tags[s] = awful.tag({ 1, 2, 3, 4, 5, 6, 7, 8, 9 }, s, layouts[1])
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "manual", TERM .. " -e man awesome" },
   { "edit config", EDITOR .. " " .. awesome.conffile },
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({
   items = {
      { "awesome", myawesomemenu, beautiful.awesome_icon },
      { "open terminal", TERM }
   }
})

mylauncher = awful.widget.launcher({
   image = beautiful.awesome_icon,
   menu = mymainmenu
})

-- Menubar configuration
menubar.utils.terminal = TERM -- Set the TERM for applications that require it
-- }}}

-- {{{ Wibox

-- Reusable separator
separator = wibox.widget.imagebox()
separator:set_image(beautiful.widget_sep)

-- CPU usage and temperature
cpuicon = wibox.widget.imagebox()
cpuicon:set_image(beautiful.widget_cpu)
cpugraph = awful.widget.graph()
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_color(beautiful.gradient)
vicious.register(cpugraph, vicious.widgets.cpu, "$1", 2)
if SYSTEMP then
   cputemp = wibox.widget.textbox()
   vicious.register(cputemp, vicious.widgets.thermal, " $1°", 20, SYSTEMP)
end
cpugraph:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec(TERM .. " -e htop") end)
))
cputip = awful.tooltip({
   objects = { cpuicon, cpugraph },
   timeout = 1,
   timer_function = function ()
      cmd = io.popen("ps -aux --cols 110 --sort=-%cpu | head -6")
      top = cmd:read("*a")
      return (
         "<span color=\""..beautiful.fg_normal.."\">"..top:match("^([^\n]+)").."</span>\n"..
         awful.util.escape(top:gsub("^([^\n]+)\n",""):gsub("\n$",""))
      )
   end
})

-- Battery state
if SYSBAT then
   vicious.cache(vicious.widgets.bat)
   baticon = wibox.widget.imagebox()
   baticon:set_image(beautiful.widget_bat)
   batwidget = wibox.widget.textbox()
   batwidget.fit = function(box,w,h)
      local w,h = wibox.widget.textbox.fit(box,w,h)
      return math.max(32,w),h
   end
   vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 60, SYSBAT)
   batbar = awful.widget.progressbar()
   batbar:set_vertical(true):set_ticks(true)
   batbar:set_height(14):set_width(8):set_ticks_size(2)
   batbar:set_background_color(beautiful.fg_off_widget)
   batbar:set_color(beautiful.gradient)
   vicious.register(batbar, vicious.widgets.bat, "$2", 60, SYSBAT)
end

-- Memory usage
vicious.cache(vicious.widgets.mem)
memicon = wibox.widget.imagebox()
memicon:set_image(beautiful.widget_mem)
memwidget = wibox.widget.textbox()
memwidget:set_align('center')
memwidget.fit = function(box,w,h)
   local w,h = wibox.widget.textbox.fit(box,w,h)
   return math.max(35,w),h
end
membar = awful.widget.progressbar()
membar:set_vertical(true):set_ticks(true)
membar:set_height(14):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_color(beautiful.gradient)
memtip = awful.tooltip({ objects = { memwidget, memicon, membar }})
vicious.register(membar, vicious.widgets.mem, "$1", 1)
vicious.register(
   memwidget, vicious.widgets.mem,
   function (widget,args)
      memtip:set_text(
         "Free <span color=\""..beautiful.fg_widget.."\">"..args[4].."</span>KB\n"..
         "Used <span color=\""..beautiful.fg_widget.."\">"..args[2].."</span>KB\n"..
         "Size <span color=\""..beautiful.fg_widget.."\">"..args[3].."</span>KB\n"..
         "Swap <span color=\""..beautiful.fg_widget.."\">"..args[5].."</span>%"
      )
      return args[1].."%"
   end,
   1
)

-- File system usage
if MOUNTS then
   vicious.cache(vicious.widgets.fs)
   fsicon = wibox.widget.imagebox()
   fsicon:set_image(beautiful.widget_fs)
   fs = {}
   fstip = {}
   for i=1,#MOUNTS do
      fs[i] = awful.widget.progressbar()
      fs[i]:set_vertical(true):set_ticks(true)
      fs[i]:set_height(16):set_width(8):set_ticks_size(2)
      fs[i]:set_border_color(beautiful.border_widget)
      fs[i]:set_background_color(beautiful.fg_off_widget)
      fs[i]:set_color(beautiful.gradient)
      fstip[i] = awful.tooltip({ objects = { fs[i] } })
      if FILER then
         fs[i]:buttons(awful.util.table.join(
            awful.button({ }, 1, function () exec(FILER, false) end)
         ))
      end
      vicious.register(
         fs[i], vicious.widgets.fs,
         function (widget, args)
            fstip[i]:set_text(
               "<span color=\""..beautiful.fg_normal.."\"><b>"..MOUNTS[i].."</b></span>\n"..
               "Free <span color=\""..beautiful.fg_widget.."\">"..args["{"..MOUNTS[i].." avail_gb}"].."</span>GB\n"..
               "Used <span color=\""..beautiful.fg_widget.."\">"..args["{"..MOUNTS[i].." used_gb}"].."</span>GB\n"..
               "Size <span color=\""..beautiful.fg_widget.."\">"..args["{"..MOUNTS[i].." size_gb}"].."</span>GB"
            )
            return args["{"..MOUNTS[i].." used_p}"];
         end,
         120
      )
   end
end

-- Network usage
if NETINT then
   vicious.cache(vicious.widgets.net)
   dnicon = wibox.widget.imagebox()
   dnicon:set_image(beautiful.widget_net)
   dngraph = awful.widget.graph()
   dngraph:set_width(20):set_height(14)
   dngraph:set_scale(true)
   dngraph:set_background_color(beautiful.fg_off_widget)
   dngraph:set_color(beautiful.fg_netdn_widget)
   dntext = wibox.widget.textbox()
   dntext.fit = function(box,w,h)
      local w,h = wibox.widget.textbox.fit(box,w,h)
      return math.max(40,w),h
   end
   dntext.align = "left"
   upicon = wibox.widget.imagebox()
   upicon:set_image(beautiful.widget_netup)
   upgraph = awful.widget.graph()
   upgraph:set_width(20):set_height(14)
   upgraph:set_scale(true)
   upgraph:set_background_color(beautiful.fg_off_widget)
   upgraph:set_color(beautiful.fg_netup_widget)
   uptext = wibox.widget.textbox()
   uptext:set_align('right')
   uptext.fit = function(box,w,h)
      local w,h = wibox.widget.textbox.fit(box,w,h)
      return math.max(40,w),h
   end
   uptext.align = "right"
   vicious.register(uptext, vicious.widgets.net, '<span color="'..beautiful.fg_netup_widget..'">${'..NETINT..' up_kb}</span>', 2)
   vicious.register(dntext, vicious.widgets.net, '<span color="'..beautiful.fg_netdn_widget..'">${'..NETINT..' down_kb}</span>', 2)
   vicious.register(upgraph, vicious.widgets.net, '${'..NETINT..' up_kb}', 2)
   vicious.register(dngraph, vicious.widgets.net, '${'..NETINT..' down_kb}', 2)
end

-- GMAIL
if GMAIL then
   mailicon = wibox.widget.imagebox()
   mailicon:set_image(beautiful.widget_mail)
   mailwidget = wibox.widget.textbox()
   mailwidget.fit = function(box,w,h)
      local w,h = wibox.widget.textbox.fit(box,w,h)
      return math.max(20,w),h
   end
   mailwidget:set_align('center')
   mailtip = awful.tooltip({ objects = { mailwidget } })
   vicious.register(
      mailwidget, vicious.widgets.gmail,
      function (widget, args)
         mailtip:set_text(args["{subject}"])
         return args["{count}"]
      end,
      180
   )
   mailwidget:buttons(awful.util.table.join(
      awful.button({ }, 1, function () exec(BROWSER .. " https://mail.google.com/mail/?shva=1#inbox") end)
   ))
end

-- Volume level
if CHAUDIO then
   vicious.cache(vicious.widgets.volume)
   volicon   = wibox.widget.imagebox()
   volicon:set_image(beautiful.widget_vol)
   volbar    = awful.widget.progressbar()
   volwidget = wibox.widget.textbox()
   volwidget:set_align('center')
   volwidget.fit = function(box,w,h)
      local w,h = wibox.widget.textbox.fit(box,w,h)
      return math.max(35,w),h
   end
   volbar:set_vertical(true):set_ticks(true)
   volbar:set_height(14):set_width(8):set_ticks_size(2)
   volbar:set_background_color(beautiful.fg_off_widget)
   volbar:set_color(beautiful.gradient)
   vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, CHAUDIO)
   vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, CHAUDIO)
   volbar:buttons(awful.util.table.join(
      awful.button({ }, 1, function () exec(TERM .. " -e alsamixer") end),
      awful.button({ }, 4, function () exec("amixer -q set " .. CHAUDIO .. " 2dB+", false) end),
      awful.button({ }, 5, function () exec("amixer -q set " .. CHAUDIO .. " 2dB-", false) end)
   ))
   volicon:buttons(awful.util.table.join(
      awful.button({ }, 1, function () exec("amixer -q set Master toggle", false) end)
   ))
   volwidget:buttons(volbar:buttons())
end

-- Date and time
dateicon = wibox.widget.imagebox()
dateicon:set_image(beautiful.widget_date)
datewidget = wibox.widget.textbox()
datetip = awful.tooltip({
   objects = { datewidget, dateicon },
   timeout = 1800,
   timer_function = function ()
      cmd = io.popen("cal -3")
      cal = cmd:read("*a")
      return (
         "<span color=\""..beautiful.fg_normal.."\">"..cal:match("^([^\n]+\n[^\n]+)").."</span>\n"..
         awful.util.escape(cal:gsub("^([^\n]+\n[^\n]+\n)",""):gsub("\n$",""))
      )
   end
})
vicious.register(datewidget, vicious.widgets.date, "%d/%m %R", 60)
datewidget:buttons(awful.util.table.join(
   awful.button({ }, 1, function () exec(bin .. "pylendar.py") end)
))

-- SysTray
systray = wibox.widget.systray()

-- Create a wibox for each screen and add it
mywibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
   awful.button({ }, 1, awful.tag.viewonly),
   awful.button({ MODKEY }, 1, awful.client.movetotag),
   awful.button({ }, 3, awful.tag.viewtoggle),
   awful.button({ MODKEY }, 3, awful.client.toggletag),
   awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
   awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
)
mytasklist = {}
mytasklist.buttons = awful.util.table.join(
   awful.button({ }, 1, function (c)
      if c == client.focus then
         c.minimized = true
      else
         -- Without this, the following
         -- :isvisible() makes no sense
         c.minimized = false
         if not c:isvisible() then
             awful.tag.viewonly(c:tags()[1])
         end
         -- This will also un-minimize
         -- the client, if needed
         client.focus = c
         c:raise()
      end
   end),
   awful.button({ }, 3, function ()
      if instance then
         instance:hide()
         instance = nil
      else
         instance = awful.menu.clients({ width=250 })
      end
   end),
   awful.button({ }, 4, function ()
      awful.client.focus.byidx(1)
      if client.focus then client.focus:raise() end
   end),
   awful.button({ }, 5, function ()
      awful.client.focus.byidx(-1)
      if client.focus then client.focus:raise() end
   end)
)

for s = 1, screen.count() do
   -- Create a promptbox for each screen
   mypromptbox[s] = awful.widget.prompt()
   -- Create an imagebox widget which will contains an icon indicating which layout we're using.
   -- We need one layoutbox per screen.
   mylayoutbox[s] = awful.widget.layoutbox(s)
   mylayoutbox[s]:buttons(awful.util.table.join(
      awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
      awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
      awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
   ))
   -- Create a taglist widget
   mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

   -- Create a tasklist widget
   mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

   -- Create the wibox
   mywibox[s] = awful.wibox({
   -- position = "top", screen = s 
      screen = s,
      fg = beautiful.fg_normal,
      height = 16,
      bg = beautiful.bg_normal,
      position = "top",
      border_color = beautiful.bg_normal,
      border_width = beautiful.border_width
   })

   -- Widgets that are aligned to the left
   local left_layout = wibox.layout.fixed.horizontal()
   left_layout:add(mylauncher)
   left_layout:add(mytaglist[s])
   left_layout:add(mylayoutbox[s])
   left_layout:add(mypromptbox[s])

   -- Widgets that are aligned to the right
   local right_layout = wibox.layout.fixed.horizontal()
   if s == SCREENINFO or 0 == SCREENINFO then

      if cputemp then right_layout:add(cputemp) end
      right_layout:add(cpuicon)
      right_layout:add(cpugraph)
      right_layout:add(separator)

      if memwidget then
         right_layout:add(memicon)
         right_layout:add(membar)
         right_layout:add(memwidget)
         right_layout:add(separator)
      end

      if fs then
         right_layout:add(fsicon)
         for i=1,#fs do
            right_layout:add(fs[i])
         end
         right_layout:add(separator)
      end

      if dngraph then
         right_layout:add(dnicon)
         right_layout:add(dntext)
         right_layout:add(dngraph)
         right_layout:add(separator)
      end
      if upgraph then
         right_layout:add(upgraph)
         right_layout:add(uptext)
         right_layout:add(upicon)
         right_layout:add(separator)
      end

      if batwidget then 
         right_layout:add(baticon)
         right_layout:add(batwidget)
         right_layout:add(batbar)
         right_layout:add(separator)
      end

      if mailwidget then
         right_layout:add(mailicon)
         right_layout:add(mailwidget)
         right_layout:add(separator)
      end

      if volwidget then
         right_layout:add(volicon)
         right_layout:add(volbar)
         right_layout:add(volwidget)
         right_layout:add(separator)
      end

      if datewidget then
         right_layout:add(dateicon)
         right_layout:add(datewidget)
         right_layout:add(separator)
      end

      right_layout:add(systray)
   end

   -- Now bring it all together (with the tasklist in the middle)
   local layout = wibox.layout.align.horizontal()
   layout:set_left(left_layout)
   layout:set_middle(mytasklist[s])
   layout:set_right(right_layout)

   mywibox[s]:set_widget(layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
   awful.button({ }, 3, function () mymainmenu:toggle() end),
   awful.button({ }, 4, awful.tag.viewnext),
   awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = awful.util.table.join(
   awful.key({ MODKEY,           }, "Left",   awful.tag.viewprev       ),
   awful.key({ MODKEY,           }, "Right",  awful.tag.viewnext       ),
   awful.key({ MODKEY,           }, "Escape", awful.tag.history.restore),

   awful.key({ MODKEY,           }, "j",
      function ()
         awful.client.focus.byidx( 1)
         if client.focus then client.focus:raise() end
      end),
   awful.key({ MODKEY,           }, "k",
      function ()
         awful.client.focus.byidx(-1)
         if client.focus then client.focus:raise() end
      end),
   awful.key({ MODKEY,           }, "w", function () mymainmenu:show() end),

   -- Layout manipulation
   awful.key({ MODKEY, "Shift"   }, "j", function () awful.client.swap.byidx( 1)     end),
   awful.key({ MODKEY, "Shift"   }, "k", function () awful.client.swap.byidx(-1)     end),
   awful.key({ MODKEY, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
   awful.key({ MODKEY, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
   awful.key({ MODKEY,           }, "u", awful.client.urgent.jumpto),
   awful.key({ MODKEY,           }, "Tab",
      function ()
         awful.client.focus.history.previous()
         if client.focus then
            client.focus:raise()
         end
      end),
   awful.key({ MODKEY,           }, "l",     function () awful.tag.incmwfact( 0.05)    end),
   awful.key({ MODKEY,           }, "h",     function () awful.tag.incmwfact(-0.05)    end),
   awful.key({ MODKEY, "Shift"   }, "h",     function () awful.tag.incnmaster( 1)      end),
   awful.key({ MODKEY, "Shift"   }, "l",     function () awful.tag.incnmaster(-1)      end),
   awful.key({ MODKEY, "Control" }, "h",     function () awful.tag.incncol( 1)         end),
   awful.key({ MODKEY, "Control" }, "l",     function () awful.tag.incncol(-1)         end),
   awful.key({ MODKEY,           }, "space", function () awful.layout.inc(layouts,  1) end),
   awful.key({ MODKEY, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
   awful.key({ MODKEY, "Control" }, "n", awful.client.restore),

   -- Standard program
   awful.key({ MODKEY,           }, "Return", function () exec(TERM) end),
   awful.key({ MODKEY, "Shift"   }, "r", awesome.restart),
   awful.key({ MODKEY, "Shift"   }, "q", awesome.quit),

   awful.key({ MODKEY }, "w", function () exec(BROWSER) end),

   awful.key({ MODKEY, "Shift"   }, "l", function () exec(LOCKER) end),
   awful.key({                   }, "XF86PowerOff", function () exec(LOCKER) end),
   awful.key({                   }, "XF86Sleep", function () exec(LOCKER) end),

   -- Audio
   awful.key({                   }, "XF86AudioPlay", function () exec("mocp --toggle-pause", false) end),
   awful.key({ MODKEY, "Shift"   }, "m", function () exec("amixer -q set Master toggle", false) end),
   awful.key({                   }, "XF86AudioMute", function () exec("amixer -q set Master toggle", false) end),
   awful.key({ MODKEY, "Shift"   }, "Down", function () exec("amixer -q set " .. CHAUDIO .. " 2dB-", false) end),
   awful.key({                   }, "XF86AudioLowerVolume", function () exec("amixer -q set " .. CHAUDIO .. " 2dB-", false) end),
   awful.key({ MODKEY, "Shift"   }, "Up", function () exec("amixer -q set " .. CHAUDIO .. " 2dB+", false)  end),
   awful.key({                   }, "XF86AudioRaiseVolume", function () exec("amixer -q set " .. CHAUDIO .. " 2dB+", false) end),
   awful.key({ MODKEY, "Shift"   }, "Left", function () exec("mocp --previous", false) end),
   awful.key({                   }, "XF86AudioPrev", function () exec("mocp --previous", false) end),
   awful.key({ MODKEY, "Shift"   }, "Right", function () exec("mocp --next", false) end),
   awful.key({                   }, "XF86AudioNext", function () exec("mocp --next", false) end),

   -- Prompt
   awful.key({ MODKEY },            "r",     function () mypromptbox[mouse.screen]:run() end),

   awful.key({ MODKEY }, "x",
      function ()
         awful.prompt.run({ prompt = "Run Lua code: " },
         mypromptbox[mouse.screen].widget,
         awful.util.eval, nil,
         awful.util.getdir("cache") .. "/history_eval")
      end),
   
   -- Menubar
   awful.key({ MODKEY }, "p", function() menubar.show() end),
   awful.key({ MODKEY }, "F2", function() menubar.show() end)

)

clientkeys = awful.util.table.join(
   awful.key({ MODKEY,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
   awful.key({ MODKEY, "Shift"   }, "c",      function (c) c:kill()                         end),
   awful.key({ MODKEY, "Control" }, "space",  awful.client.floating.toggle                     ),
   awful.key({ MODKEY, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
   awful.key({ MODKEY,           }, "o",      awful.client.movetoscreen                        ),
   awful.key({ MODKEY,           }, "t",      function (c) c.ontop = not c.ontop            end),
   awful.key({ MODKEY,           }, "n",
      function (c)
         -- The client currently has the input focus, so it cannot be
         -- minimized, since minimized clients can't have the focus.
         c.minimized = true
      end),
   awful.key({ MODKEY,           }, "m",
      function (c)
         c.maximized_horizontal = not c.maximized_horizontal
         c.maximized_vertical   = not c.maximized_vertical
      end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
   globalkeys = awful.util.table.join(globalkeys,
      awful.key({ MODKEY }, "#" .. i + 9,
         function ()
            local screen = mouse.screen
            if tags[screen][i] then
               awful.tag.viewonly(tags[screen][i])
            end
         end),
      awful.key({ MODKEY, "Control" }, "#" .. i + 9,
         function ()
            local screen = mouse.screen
            if tags[screen][i] then
               awful.tag.viewtoggle(tags[screen][i])
            end
         end),
      awful.key({ MODKEY, "Shift" }, "#" .. i + 9,
         function ()
            if client.focus and tags[client.focus.screen][i] then
               awful.client.movetotag(tags[client.focus.screen][i])
            end
         end),
      awful.key({ MODKEY, "Control", "Shift" }, "#" .. i + 9,
         function ()
            if client.focus and tags[client.focus.screen][i] then
               awful.client.toggletag(tags[client.focus.screen][i])
            end
         end)
   )
end

clientbuttons = awful.util.table.join(
   awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
   awful.button({ MODKEY }, 1, awful.mouse.client.move),
   awful.button({ MODKEY }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
   -- All clients will match this rule.
   { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
   -- { rule = { class = "MPlayer" },
   --    properties = { floating = true } },
   { rule = { class = "pinentry" },
      properties = { floating = true } },
   { rule = { class = "gimp" },
      properties = { floating = true } },
   -- Set Firefox to always map on tags number 2 of screen 1.
   -- { rule = { class = "Firefox" },
   --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
   -- Enable sloppy focus
   c:connect_signal("mouse::enter", function(c)
      if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
         and awful.client.focus.filter(c) then
         client.focus = c
      end
   end)

   if not startup then
      -- Set the windows at the slave,
      -- i.e. put it at the end of others instead of setting it master.
      -- awful.client.setslave(c)

      -- Put windows in a smart way, only if they does not set an initial position.
      if not c.size_hints.user_position and not c.size_hints.program_position then
         awful.placement.no_overlap(c)
         awful.placement.no_offscreen(c)
      end
   end

   local titlebars_enabled = false
   if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
      -- Widgets that are aligned to the left
      local left_layout = wibox.layout.fixed.horizontal()
      left_layout:add(awful.titlebar.widget.iconwidget(c))

      -- Widgets that are aligned to the right
      local right_layout = wibox.layout.fixed.horizontal()
      right_layout:add(awful.titlebar.widget.floatingbutton(c))
      right_layout:add(awful.titlebar.widget.maximizedbutton(c))
      right_layout:add(awful.titlebar.widget.stickybutton(c))
      right_layout:add(awful.titlebar.widget.ontopbutton(c))
      right_layout:add(awful.titlebar.widget.closebutton(c))

      -- The title goes in the middle
      local title = awful.titlebar.widget.titlewidget(c)
      title:buttons(awful.util.table.join(
         awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
         end),
         awful.button({ }, 3, function()
            client.focus = c
               c:raise()
                  awful.mouse.client.resize(c)
         end)
      ))

      -- Now bring it all together
      local layout = wibox.layout.align.horizontal()
      layout:set_left(left_layout)
      layout:set_right(right_layout)
      layout:set_middle(title)

      awful.titlebar(c):set_widget(layout)
   end
end)

client.connect_signal("focus", function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}
