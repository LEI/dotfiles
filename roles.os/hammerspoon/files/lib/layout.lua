-- Watch the number of display and adjust window layout

hs.layout.center = {0.1, 0.1, 0.8, 0.8}

local lastCount = nil
function applyWindowLayout()
    local screens = hs.screen.allScreens()
    local count = #screens

    if count ~= lastCount then
        if count == 1 then
            screens[2] = screens[1]
        end
    end

    local windowLayout = {
        -- {"Finder", nil, screens[1]:name(), hs.layout.center, nil, nil},
        {"Terminal", nil, screens[1]:name(), nil, nil, screens[1]:fullFrame()},
        {"Google Chrome", nil, screens[2]:name(), hs.layout.maximized, nil, nil},
        {"Firefox", nil, screens[2]:name(), hs.layout.maximized, nil, nil},
        {"Sequel Pro", nil, screens[2]:name(), hs.layout.center, nil, nil},
        {"Skype", nil, screens[2]:name(), hs.layout.left50, nil, nil },
        {"Mail", nil, screens[2]:name(), hs.layout.right50, nil, nil },
    }

    hs.layout.apply(windowLayout)
    lastCount = count
end

local screenWatcher = hs.screen.watcher.new(applyWindowLayout)
screenWatcher:start()

applyWindowLayout()

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
