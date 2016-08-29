-- Caffeine
-- https://github.com/cmsj/hammerspoon-config/blob/master/init.lua
-- http://jimmygreen.deviantart.com/art/Retina-Caffeine-menubar-icons-350451587

local caffeine = hs.menubar.new()

function setCaffeineDisplay(state)
    local icon = "caffeinIcon"
    if state then
        icon = icon .. "Active"
    end
    caffeine:setIcon("assets/" .. icon .. ".tiff")
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

return {
    init = nil
}
