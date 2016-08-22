-- Grid

local margins = {w=0,h=0}
hs.grid.setMargins(margins)

-- Modal resizing UI

-- Color values {redN,greenN,blueN[,alphaN]}
hs.grid.ui.textColor = {1,1,1}
hs.grid.ui.cellColor = {0,0,0,0.25}
hs.grid.ui.cellStrokeColor = {0,0,0}
-- For the first selected cell during a modal resize
hs.grid.ui.selectedColor = {0.2,0.7,0,0.4}
-- To highlight the frontmost window behind the grid
hs.grid.ui.highlightColor = {0.8,0.8,0,0.5}
hs.grid.ui.highlightStrokeColor = {0.8,0.8,0,1}
-- To highlight the window to be resized, when cycling among windows
hs.grid.ui.cyclingHighlightColor = {0,0.8,0.8,0.5}
hs.grid.ui.cyclingHighlightStrokeColor = {0,0.8,0.8,1}

-- Numbers (screen points)
hs.grid.ui.textSize = 80 -- default: 200
hs.grid.ui.cellStrokeWidth = 5
hs.grid.ui.highlightStrokeWidth = 5 -- default: 30

-- Strings
hs.grid.ui.fontName = "Helvetica" -- "Lucida Grande"

-- Booleans
-- Show non-grid keybindings in the center of the grid
hs.grid.ui.showExtraKeys = true

return {
    bind = {
        -- https://github.com/Linell/hammerspoon-config/blob/master/init.lua
        -- Toggle grid
        { mods = mash, key = "G", fn = hs.grid.toggleShow },
        -- -- Left half
        -- { mods = mash, key = "H", fn = hs.grid.pushWindowLeft },
        -- -- Bottom half
        -- { mods = mash, key = "J", fn = hs.grid.pushWindowDown },
        -- -- Top half
        -- { mods = mash, key = "K", fn = hs.grid.pushWindowUp },
        -- -- Right half
        -- { mods = mash, key = "L", fn = hs.grid.pushWindowRight },
    },
    init = function()
        -- Grid size
        hs.grid.setGrid(config.grid.geometry, config.grid.screen, config.grid.frame)
        -- Hint layout
        for name,layout in pairs(config.grid.hints) do
            if string.find(hs.keycodes.currentLayout(), name) then
                hs.grid.HINTS = layout
            end
        end
    end
}
