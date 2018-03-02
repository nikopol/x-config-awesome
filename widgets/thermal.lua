local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tools = require("widgets.tools")

local thermal_text = wibox.widget {
    text   = '?',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
}

local thermal_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_temp
}

function thermalinfo()
    local temp = "-"
    local val = tools.readnum(THERMAL_SRC)
    if val ~= nil then
        temp = math.floor(val / 100) / 10
    end
    return temp.."°"
end

gears.timer {
    timeout = 2,
    autostart = true,
    callback = function ()
        thermal_text:set_text(thermalinfo())
    end
}

local thermal_layout = wibox.widget {
    wibox.container.place(thermal_icon, "center", "center"),
    wibox.container.margin(thermal_text, beautiful.widget_margin, beautiful.widget_margin, 0, 0),
    layout = wibox.layout.fixed.horizontal,
}

return thermal_layout
