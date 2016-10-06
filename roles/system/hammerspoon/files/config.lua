-- https://github.com/tstirrat/hammerspoon-config/blob/master/config.example.lua

local config = {}

config.modules = {
    -- Applications
    "application",
    "redshift",
    "caffeine",
    "volumes",
    -- Extensions
    "window",
    -- Settings
    "reload",
    "layout",
    "grid",
}

config.apps = {
    -- -- Bring all Finder windows forward when one gets activated (desktop is a finder)
    -- { name = "Finder", fn = function(appObject)
    --     appObject:selectMenuItem({"Window", "Bring All to Front"})
    -- end },
}

config.grid = {
    geometry = "4x4",
    hints = {
        French = {
            { "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10" },
            { "&", "é", '"', "'", "(", "§", "è", "!", "ç", "à" },
            { "A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P" },
            { "Q", "S", "D", "F", "G", "H", "J", "K", "L", "M" },
            { "W", "X", "C", "V", "B", "N", ",", ";", ":", "=" },
        },
    },
}

local moveStep = 10
config.bindings = {
    -- { mods = mash, key = "R", fn = hs.reload },
    -- { mods = mash, key = "G", fn = hs.grid.toggleShow },
    { mods = mash, key = ",", fn = hs.hints.windowHints },

    -- Lock
    -- hs.hotkey.bind(hyper, "L", hs.caffeinate.startScreensaver

    -- Console
    { mods = mash, key = "C", fn = hs.toggleConsole },

    -- Color picker
    { mods = super, key = "C", fn = function()
        hs.osascript.applescript("choose color")
    end },

    -- Force paste
    { mods = alt, key = "V", fn = function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
    end },

    -- local win = hs.window.focusedWindow()
    -- win:toggleMaximize()

    -- Window resizing using vim movement keys
    --      k
    --  h       l
    --      j

    -- https://github.com/rtoshiro/hammerspoon-init/blob/master/init.lua

    -- Top half
    { mods = mash, key = "K", fn = function()
        local win = hs.window.focusedWindow()
        win:up()
    end },

    -- Right half
    { mods = mash, key = "L", fn = function()
        local win = hs.window.focusedWindow()
        win:right()
    end },

    -- Bottom half
    { mods = mash, key = "J", fn = function()
        local win = hs.window.focusedWindow()
        win:down()
    end },

    -- Left half
    { mods = mash, key = "H", fn = function()
        local win = hs.window.focusedWindow()
        win:left()
    end },

    -- Top right corner
    { mods = super, key = "K", fn = function()
        local win = hs.window.focusedWindow()
        win:upRight()
    end },

    -- Bottom right corner
    { mods = super, key = "L", fn = function()
        local win = hs.window.focusedWindow()
        win:downRight()
    end },

    -- Bottom left corner
    { mods = super, key = "J", fn = function()
        local win = hs.window.focusedWindow()
        win:downLeft()
    end },

    -- Top left corner
    { mods = super, key = "H", fn = function()
        local win = hs.window.focusedWindow()
        win:upLeft()
    end },

    -- Window movements using nethack movement keys
    --  y   k   u
    --  h       l
    --  b   j   n

    { mods = hyper, key = "Y", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x - moveStep
        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "K", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "U", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x + moveStep
        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "H", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "L", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "B", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x - moveStep
        f.y = f.y + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "J", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.y = f.y + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "N", fn = function()
        local win = hs.window.focusedWindow()
        local f = win:frame()

        f.x = f.x + moveStep
        f.y = f.y + moveStep
        win:setFrame(f)
    end },

    -- Window navigation

    { mods = super, key = "Up", fn = hs.window.focusWindowNorth },
    { mods = super, key = "Right", fn = hs.window.focusWindowEast },
    { mods = super, key = "Down", fn = hs.window.focusWindowSouth },
    { mods = super, key = "Left", fn = hs.window.focusWindowWest },

    -- FIXME: attempt to index a nil value (local 'self')
    -- hs.hotkey.bind(hyper, "Up", hs.window.moveOneScreenNorth)
    -- hs.hotkey.bind(hyper, "Right", hs.window.moveOneScreenEast)
    -- hs.hotkey.bind(hyper, "Down", hs.window.moveOneScreenSouth)
    -- hs.hotkey.bind(hyper, "Left", hs.window.moveOneScreenWest)

    { mods = mash, key = "T", fn = function()
        hs.applescript.applescript([[
            tell application "System Preferences"
                activate
            end tell

            tell application "System Events" to tell process "System Preferences"
                delay 2
                click menu item "General" of menu "View" of menu bar 1
                delay 1
                # click checkbox 1 of window 1
                click checkbox "Use dark menu bar and Dock" of group 1
                # if value of checkbox "Use dark menu bar and Dock" of group 1 of tab group 1 is 0 then
                #    click checkbox "Use dark menu bar and Dock" of group 1 of tab group 1
                # end if
                # click checkbox 1 of row 1 of table 1 of scroll area 1 of group 1
            end tell

            # tell application "System Preferences"
            #     quit
            # end tell
        ]])
    end },
}

return config
