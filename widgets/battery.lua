local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
local naughty = require("naughty")
local tools = require("widgets.tools")

local batt_text = wibox.widget {
    text   = '?',
    align  = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
}

local batt_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_bat
}

local battery_states = {
    ["Full"]        = "↯",
    ["Unknown"]     = "?",
    ["Charged"]     = "↯",
    ["Charging"]    = "+",
    ["Discharging"] = "-"
}

function battinfo()
    local bat = "-"
    local max = tools.readnum(BATTERY_SRC..'/energy_full_design')
    local cur = tools.readnum(BATTERY_SRC..'/energy_now')
    local state = battery_states[tools.readline(BATTERY_SRC..'/status')] or '?'
    if max ~= nil then
        bat = state..tostring(math.floor(100 * cur / max))..'%'
    else
        bat = state
    end
    return bat
end

gears.timer {
    timeout = 5,
    autostart = true,
    callback = function ()
        batt_text:set_text(battinfo())
    end
}

local batt_layout = wibox.widget {
    wibox.container.place(batt_icon, "center", "center"),
    wibox.container.margin(batt_text, beautiful.widget_margin, beautiful.widget_margin, 0, 0),
    layout = wibox.layout.fixed.horizontal,
}

return batt_layout
