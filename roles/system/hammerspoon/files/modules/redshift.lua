-- Location base Redshift
-- github.com/heptal/dotfiles/blob/master/roles/hammerspoon/files/redshift.lua

-- make a windowfilterDisable for redshift: VLC, Photos and screensaver/login window will disable color adjustment and inversion
--local wfRedshift=hs.window.filter.new({VLC={focused=true},Photos={focused=true},loginwindow={visible=true,allowRoles='*'}},'wf-redshift')
-- start redshift: 2800K + inverted from 21 to 7, very long transition duration (19->23 and 5->9)
--hs.redshift.start(2800,'21:00','7:00','4h',true,wfRedshift)
-- allow manual control of inverted colors
--hs.hotkey.bind(HYPER,'f1','Invert',hs.redshift.toggleInvert)

hs.location.start()

hs.timer.doAfter(1, function()
    local loc = hs.location.get()
    hs.location.stop()

    local times = {sunrise = "07:00", sunset = "20:00"}

    if loc then
        local tzOffset = tonumber(string.sub(os.date("%z"), 1, -3))
        for i, v in pairs({"sunrise", "sunset"}) do
            times[v] = os.date("%H:%M", hs.location[v](loc.latitude, loc.longitude, tzOffset))
        end
    end

    hs.redshift.start(3600, times.sunset, times.sunrise)
end)

return {
    init = nil
}
