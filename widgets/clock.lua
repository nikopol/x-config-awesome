local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local beautiful = require("beautiful")

clock_widget = wibox.widget.textclock(CLOCK_FMT)

local clock_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_date
}

local clock_layout = wibox.widget {
    wibox.container.place(clock_icon, "center", "center"),
    wibox.container.margin(clock_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    layout = wibox.layout.fixed.horizontal,
}

local clock_tooltip = awful.tooltip {
    objects        = { clock_layout },
    timeout        = 1,
    timer_function = function()
      sh = io.popen("cal -3")
      out = sh:read("*a")
      sh:close()
      return (
         "<span color=\""..beautiful.fg_normal.."\">"..out:match("^([^\n]+\n[^\n]+)").."</span>\n"..
         out:gsub("^([^\n]+\n[^\n]+\n)",""):gsub("\n$","")
      )
   end
}

return clock_layout
