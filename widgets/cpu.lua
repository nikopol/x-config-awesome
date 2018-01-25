local wibox = require("wibox")
local awful = require("awful")
local gears = require("gears")
local beautiful = require("beautiful")
--local naughty = require("naughty")

local cpu_graph = wibox.widget {
    max_value = 100,
    color = beautiful.gradient,
    background_color = beautiful.fg_off_widget,
    forced_width = 50,
    --step_width = 2,
    --step_spacing = 1,
    widget = wibox.widget.graph
}

function cpuinfo()
    local cpu = {}
    for line in io.lines("/proc/stat") do
        if string.sub(line,1,4)=="cpu " then
            local user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice = 
                line:match('(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')
            cpu = {
                user       = user,
                nice       = nice,
                system     = system,
                idle       = idle,
                iowait     = iowait,
                irq        = irq,
                softirq    = softirq,
                steal      = steal,
                guest      = guest,
                guest_nice = guest_nice,
            }
            break
        end
    end
    return cpu
end

local total_prev = 0
local idle_prev = 0
gears.timer {
    timeout = 2,
    autostart = true,
    callback = function ()
        local cpu = cpuinfo()
        local total = cpu.user + cpu.nice + cpu.system + cpu.idle + cpu.iowait + cpu.irq + cpu.softirq + cpu.steal
        local diff_idle = cpu.idle - idle_prev
        local diff_total = total - total_prev
        local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
        cpu_graph:add_value(diff_usage)
        total_prev = total
        idle_prev = cpu.idle
    end
}

local cpu_icon = wibox.widget {
    widget = wibox.widget.imagebox,
    resize = false,
    image = beautiful.widget_cpu
}

local cpu_widget = wibox.container.mirror(cpu_graph, { horizontal = true })

local cpu_layout  = wibox.widget {
    wibox.container.place(cpu_icon, "center", "center"),
    wibox.container.margin(cpu_widget, beautiful.widget_margin, 0, beautiful.widget_margin, beautiful.widget_margin),
    layout = wibox.layout.fixed.horizontal,
}

local cpu_tooltip = awful.tooltip {
    objects = { cpu_layout },
    timeout = 1,
    timer_function = function ()
      sh = io.popen("ps -aux --cols 110 --sort=-%cpu | head -6")
      out = sh:read("*a")
      sh:close()
      return (
         "<span color=\""..beautiful.fg_normal.."\">"..out:match("^([^\n]+)").."</span>\n"..
         awful.util.escape(out:gsub("^([^\n]+)\n",""):gsub("\n$",""))
      )
   end
}

return cpu_layout