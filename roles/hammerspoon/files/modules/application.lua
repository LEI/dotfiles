-- Application

local function watch(name, fn)
    return function(appName, eventType, appObject)
        if (eventType == hs.application.watcher.activated) then
            if (appName == name) then
                fn(appObject)
            end
        end
    end
end

return {
    init = function()
        hs.fnutils.each(config.apps, function(app)
            local watcher = hs.application.watcher.new(watch(app.name, app.fn))
            watcher:start()
        end)
    end
}
