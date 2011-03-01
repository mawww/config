require("awful")
require("vicious")
require("mawww.notmuch")

local awful = awful
local vicious = vicious
local widget = widget
local image = image
local notmuch = mawww.notmuch

module("mawww.widgets")

local function icon(name)
    local iconwidget = widget({ type = "imagebox" })
    iconwidget.image = image("/home/mawww/misc/icons/open_icon_library-standard/icons/png/32x32/" .. name)
    return iconwidget
end

-- vicious widgets
local cpuicon = icon("devices/cpu.png")
local cpuwidget = awful.widget.graph()
cpuwidget:set_width(50)
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

local memicon = icon("devices/memory.png")
local memwidget = awful.widget.progressbar()
memwidget:set_vertical(true)
memwidget:set_width(6)
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)

local volicon = icon("devices/audio-card-2.png")
local volwidget = awful.widget.progressbar()
volwidget:set_vertical(true)
volwidget:set_width(6)
vicious.register(volwidget, vicious.widgets.volume, "$1", 2, "PCM")

local baticon = icon("devices/battery.png")
local batwidget = awful.widget.progressbar()
batwidget:set_vertical(true)
batwidget:set_width(6)
vicious.register(batwidget, vicious.widgets.bat, "$2", 61, "BAT0")

local mailicon = icon("emblems/emblem-mail.png")
local mailwidget = widget({ type = "textbox" })
mailwidget.text="inbox: ??"
vicious.register(mailwidget, notmuch, "inbox: $1", 31, { "inbox" })

systraywidget = widget({ type = "systray" })

clockwidget = awful.widget.textclock({ align = "right" })

local wibox = awful.wibox({ position = "bottom" })
wibox.widgets = {
    cpuicon,
    cpuwidget,
    memicon,
    memwidget,
    volicon,
    volwidget,
    baticon,
    batwidget,
    mailicon,
    mailwidget,
    layout = awful.widget.layout.horizontal.leftright,
    {
        clockwidget,
        systraywidget,
        layout = awful.widget.layout.horizontal.rightleft,
    },
}

