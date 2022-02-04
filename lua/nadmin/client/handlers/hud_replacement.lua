if CLIENT then
    local hide = {
        ["CHudBattery"] = true,
        ["CHudHealth"] = true,
        ["CHudAmmo"] = true,
        ["CHudSecondaryAmmo"] = true
    }
    hook.Add("HUDShouldDraw", "nadmin_hide_default_hud", function(name)
        if not IsValid(LocalPlayer()) then return end
        if nadmin.plugins.hud and nadmin.clientData.useCustomHud then
            if hide[name] then return false end
            nadmin.hud:Show(false)
        else
            nadmin.hud:Hide()
        end
    end)
end
