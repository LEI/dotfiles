-- Watch the number of display and adjust window layout

hs.layout.center = {0.1, 0.1, 0.8, 0.8}

local function applyWindowLayout()
    local screens = hs.screen.allScreens()

    if #screens ~= lastCount then
        if #screens == 1 then
            screens[2] = screens[1]
        end
    end

    -- screens[2] -> attempt to index a nil value (field '?')
    local windowLayout = {
        -- {"Finder", nil, screens[1]:name(), hs.layout.center, nil, nil},
        {"Terminal", nil, screens[1]:name(), nil, nil, screens[1]:fullFrame()},
        {"Google Chrome", nil, screens[2]:name(), hs.layout.maximized, nil, nil},
        {"Google Chrome", "Postman", screens[2]:name(), hs.layout.center, nil, nil},
        {"Firefox", nil, screens[2]:name(), hs.layout.maximized, nil, nil},
        {"Sequel Pro", nil, screens[2]:name(), hs.layout.center, nil, nil},
        {"Skype", nil, screens[2]:name(), hs.layout.left50, nil, nil },
        {"Mail", nil, screens[2]:name(), hs.layout.right50, nil, nil },
        {"Slack", nil, screens[2]:name(), hs.layout.center, nil, nil },
    }

    hs.layout.apply(windowLayout)
    lastCount = #screens
end

--[[function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Terminal") then
            local win = appObject:focusedWindow()
            if win ~= nil then -- & isFullScreen?
                win:setFullScreen(true)
            end
        end
    end
end

local appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()--]]

return {
    init = function()
        local screenWatcher = hs.screen.watcher.new(applyWindowLayout)
        screenWatcher:start()

        applyWindowLayout()
    end
}
