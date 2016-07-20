-- Window resizing
-- github.com/tstirrat/hammerspoon-config/blob/master/utils/position.lua

-- hs.window.setFrameCorrectness = true

function hs.window.screenFrame(win)
    return win:screen():frame() -- fullFrame()?
end

local frameCache = {}
local function toggleMaximize(win)
    -- Fix hidden windows?
    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
        -- win:setFrameInScreenBounds(win:screenFrame())
        -- if win:isFullScreen() then
        --     win:setTopLeft({x=0,y=0})
        -- else
        -- end
    end
end
hs.window.toggleMaximize = function()
    local win = hs.window.focusedWindow()
    toggleMaximize(win)
end

function hs.window.up(win)
    local f = win:screenFrame()
    f.h = f.h / 2
    win:setFrame(f)
end

function hs.window.right(win)
    local f = win:screenFrame()
    f.x = f.x + (f.w / 2)
    f.w = f.w / 2
    win:setFrame(f)
end

function hs.window.down(win)
    local f = win:screenFrame()
    f.y = f.y + (f.h / 2)
    f.h = f.h / 2
    win:setFrame(f)
end

function hs.window.left(win)
    local f = win:screenFrame()
    f.w = f.w / 2
    win:setFrame(f)
end

function hs.window.upLeft(win)
    local f = win:screenFrame()
    f.w = f.w / 2
    f.h = f.h / 2
    win:setFrame(f)
end

function hs.window.upRight(win)
    local f = win:screenFrame()
    f.x = f.x + (f.w / 2)
    f.w = f.w / 2
    f.h = f.h / 2
    win:setFrame(f)
end

function hs.window.downLeft(win)
    local f = win:screenFrame()
    f.y = f.y + (f.h / 2)
    f.w = f.w / 2
    f.h = f.h / 2
    win:setFrame(f)
end

function hs.window.downRight(win)
    local f = win:screenFrame()
    f.x = f.x + (f.w / 2)
    f.y = f.y + (f.h / 2)
    f.w = f.w / 2
    f.h = f.h / 2
    win:setFrame(f)
end

-- function hs.window.moveUpLeft(win)
--     local f = win:
-- end

return {
    bind = {
        -- Maximize focused window
        { mods = mash, key = "M", fn = hs.window.toggleMaximize },
    },
    init = function()
    end
}
