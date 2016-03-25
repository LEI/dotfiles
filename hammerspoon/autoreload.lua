-- Automatic configuration reloading

function endsWith(file, str)
    return #file > 0 and file:sub(-4) == str and true or false
end

function luaFileChanged(files)
    for _, file in pairs(files) do
        if endsWith(file, ".lua") then
            return true
        end
    end

    return false
end

function reloadConfig(files)
    if luaFileChanged(files) then
        hs.reload()
    end
end

-- os.getenv("HOME") .. "/.hammerspoon/"
cfgWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
cfgWatcher:start()
