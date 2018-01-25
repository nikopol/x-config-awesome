local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local spawn = require("awful.spawn")
local beautiful = require("beautiful")
--local naughty = require("naughty")

local vol_graph = wibox.widget {
    max_value        = 100,
    value            = 0,
    ticks            = true,
    ticks_size       = 2,
    color            = beautiful.vgradient,
    background_color = beautiful.fg_off_widget,
    widget           = wibox.widget.progressbar,
}

local vol_text = wibox.widget {
    text  = '?',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox,
}

local update_vol = function(widget, stdout, _, _, _)
    local muted = string.match(stdout, "%[(o[fn]+)%]") == "off"
    local volume = string.match(stdout, "(%d+)%%")
    widget.value = tonumber(volume);
    if muted then vol_text.text = "--%"
    else          vol_text.text = volume.."%"
    end
end


watch(GET_VOLUME_CMD, 3, update_vol, vol_graph)

local vol_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_vol
}

local vol_widget = wibox.widget {
    vol_graph,
    forced_width = 8,
    direction    = 'east',
    layout       = wibox.container.rotate,
}

local vol_layout = wibox.widget {
    wibox.container.place(vol_icon, "center", "center"),
    wibox.container.margin(vol_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    wibox.container.margin(vol_text, beautiful.widget_margin, 0, 0, 0),
    layout = wibox.layout.fixed.horizontal,
}

vol_layout:connect_signal("button::press", function(_, _, _, button)
    if (button == 4) then awful.spawn(INC_VOLUME_CMD, false)
    elseif (button == 5) then awful.spawn(DEC_VOLUME_CMD, false)
    elseif (button == 1) then awful.spawn(TOG_VOLUME_CMD, false)
    end
    spawn.easy_async(GET_VOLUME_CMD, function(stdout, stderr, exitreason, exitcode)
        update_vol(vol_graph, stdout, stderr, exitreason, exitcode)
    end)
end)

return vol_layout
