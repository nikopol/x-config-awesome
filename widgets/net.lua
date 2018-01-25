local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local beautiful = require("beautiful")
--local naughty = require("naughty")

local netdn_graph = wibox.widget {
    max_value = 100,
    color = beautiful.fg_netdn_widget,
    background_color = beautiful.fg_off_widget,
    forced_width = 25,
    scale = true,
    --step_width = 2,
    --step_spacing = 1,
    widget = wibox.widget.graph
}

local netdn_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_netdn
}

local netdn_text = wibox.widget {
    text         = "?",
    align        = "left",
    valign       = "center",
    forced_width = 50,
    widget = wibox.widget.textbox,
}

local netup_graph = wibox.widget {
    max_value = 100,
    color = beautiful.fg_netup_widget,
    background_color = beautiful.fg_off_widget,
    forced_width = 25,
    scale = true,
    --step_width = 2,
    --step_spacing = 1,
    widget = wibox.widget.graph
}

local netup_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image  = beautiful.widget_netup
}

local netup_text = wibox.widget {
    text         = "?",
    align        = "right",
    valign       = "center",
    forced_width = 50,
    widget = wibox.widget.textbox,
}

function netfmt(o)
    local s = ""
    if     o == nil  then s = "n/a"
    elseif o == 0    then s = "0"
    elseif o < 10240 then s = tostring(math.floor(o / 102.4) / 10)
    else                  s = tostring(math.floor(o / 1024))
    end
    return s
end

local nets = {}
function netinfo(name)
    local info = {}
    -- Get NET stats
    for line in io.lines("/proc/net/dev") do
        -- Match wmaster0 as well as rt0 (multiple leading spaces)
        local name = string.match(line, "^%s*(%w+):")
        if name ~= nil then
            local net = {
                recv = tonumber(string.match(line, ":%s*(%d+)")),
                send = tonumber(string.match(line, "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+$")),
                time = os.time()
            }
            if nets[name] == nil then
                nets[name] = net
            else
                local interval = net.time - nets[name].time
                if interval >= 1 then
                    net.down = (net.recv - nets[name].recv) / interval
                    net.up   = (net.send - nets[name].send) / interval
                    nets[name] = net
                end
            end
        end
    end
    return nets
end

gears.timer {
    timeout = 2,
    autostart = true,
    callback = function ()
        local net = netinfo()[NET_INTERFACE]
        if net.down ~= nil then
            netdn_graph:add_value(net.down)
            netdn_text:set_text(netfmt(net.down))
            netup_graph:add_value(net.up)
            netup_text:set_text(netfmt(net.up))
        end
    end
}

local netdn_graph_widget = wibox.container.mirror(netdn_graph, { horizontal = true })
local netup_graph_widget = wibox.container.mirror(netup_graph, { horizontal = true })

local net_layout  = wibox.widget {
    wibox.container.place(netdn_icon, "center", "center"),
    wibox.container.margin(netdn_text, beautiful.widget_margin, beautiful.widget_margin, 0, 0),
    wibox.container.margin(netdn_graph_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    wibox.container.margin(netup_graph_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    wibox.container.margin(netup_text, beautiful.widget_margin, beautiful.widget_margin, 0, 0),
    wibox.container.place(netup_icon, "center", "center"),
    layout = wibox.layout.fixed.horizontal,
}


return net_layout