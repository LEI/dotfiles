-- Hammerspoon configuration

hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.consoleOnTop(true)
hs.dockIcon(false)
hs.menuIcon(false)

-- General

hs.window.animationDuration = 0

-- local hostname = hs.host.localizedName()

-- Core
require "lib/utils"
require "lib/autoreload"
require "lib/window"
require "lib/layout"
require "lib/grid"

-- Menubar
require "lib/caffeine"
require "lib/volumes" -- image:setSize!

-- Applications
require "lib/redshift"

-- Bindings
-- github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/window.lua
mash = {"cmd", "ctrl"}
super = {"cmd", "alt", "ctrl"}
hyper = {"shift", "cmd", "alt", "ctrl"}

-- Hints
-- hs.hints.fontSize = 16
-- hs.hints.showTitleThresh = 10
hs.hints.style = "vimperator"
hs.hotkey.bind(mash, ",", hs.hints.windowHints)

hs.hotkey.bind(mash, "R", hs.reload)
hs.hotkey.bind(mash, "C", hs.toggleConsole)

-- Lock
-- hs.hotkey.bind(hyper, "L", hs.caffeinate.startScreensaver)

hs.hotkey.bind(mash, "G", hs.grid.toggleShow)

-- Bring all Finder windows forward when one gets activated (desktop is a finder)
--[[function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end

local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()--]]

-- Maximize focused window
hs.hotkey.bind(mash, "M", function()
    local win = focusedWin()
    win:toggleMaximize()
end)

-- Window resizing using vim movement keys
--      k
--  h       l
--      j

-- github.com/rtoshiro/hammerspoon-init/blob/master/init.lua

-- Top half
hs.hotkey.bind(mash, "K", function()
    local win = focusedWin()
    win:up()
end)

-- Right half
hs.hotkey.bind(mash, "L", function()
    local win = focusedWin()
    win:right()
end)

-- Bottom half
hs.hotkey.bind(mash, "J", function()
    local win = focusedWin()
    win:down()
end)

-- Left half
hs.hotkey.bind(mash, "H", function()
    local win = focusedWin()
    win:left()
end)

-- Top right corner
hs.hotkey.bind(super, "K", function()
    local win = focusedWin()
    win:upRight()
end)

-- Bottom right corner
hs.hotkey.bind(super, "L", function()
    local win = focusedWin()
    win:downRight()
end)

-- Bottom left corner
hs.hotkey.bind(super, "J", function()
    local win = focusedWin()
    win:downLeft()
end)

-- Top left corner
hs.hotkey.bind(super, "H", function()
    local win = focusedWin()
    win:upLeft()
end)

-- Window movements using nethack movement keys
--  y   k   u
--  h       l
--  b   j   n

local moveStep = 10

hs.hotkey.bind(hyper, "Y", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x - moveStep
    f.y = f.y - moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "K", function()
    local win = focusedWin()
    local f = win:frame()

    f.y = f.y - moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "U", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x + moveStep
    f.y = f.y - moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "H", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x - moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "L", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x + moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "B", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x - moveStep
    f.y = f.y + moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "J", function()
    local win = focusedWin()
    local f = win:frame()

    f.y = f.y + moveStep
    win:setFrame(f)
end)

hs.hotkey.bind(hyper, "N", function()
    local win = focusedWin()
    local f = win:frame()

    f.x = f.x + moveStep
    f.y = f.y + moveStep
    win:setFrame(f)
end)

-- Window navigation

hs.hotkey.bind(super, "Up", hs.window.focusWindowNorth)
hs.hotkey.bind(super, "Right", hs.window.focusWindowEast)
hs.hotkey.bind(super, "Down", hs.window.focusWindowSouth)
hs.hotkey.bind(super, "Left", hs.window.focusWindowWest)

-- FIXME: attempt to index a nil value (local 'self')
-- hs.hotkey.bind(hyper, "Up", hs.window.moveOneScreenNorth)
-- hs.hotkey.bind(hyper, "Right", hs.window.moveOneScreenEast)
-- hs.hotkey.bind(hyper, "Down", hs.window.moveOneScreenSouth)
-- hs.hotkey.bind(hyper, "Left", hs.window.moveOneScreenWest)

local msg = {""}
local wasLoaded = #hs.console.getHistory()

if wasLoaded == 0 then
    -- Add an empty command in the history
    hs.console.setHistory({""})
    table.insert(msg, "Loaded")
else
    table.insert(msg, "Re-loaded")
end

hs.alert(table.concat(msg))
