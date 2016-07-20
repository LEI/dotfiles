-- Manage removable volumes
-- https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/volumes.lua

-- local std = require "hs.stdlib"
keys = import("utils/keys")

local volumes = {}
local fmt = string.format
-- local keys = std.table.keys

local humanSize = function(bytes)
    local units = {'bytes', 'kb', 'MB', 'GB', 'TB', 'PB'}
    local power = math.floor(math.log(bytes)/math.log(1000))
    return string.format("%.3f "..units[power + 1], bytes/(1000^power))
end

local volumesMenu = function(eventType, info)
    local entries = {{title = "Disk Utility", fn = function() hs.application.launchOrFocus("Disk Utility") end}, {title = "-"}}
    local removableVolumes = hs.fnutils.filter(hs.fs.volume.allVolumes(), function(v) return v.NSURLVolumeIsRemovableKey end)
    if #keys(removableVolumes) > 0 then volumes.menu:returnToMenuBar() else volumes.menu:removeFromMenuBar() return end

    hs.fnutils.each(keys(removableVolumes), function(path)
        local name = path:match("^/Volumes/(.*)")
        local size = humanSize(removableVolumes[path].NSURLVolumeTotalCapacityKey)
        table.insert(entries, {title = fmt("%s (%s)", name, size), fn = function() hs.execute(fmt("open %q",path)) end})
        table.insert(entries, {title = "⏏ Eject", indent = 1, fn = function() hs.fs.volume.eject(path) end})
    end)

    return entries
end

local diskIconPath = "/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/SidebarRemovableDisk.icns"
local diskImage = hs.image.imageFromPath(diskIconPath)

-- https://github.com/Hammerspoon/hammerspoon/issues/815
volumes.menu = hs.menubar.new():setMenu(volumesMenu)
-- volumes.menu:setTitle("⏏")
-- volumes.menu = hs.menubar.new():setMenu(volumesMenu):setIcon(diskImage:setSize({w=16,h=16}))
volumes.menu:setIcon(diskImage:setSize({w=16,h=16}))

volumes.watcher = hs.fs.volume.new(volumesMenu):start()
volumesMenu()

-- return volumes
return {
    init = nil
}
