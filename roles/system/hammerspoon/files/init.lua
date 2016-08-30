-- Hammerspoon configuration
-- https://github.com/tstirrat/hammerspoon-config/blob/master/init.lua
-- https://github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/window.lua
-- https://github.com/szymonkaliski/Dotfiles/blob/master/Dotfiles/hammerspoon/init.lua

-- Settings
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.consoleOnTop(true)
hs.dockIcon(false)
hs.menuIcon(false)
hs.window.animationDuration = 0.05

-- Hints
-- hs.hints.fontName = Helvetica
-- hs.hints.fontSize = 16
-- hs.hints.showTitleThresh = 10
hs.hints.style = "vimperator"

-- local hostname = hs.host.localizedName()

import = require("utils/import")
import.clear_cache()

-- Binding modifiers
alt = {"cmd", "alt"}
mash = {"cmd", "ctrl"}
super = {"cmd", "alt", "ctrl"}
hyper = {"shift", "cmd", "alt", "ctrl"}

config = import("config")
-- local log = hs.logger.new('init','debug')

function config:get(key_path, default)
    local root = self
    for part in string.gmatch(key_path, "[^\\.]+") do
        root = root[part]
        if root == nil then
            return default
        end
    end
    return root
end

local modules = {}

-- for _, v in ipairs(config.modules) do end
hs.fnutils.each(config.modules, function(module_name)
    local module_path = "modules/" .. module_name
    local module = import(module_path)

    if type(module.init) == "function" then
        module.init()
    elseif type(module.init) ~= "nil" then
        hs.alert.show("Unknown init type: " .. type(module.bind))
    end

    if type(module.bind) == "function" then
        module.bind()
    elseif type(module.bind) == "table" then
        hs.fnutils.each(module.bind, function(binding)
            -- if type(binding.fn) == "string" then
            --     binding.fn = _G[binding.fn]
            -- end
            table.insert(config.bindings, binding)
        end)
    elseif type(module.bind) ~= "nil" then
        hs.alert.show("Unknown bind type: " .. type(module.bind))
    end

    table.insert(modules, module)
end)

-- Apply key bindings
hs.fnutils.each(config.bindings, function (bind)
    hs.hotkey.bind(bind.mods, bind.key, bind.fn)
end)

local buf = {}

if hs.wasLoaded == nil then
    hs.wasLoaded = true
    table.insert(buf, "loaded: ")
else
    table.insert(buf, "reloaded: ")
end

table.insert(buf, #modules .. " modules")

hs.alert.show("Hammerspoon " .. table.concat(buf))
