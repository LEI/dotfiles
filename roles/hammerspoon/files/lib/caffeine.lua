-- Caffeine
-- github.com/cmsj/hammerspoon-config/blob/master/init.lua

local caffeine = hs.menubar.new()

function setCaffeineDisplay(state)
    local result
    if state then
        caffeine:setIcon("img/caffeine-on.pdf")
    else
        caffeine:setIcon("img/caffeine-off.pdf")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end
