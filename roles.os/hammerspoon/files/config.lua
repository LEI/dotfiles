-- https://github.com/tstirrat/hammerspoon-config/blob/master/config.example.lua

local config = {}

config.modules = {
    "utils",
    "bindings",
    "application",
    "reload",
    "window",
    "layout",
    "grid",
    -- Menubar
    "caffeine",
    "volumes",
    -- Applications
    "redshift",
}

local moveStep = 10

config.bindings = {
    { mods = mash, key = "R", fn = hs.reload },
    { mods = mash, key = ",", fn = hs.hints.windowHints },
    { mods = mash, key = "G", fn = hs.grid.toggleShow },

    -- Lock
    -- hs.hotkey.bind(hyper, "L", hs.caffeinate.startScreensaver

    -- Console
    -- hs.hotkey.bind(mash, "C", hs.toggleConsole)
    { mods = super, key = "C", fn = hs.toggleConsole },

    -- Color picker
    { mods = mash, key = "C", fn = function()
        hs.osascript.applescript("choose color")
    end },

    -- Force paste
    { mods = alt, key = "V", fn = function()
        hs.eventtap.keyStrokes(hs.pasteboard.getContents())
    end },

    -- Maximize focused window
    { mods = mash, key = "M", fn = function()
        local win = focusedWin()
        win:toggleMaximize()
    end },

    -- Window resizing using vim movement keys
    --      k
    --  h       l
    --      j

    -- github.com/rtoshiro/hammerspoon-init/blob/master/init.lua

    -- Top half
    { mods = mash, key = "K", fn = function()
        local win = focusedWin()
        win:up()
    end },

    -- Right half
    { mods = mash, key = "L", fn = function()
        local win = focusedWin()
        win:right()
    end },

    -- Bottom half
    { mods = mash, key = "J", fn = function()
        local win = focusedWin()
        win:down()
    end },

    -- Left half
    { mods = mash, key = "H", fn = function()
        local win = focusedWin()
        win:left()
    end },

    -- Top right corner
    { mods = super, key = "K", fn = function()
        local win = focusedWin()
        win:upRight()
    end },

    -- Bottom right corner
    { mods = super, key = "L", fn = function()
        local win = focusedWin()
        win:downRight()
    end },

    -- Bottom left corner
    { mods = super, key = "J", fn = function()
        local win = focusedWin()
        win:downLeft()
    end },

    -- Top left corner
    { mods = super, key = "H", fn = function()
        local win = focusedWin()
        win:upLeft()
    end },

    -- Window movements using nethack movement keys
    --  y   k   u
    --  h       l
    --  b   j   n

    { mods = hyper, key = "Y", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.x = f.x - moveStep
        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "K", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "U", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.x = f.x + moveStep
        f.y = f.y - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "H", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.x = f.x - moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "L", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.x = f.x + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "B", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.x = f.x - moveStep
        f.y = f.y + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "J", fn = function()
        local win = focusedWin()
        local f = win:frame()

        f.y = f.y + moveStep
        win:setFrame(f)
    end },

    { mods = hyper, key = "N", fn = function()
        local win = focusedWin()
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
}

config.apps = {
    -- Bring all Finder windows forward when one gets activated (desktop is a finder)
    { name = "Finder", fn = function(appObject)
        appObject:selectMenuItem({"Window", "Bring All to Front"})
    end },
}

return config
