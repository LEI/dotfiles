-- Automatic configuration reloading
-- https://github.com/tstirrat/hammerspoon-config/blob/master/modules/auto_reload.lua

local function endsWith(file, str)
    return #file > 0 and file:sub(-4) == str and true or false
end

local function luaFileChanged(files)
    for _, file in pairs(files) do
        if endsWith(file, ".lua") then
            return true
        end
    end

    return false
end

local function reloadConfig(files)
    if luaFileChanged(files) then
        hs.reload()
    end
end

return {
    bind = {
        { mods = mash, key = "R", fn = hs.reload },
    },
    init = function()
        -- os.getenv("HOME") .. "/.hammerspoon/"
        cfgWatcher = hs.pathwatcher.new(hs.configdir, reloadConfig)
        cfgWatcher:start()
    end
}
