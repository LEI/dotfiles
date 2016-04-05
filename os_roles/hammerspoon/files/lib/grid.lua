-- Grid

if hs.keycodes.currentLayout() == "French" then
    hs.grid.HINTS = {
        { "f1", "f2", "f3", "f4", "f5", "f6", "f7", "f8", "f9", "f10" },
        { "&", "é", '"', "'", "(", "§", "è", "!", "ç", "à" },
        -- { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" },
        { "A", "Z", "E", "R", "T", "Y", "U", "I", "O", "P" },
        { "Q", "S", "D", "F", "G", "H", "J", "K", "L", "M" },
        { "W", "X", "C", "V", "B", "N", ",", ";", ":", "=" },
    }
end

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
hs.grid.ui.fontName = 'Lucida Grande'

-- Booleans
-- Show non-grid keybindings in the center of the grid
hs.grid.ui.showExtraKeys = true
