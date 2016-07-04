-- Key bindings

local function bindKeys(map)
    hs.fnutils.each(map, function (bind)
        hs.hotkey.bind(bind.mods, bind.key, bind.fn)
    end)
end

return {
    init = function()
        bindKeys(config.bindings)
    end
}
