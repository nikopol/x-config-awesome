local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local beautiful = require("beautiful")

local ram_graph = wibox.widget {
    max_value        = 100,
    value            = 0,
    ticks            = true,
    ticks_size       = 2,
    color            = beautiful.vgradient,
    background_color = beautiful.fg_off_widget,
    widget           = wibox.widget.progressbar,
}

local ram_text = wibox.widget {
    text  = "?",
    align = "center",
    valign = "center",
    widget = wibox.widget.textbox,
}


function memfmt(o)
    local s = ""
    if     o == nil       then s = "n/a"
    elseif o == 0         then s = "none"
    elseif o < 1024       then s = math.floor(o).."B"
    elseif o < 1048576    then s = math.floor(o / 1024).."k"
    elseif o < 1073741824 then s = math.floor(o / 1048576).."M"
    else                       s = (math.floor(o / 107374182.4)/10).."G"
    end
    return s
end

local mem = { buf = {}, swap = {} }
function meminfo()
    for line in io.lines("/proc/meminfo") do
        for k, v in string.gmatch(line, "([%a]+):[%s]+([%d]+).+") do
            if     k == "MemTotal"  then mem.total = v * 1024
            elseif k == "MemFree"   then mem.buf.f = v * 1024
            elseif k == "Buffers"   then mem.buf.b = v * 1024
            elseif k == "Cached"    then mem.buf.c = v * 1024
            elseif k == "SwapTotal" then mem.swap.total = v * 1024
            elseif k == "SwapFree"  then mem.swap.free = v * 1024
            end
        end
    end
    mem.free = mem.buf.f + mem.buf.b + mem.buf.c
    mem.used = mem.total - mem.free
    mem.usep = math.floor(mem.used / mem.total * 100)
    mem.swap.used = mem.swap.total - mem.swap.free
    return mem
end

gears.timer {
    timeout = 2,
    autostart = true,
    callback = function ()
        meminfo()
        ram_graph:set_value(mem.usep)
        ram_text:set_text(memfmt(mem.free))
    end
}

local ram_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widgetmem
}

local ram_widget = wibox.widget {
    ram_graph,
    forced_width = 8,
    direction    = 'east',
    layout       = wibox.container.rotate,
}

local ram_layout = wibox.widget {
    wibox.container.place(ram_icon, "center", "center"),
    wibox.container.margin(ram_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    wibox.container.margin(ram_text, beautiful.widget_margin, 0, 0, 0),
    layout = wibox.layout.fixed.horizontal,
}

local ram_tooltip = awful.tooltip {
    objects        = { ram_layout },
    timeout        = 1,
    timer_function = function ()
      return (
         "<span color=\""..beautiful.fg_normal.."\"> Free:</span> "..memfmt(mem.free).."\n"..
         "<span color=\""..beautiful.fg_normal.."\"> Used:</span> "..memfmt(mem.used).."\n"..
         "<span color=\""..beautiful.fg_normal.."\">Total:</span> "..memfmt(mem.total).."\n"..
         "<span color=\""..beautiful.fg_normal.."\"> Swap:</span> "..memfmt(mem.swap.used)
      )
   end
}

return ram_layout
