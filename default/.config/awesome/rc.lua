-- {{{ License
-- Awesome configuration, using awesome 3.4.6 on Arch GNU/Linux
--   * NiKo <nikomomo@GMAIL.com>
--   * Adrian C. <anrxc@sysphere.org>
-- This work is licensed under the Creative Commons Attribution-Share
-- Alike License: http://creativecommons.org/licenses/by-sa/3.0/
-- }}}


-- {{{ Libraries
require("awful")
require("awful.rules")
require("awful.autofocus")
-- User libraries
require("vicious")
require("scratch")
require("naughty")
require("config")
-- }}}

-- {{{ Variable definitions
local home    = os.getenv("HOME")
local bin     = home .. "/.config/awesome/bin/"
local exec    = awful.util.spawn
local sexec   = awful.util.spawn_with_shell

if NOTIFYSCREEN then
	naughty.config.default_preset.screen = NOTIFYSCREEN
end
if NOTIFYPOS then
	naughty.config.default_preset.position = NOTIFYPOS
end

-- Beautiful theme
beautiful.init(home .. "/.config/awesome/zenburn.lua")

--Window management layouts
layouts = {
	awful.layout.suit.tile,        -- 1
	awful.layout.suit.tile.bottom, -- 2
	awful.layout.suit.fair,        -- 3
	awful.layout.suit.max,         -- 4
	awful.layout.suit.magnifier,   -- 5
	awful.layout.suit.floating     -- 6
}
-- }}}

-- {{{ Tags
tags = {
	names  = { "1-term", "2-term",  "3-term",  "4-web",   "5-mail",  "6-im",    "7-tmp",   "8-hideout" },
	layout = { layouts[1],layouts[1],layouts[1],layouts[4],layouts[1],layouts[1],layouts[1],layouts[1] }
}
for s = 1, screen.count() do
	tags[s] = awful.tag(tags.names, s, tags.layout)
	awful.tag.setproperty(tags[s][6], "mwfact", 0.20)
	awful.tag.setproperty(tags[s][8], "hide",   true)
end
-- }}}

-- {{{ Wibox
--
-- {{{ Widgets configuration
--
-- {{{ Reusable separator
separator = widget({ type = "imagebox" })
separator.image = image(beautiful.widget_sep)
-- }}}

-- {{{ CPU usage and temperature
cpuicon = widget({ type = "imagebox" })
cpuicon.image = image(beautiful.widget_cpu)
-- Initialize widgets
cpugraph  = awful.widget.graph()
-- Graph properties
cpugraph:set_width(40):set_height(14)
cpugraph:set_background_color(beautiful.fg_off_widget)
cpugraph:set_gradient_angle(0):set_gradient_colors({
	beautiful.fg_end_widget,
	beautiful.fg_center_widget,
	beautiful.fg_widget
})
-- Register widgets
vicious.register(cpugraph, vicious.widgets.cpu, "$1")
if SYSTEMP then
	cputemp = widget({ type = "textbox" })
	vicious.register(cputemp, vicious.widgets.thermal, " $1°", 19, SYSTEMP)
end
-- Register buttons
cpugraph.widget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () exec(TERM .. " -e htop") end)
))
-- }}}

-- {{{ Battery state
if SYSBAT then
	baticon = widget({ type = "imagebox" })
	baticon.image = image(beautiful.widget_bat)
	-- Initialize widget
	batwidget = widget({ type = "textbox" })
	-- Register widget
	vicious.register(batwidget, vicious.widgets.bat, "$1$2%", 61, SYSBAT)
	batbar = awful.widget.progressbar()
	batbar:set_vertical(true):set_ticks(true)
	batbar:set_height(14):set_width(8):set_ticks_size(2)
	batbar:set_background_color(beautiful.fg_off_widget)
	batbar:set_gradient_colors({
		beautiful.fg_end_widget,
		beautiful.fg_center_widget,
		beautiful.fg_widget
	})
	-- Register widget
	vicious.register(batbar, vicious.widgets.bat, "$2", 61, SYSBAT)
end
-- }}}

-- {{{ Memory usage
memicon = widget({ type = "imagebox" })
memicon.image = image(beautiful.widget_mem)
memwidget = widget({ type = "textbox" })
-- Initialize widget
membar = awful.widget.progressbar()
-- Pogressbar properties
membar:set_vertical(true):set_ticks(true)
membar:set_height(14):set_width(8):set_ticks_size(2)
membar:set_background_color(beautiful.fg_off_widget)
membar:set_gradient_colors({
	beautiful.fg_widget,
	beautiful.fg_center_widget,
	beautiful.fg_end_widget
})
-- Register widget
memtip = awful.tooltip({ objects = { memwidget, memicon, membar.widget }})
vicious.register(membar, vicious.widgets.mem, "$1", 13)
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
	13
)
-- }}}

-- {{{ File system usage
if MOUNTS then
	fswidgets = { separator }
	-- Enable caching
	vicious.cache(vicious.widgets.fs)
	-- Initialize widgets
	fsicon = widget({ type = "imagebox" })
	fsicon.image = image(beautiful.widget_fs)
	fs = {}
	fstip = {}
	for i=1,#MOUNTS do
		fs[i] = awful.widget.progressbar()
		fs[i]:set_vertical(true):set_ticks(true)
		fs[i]:set_height(16):set_width(8):set_ticks_size(2)
		fs[i]:set_border_color(beautiful.border_widget)
		fs[i]:set_background_color(beautiful.fg_off_widget)
		fs[i]:set_gradient_colors({
			beautiful.fg_widget,
			beautiful.fg_center_widget,
			beautiful.fg_end_widget
		})
		fstip[i] = awful.tooltip({ objects = { fs[i].widget } })
		-- Register buttons
		if FILER then
			fs[i].widget:buttons(awful.util.table.join(
				awful.button({ }, 1, function () exec(FILER, false) end)
			))
		end
		-- Register widget
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
			599
		)
		table.insert(fswidgets, fs[i].widget)
	end
	table.insert(fswidgets, fsicon)
end
-- }}}

-- {{{ Network usage
if NETINT then
	dnicon = widget({ type = "imagebox" })
	dnicon.image = image(beautiful.widget_net)
	dngraph = awful.widget.graph()
	dngraph:set_width(20):set_height(14)
	dngraph:set_scale(true)
	dngraph:set_background_color(beautiful.fg_off_widget)
	dngraph:set_color(beautiful.fg_netdn_widget)
	dntext = widget({ type = "textbox" })
	dntext.width = 55
	dntext.align = "left"
	upicon = widget({ type = "imagebox" })
	upicon.image = image(beautiful.widget_netup)
	upgraph = awful.widget.graph()
	upgraph:set_width(20):set_height(14)
	upgraph:set_scale(true)
	upgraph:set_background_color(beautiful.fg_off_widget)
	upgraph:set_color(beautiful.fg_netup_widget)
	uptext = widget({ type = "textbox" })
	uptext.width = 55
	uptext.align = "right"
	-- Register widget
	vicious.register(uptext, vicious.widgets.net, '<span color="'..beautiful.fg_netup_widget..'">${'..NETINT..' up_kb}</span>', 1)
	vicious.register(dntext, vicious.widgets.net, '<span color="'..beautiful.fg_netdn_widget..'">${'..NETINT..' down_kb}</span>', 1)
	vicious.register(upgraph, vicious.widgets.net, '${'..NETINT..' up_kb}', 1)
	vicious.register(dngraph, vicious.widgets.net, '${'..NETINT..' down_kb}', 1)
	netwidget = { separator, upicon, uptext, upgraph.widget, separator, dngraph.widget, dntext, dnicon }
end
-- }}}

-- {{{ GMAIL
if GMAIL then
	-- echo "machine mail.google.com login yourlogin@gmail.com password yourpassword" > ~/.netrc 
	mailicon = widget({ type = "imagebox" })
	mailicon.image = image(beautiful.widget_mail)
	-- Initialize widget
	mailwidget = widget({ type = "textbox" })
	mailwidget.width = 20
	mailwidget.align = "center"
	mailtip = awful.tooltip({ objects = { mailwidget } })
	-- Register widget
	vicious.cache(vicious.widgets.gmail)
	vicious.register(
		mailwidget, vicious.widgets.gmail,
		function (widget, args)
			mailtip:set_text(args["{subject}"])
			return args["{count}"]
		end,
		180
	)
	-- Register buttons
	mailwidget:buttons(awful.util.table.join(
		awful.button({ }, 1, function () exec(BROWSER .. " https://mail.google.com/mail/?shva=1#inbox") end)
	))
end
-- }}}

-- {{{ Org-mode agenda
if ORGPATHS then
	orgicon = widget({ type = "imagebox" })
	orgicon.image = image(beautiful.widget_org)
	-- Initialize widget
	orgwidget = widget({ type = "textbox" })
	-- Configure widget
	local orgcolors = {
		past   = '<span color="'..beautiful.fg_urgent..'">',
		today  = '<span color="'..beautiful.fg_normal..'">',
		soon   = '<span color="'..beautiful.fg_widget..'">',
		future = '<span color="'..beautiful.fg_netup_widget..'">'
	}
	-- Register widget
	vicious.register(orgwidget, vicious.widgets.org,
		orgcolors.past..'$1</span>-'..orgcolors.today .. '$2</span>-' ..
		orgcolors.soon..'$3</span>-'..orgcolors.future.. '$4</span>', 601,
		ORGPATHS
	)
	-- Register buttons
	orgwidget:buttons(awful.util.table.join(
		awful.button({ }, 1, function () exec("emacsclient --eval '(org-agenda-list)'") end),
		awful.button({ }, 3, function () exec("emacsclient --eval '(make-remember-frame)'") end)
	))
end
-- }}}

-- {{{ Volume level
if CHAUDIO then
	volicon = widget({ type = "imagebox" })
	volicon.image = image(beautiful.widget_vol)
	-- Initialize widgets
	volbar    = awful.widget.progressbar()
	volwidget = widget({ type = "textbox" })
	-- Progressbar properties
	volbar:set_vertical(true):set_ticks(true)
	volbar:set_height(14):set_width(8):set_ticks_size(2)
	volbar:set_background_color(beautiful.fg_off_widget)
	volbar:set_gradient_colors({
		beautiful.fg_widget,
		beautiful.fg_center_widget,
		beautiful.fg_end_widget
	})
	-- Enable caching
	vicious.cache(vicious.widgets.volume)
	-- Register widgets
	vicious.register(volbar,    vicious.widgets.volume,  "$1",  2, CHAUDIO)
	vicious.register(volwidget, vicious.widgets.volume, " $1%", 2, CHAUDIO)
	-- Register buttons
	volbar.widget:buttons(awful.util.table.join(
		awful.button({ }, 1, function () exec(TERM .. " -e alsamixer") end),
		awful.button({ }, 4, function () exec("amixer -q set " .. CHAUDIO .. " 2dB+", false) end),
		awful.button({ }, 5, function () exec("amixer -q set " .. CHAUDIO .. " 2dB-", false) end)
	))
	volicon:buttons(awful.util.table.join(
		awful.button({ }, 1, function () exec("amixer -q set Master toggle", false) end)
	))
	-- Register assigned buttons
	volwidget:buttons(volbar.widget:buttons())
end
-- }}}

-- {{{ Date and time
dateicon = widget({ type = "imagebox" })
dateicon.image = image(beautiful.widget_date)
-- Initialize widget
datewidget = widget({ type = "textbox" })
datetip = awful.tooltip({
	objects = { datewidget, dateicon },
	timeout = 1800,
	timer_function = function ()
		cal = ""
		cmd = io.popen("cal -3")
		for line in cmd:lines() do
			cal = cal .. line .. "\n"
		end
		return cal
	end
})
-- Register widget
vicious.register(datewidget, vicious.widgets.date, "%d/%m %R", 61)
-- Register buttons
datewidget:buttons(awful.util.table.join(
	awful.button({ }, 1, function () exec(bin .. "pylendar.py") end)
))
-- }}}

-- {{{ System tray
systray = widget({ type = "systray" })
-- }}}
-- }}}

-- {{{ Wibox initialisation
wibox     = {}
promptbox = {}
layoutbox = {}
taglist   = {}
taglist.buttons = awful.util.table.join(
	awful.button({ },        1, awful.tag.viewonly),
	awful.button({ MODKEY }, 1, awful.client.movetotag),
	awful.button({ },        3, awful.tag.viewtoggle),
	awful.button({ MODKEY }, 3, awful.client.toggletag),
	awful.button({ },        4, awful.tag.viewnext),
	awful.button({ },        5, awful.tag.viewprev
))

taskbar = {}
taskbar.buttons = awful.util.table.join(
	awful.button({ }, 1,
		function (c)
			if not c:isvisible() then
				awful.tag.viewonly(c:tags()[1])
			end
			client.focus = c
			c:raise()
		end),
	awful.button({ }, 3,
		function ()
			if instance then
				instance:hide()
				instance = nil
			else
				instance = awful.menu.clients({ width=250 })
			 end
		end),
	awful.button({ }, 4,
		function ()
			awful.client.focus.byidx(1)
			if client.focus then client.focus:raise() end
		end),
	awful.button({ }, 5,
		function ()
			awful.client.focus.byidx(-1)
			if client.focus then client.focus:raise() end
		end)
)

for s = 1, screen.count() do
	-- Create a promptbox
	promptbox[s] = awful.widget.prompt({ layout = awful.widget.layout.horizontal.leftright })
	-- Create a tasklist
	taskbar[s] = awful.widget.tasklist(
		function(c)
			return awful.widget.tasklist.label.currenttags(c, s)
		end, taskbar.buttons
	)
	-- Create a layoutbox
	layoutbox[s] = awful.widget.layoutbox(s)
	layoutbox[s]:buttons(awful.util.table.join(
		awful.button({ }, 1, function () awful.layout.inc(layouts,  1) end),
		awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
		awful.button({ }, 4, function () awful.layout.inc(layouts,  1) end),
		awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)
	))
	-- Create the taglist
	taglist[s] = awful.widget.taglist(s, awful.widget.taglist.label.all, taglist.buttons)
	-- Create the wibox
	wibox[s] = awful.wibox({
		screen = s,
		fg = beautiful.fg_normal,
		height = 16,
		bg = beautiful.bg_normal,
		position = "top",
		border_color = beautiful.bg_normal,
		border_width = beautiful.border_width
	})
	-- Add widgets to the wibox
	if s == SCREENINFO or 0 == SCREENINFO then
		wibox[s].widgets = awful.util.table.join(
			{{
				taglist[s],
				layoutbox[s],
				separator,
				promptbox[s],
				separator,
				["layout"] = awful.widget.layout.horizontal.leftright
			}},
			{ systray },
			datewidget and { separator, datewidget, dateicon } or {},
			volwidget  and { separator, volwidget, volbar.widget, volicon } or {},
			orgwidget  and { separator, orgwidget, orgicon } or {},
			mailwidget and { separator, mailwidget, mailicon } or {},
			netwidget or {},
			fswidgets or {},
			memwidget and { separator, memwidget, membar.widget, memicon } or {},
			batwidget and { separator, batwidget, batbar.widget, baticon } or {},
			{ separator, cputemp or nil, cpugraph.widget, cpuicon },
			{ separator, taskbar[s] },
			{ separator, ["layout"] = awful.widget.layout.horizontal.rightleft }
		)
	else
		wibox[s].widgets = awful.util.table.join(
			{{
				taglist[s],
				layoutbox[s],
				separator,
				promptbox[s],
				separator,
				["layout"] = awful.widget.layout.horizontal.leftright
			}},
			{ separator, taskbar[s] },
			{ ["layout"] = awful.widget.layout.horizontal.rightleft }
		)
	end
end
-- }}}
-- }}}


-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
	awful.button({ }, 4, awful.tag.viewnext),
	awful.button({ }, 5, awful.tag.viewprev)
))

-- Client bindings
clientbuttons = awful.util.table.join(
	awful.button({ },        1, function (c) client.focus = c; c:raise() end),
	awful.button({ MODKEY }, 1, awful.mouse.client.move),
	awful.button({ MODKEY }, 2, awful.mouse.client.resize)
)
-- }}}


-- {{{ Key bindings
--
-- {{{ Global keys
globalkeys = awful.util.table.join(
	-- {{{ Applications
	awful.key({ MODKEY }, "w", function () exec(BROWSER) end),
	awful.key({ MODKEY }, "Return", function () exec(TERM) end),
	awful.key({ MODKEY, "Shift" }, "l", function () exec(LOCKER) end),
	-- }}}

	-- {{{ Multimedia keys
	awful.key({ MODKEY, "Shift" }, "m", function () exec("amixer -q set Master toggle", false) end),
	awful.key({ MODKEY, "Shift" }, "Down", function () exec("amixer -q set " .. CHAUDIO .. " 2dB-", false) end),
	awful.key({ MODKEY, "Shift" }, "Up", function () exec("amixer -q set " .. CHAUDIO .. " 2dB+", false)  end),
	--awful.key({}, "#232", function () exec(bin .. "plight.py -s") end),
	--awful.key({}, "#233", function () exec(bin .. "plight.py -s") end),
	--awful.key({}, "#244", function () exec("sudo /usr/sbin/pm-hibernate") end),
	--awful.key({}, "#150", function () exec("sudo /usr/sbin/pm-suspend")   end),
	--awful.key({}, "#225", function () exec(bin .. "pypres.py") end),
	--awful.key({}, "#157", function () if boosk then osk()
	--	else boosk, osk = pcall(require, "osk") end
	--end),
	-- }}}

	-- {{{ Prompt menus
	awful.key({ MODKEY }, "p", function ()
		awful.prompt.run({ prompt = "Run: " }, promptbox[mouse.screen].widget,
			function (...) promptbox[mouse.screen].text = exec(unpack(arg), false) end,
			awful.completion.shell, awful.util.getdir("cache") .. "/history")
	end),
	awful.key({ MODKEY }, "F3", function ()
		awful.prompt.run(
			{ prompt = "Calc: " }, promptbox[mouse.screen].widget,
			function (...)
				exp = unpack(arg)
				val = awful.util.eval(exp)
				naughty.notify({ title = exp, text = val })
			end)
	end),
	awful.key({ ALTKEY }, "F5", function ()
		awful.prompt.run({ prompt = "Lua: " }, promptbox[mouse.screen].widget,
		awful.util.eval, nil, awful.util.getdir("cache") .. "/history_eval")
	end),
	-- }}}

	-- {{{ Awesome controls
	awful.key({ MODKEY }, "b", function ()
		wibox[mouse.screen].visible = not wibox[mouse.screen].visible
	end),
	awful.key({ MODKEY, "Shift" }, "q", awesome.quit),
	awful.key({ MODKEY, "Shift" }, "r", function ()
		promptbox[mouse.screen].text = awful.util.escape(awful.util.restart())
	end),
	-- }}}

	-- {{{ Tag browsing
	awful.key({ ALTKEY }, "n",   awful.tag.viewnext),
	awful.key({ ALTKEY }, "p",   awful.tag.viewprev),
	awful.key({ ALTKEY }, "Tab", awful.tag.history.restore),
	-- }}}

	-- {{{ Layout manipulation
	awful.key({ MODKEY }, "l",          function () awful.tag.incmwfact( 0.05) end),
	awful.key({ MODKEY }, "h",          function () awful.tag.incmwfact(-0.05) end),
	awful.key({ MODKEY, "Shift" }, "l", function () awful.client.incwfact(-0.05) end),
	awful.key({ MODKEY, "Shift" }, "h", function () awful.client.incwfact( 0.05) end),
	awful.key({ MODKEY, "Shift" }, "space", function () awful.layout.inc(layouts, -1) end),
	awful.key({ MODKEY },          "space", function () awful.layout.inc(layouts,  1) end),
	-- }}}

	-- {{{ Focus controls
	--awful.key({ MODKEY }, "p", function () awful.screen.focus_relative(1) end),
	awful.key({ MODKEY }, "s", function () scratch.pad.toggle() end),
	awful.key({ MODKEY }, "u", awful.client.urgent.jumpto),
	awful.key({ MODKEY }, "j", function ()
		awful.client.focus.byidx(1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ MODKEY }, "k", function ()
		awful.client.focus.byidx(-1)
		if client.focus then client.focus:raise() end
	end),
	awful.key({ MODKEY }, "Tab", function ()
		awful.client.focus.history.previous()
		if client.focus then client.focus:raise() end
	end),
	awful.key({ ALTKEY }, "Escape", function ()
		awful.menu.menu_keys.down = { "Down", "Alt_L" }
		local cmenu = awful.menu.clients({width=230}, { keygrabber=true, coords={x=525, y=330} })
	end),
	awful.key({ MODKEY, "Shift" }, "j", function () awful.client.swap.byidx(1)  end),
	awful.key({ MODKEY, "Shift" }, "k", function () awful.client.swap.byidx(-1) end)
	-- }}}
)
-- }}}

-- {{{ Client manipulation
clientkeys = awful.util.table.join(
	awful.key({ MODKEY }, "c", function (c) c:kill() end),
	awful.key({ MODKEY }, "d", function (c) scratch.pad.set(c, 0.60, 0.60, true) end),
	awful.key({ MODKEY }, "f", function (c) awful.titlebar.remove(c)
		c.fullscreen           = not c.fullscreen
	end),
	awful.key({ MODKEY }, "m", function (c)
		c.maximized_horizontal = not c.maximized_horizontal
		c.maximized_vertical   = not c.maximized_vertical
	end),
	awful.key({ MODKEY }, "o",     awful.client.movetoscreen),
	awful.key({ MODKEY }, "Next",  function () awful.client.moveresize( 20,  20, -40, -40) end),
	awful.key({ MODKEY }, "Prior", function () awful.client.moveresize(-20, -20,  40,  40) end),
	awful.key({ MODKEY }, "Down",  function () awful.client.moveresize(  0,  20,   0,   0) end),
	awful.key({ MODKEY }, "Up",    function () awful.client.moveresize(  0, -20,   0,   0) end),
	awful.key({ MODKEY }, "Left",  function () awful.client.moveresize(-20,   0,   0,   0) end),
	awful.key({ MODKEY }, "Right", function () awful.client.moveresize( 20,   0,   0,   0) end),
	awful.key({ MODKEY, "Control"},"r", function (c) c:redraw() end),
	awful.key({ MODKEY, "Shift" }, "0", function (c) c.sticky = not c.sticky end),
	awful.key({ MODKEY, "Shift" }, "m", function (c) c:swap(awful.client.getmaster()) end),
	awful.key({ MODKEY, "Shift" }, "c", function (c) exec("kill -CONT " .. c.pid) end),
	awful.key({ MODKEY, "Shift" }, "s", function (c) exec("kill -STOP " .. c.pid) end),
	awful.key({ MODKEY, "Shift" }, "t", function (c)
		if   c.titlebar then awful.titlebar.remove(c)
		else awful.titlebar.add(c, { MODKEY = MODKEY }) end
	end),
	awful.key({ MODKEY, "Shift" }, "f", function (c) if awful.client.floating.get(c)
		then awful.client.floating.delete(c);    awful.titlebar.remove(c)
		else awful.client.floating.set(c, true); awful.titlebar.add(c) end
	end)
)
-- }}}

-- {{{ Keyboard digits
local keynumber = 0
for s = 1, screen.count() do
	keynumber = math.min(9, math.max(#tags[s], keynumber));
end
-- }}}

-- {{{ Tag controls
for i = 1, keynumber do
	globalkeys = awful.util.table.join( globalkeys,
		awful.key({ MODKEY }, "#" .. i + 9, function ()
			local screen = mouse.screen
			if tags[screen][i] then awful.tag.viewonly(tags[screen][i]) end
		end),
		awful.key({ MODKEY, "Control" }, "#" .. i + 9, function ()
			local screen = mouse.screen
			if tags[screen][i] then awful.tag.viewtoggle(tags[screen][i]) end
		end),
		awful.key({ MODKEY, "Shift" }, "#" .. i + 9, function ()
			if client.focus and tags[client.focus.screen][i] then
			    awful.client.movetotag(tags[client.focus.screen][i])
			end
		end),
		awful.key({ MODKEY, "Control", "Shift" }, "#" .. i + 9, function ()
			if client.focus and tags[client.focus.screen][i] then
			    awful.client.toggletag(tags[client.focus.screen][i])
			end
		end))
end
-- }}}

-- Set keys
root.keys(globalkeys)
-- }}}


-- {{{ Rules
awful.rules.rules = {
	{ rule = { }, properties = {
		focus = true,
		size_hints_honor = false,
		keys = clientkeys,
		buttons = clientbuttons,
		border_width = beautiful.border_width,
		border_color = beautiful.border_normal
	}},
	--{ rule = { class = "Firefox",  instance = "Navigator" }, properties = { tag = tags[screen.count()][3] } },
	{ rule = { class = "Xmessage", instance = "xmessage" }, properties = { floating = true }, callback = awful.titlebar.add  },
	{ rule = { instance = "firefox-bin" }, properties = { floating = true }, callback = awful.titlebar.add  },
	{ rule = { name  = "Alpine" },      properties = { tag = tags[1][4]} },
	{ rule = { class = "Ark" },         properties = { floating = true } },
	{ rule = { class = "Geeqie" },      properties = { floating = true } },
	{ rule = { class = "ROX-Filer" },   properties = { floating = true } },
	{ rule = { class = "Pinentry.*" },  properties = { floating = true } },
}
-- }}}


-- {{{ Signals
--
-- {{{ Manage signal handler
client.add_signal("manage", function (c, startup)
	-- Add titlebar to floaters, but remove those from rule callback
	if awful.client.floating.get(c)
	or awful.layout.get(c.screen) == awful.layout.suit.floating then
		if   c.titlebar then awful.titlebar.remove(c)
		else awful.titlebar.add(c, {MODKEY = MODKEY}) end
	end

	-- Enable sloppy focus
	c:add_signal("mouse::enter", function (c)
		if  awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
		and awful.client.focus.filter(c) then
			client.focus = c
		end
	end)

	-- Client placement
	if not startup then
		awful.client.setslave(c)
		if  not c.size_hints.program_position
		and not c.size_hints.user_position then
			awful.placement.no_overlap(c)
			awful.placement.no_offscreen(c)
		end
	end
end)
-- }}}

-- {{{ Focus signal handlers
client.add_signal("focus",   function (c) c.border_color = beautiful.border_focus  end)
client.add_signal("unfocus", function (c) c.border_color = beautiful.border_normal end)
-- }}}

-- {{{ Arrange signal handler
for s = 1, screen.count() do
	screen[s]:add_signal("arrange", function ()
		local clients = awful.client.visible(s)
		local layout = awful.layout.getname(awful.layout.get(s))
		for _, c in pairs(clients) do
			-- Floaters are always on top
			if   awful.client.floating.get(c) or layout == "floating"
			then if not c.fullscreen then c.above       =  true  end
			else                          c.above       =  false end
		end
	end)
end
-- }}}
-- }}}
