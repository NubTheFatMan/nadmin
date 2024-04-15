-- Short files have been combined into this one to deflate the high file count


-- Formerly health_regeneration.lua
nadmin:RegisterPerm({
    title = "Health Regeneration",
    id = "hp_regen"
})


-- Formerly physgun_players.lua
nadmin:RegisterPerm({
    title = "Physgun Players"
})
nadmin:RegisterPerm({
    title = "Always Allow Noclip"
})


-- Formerly scoreboard_replacement.lua
hook.Add("ScoreboardShow", "nadmin_open_scoreboard", function()
    if nadmin.plugins.scoreboard then
        nadmin.scoreboard:Show()
        nadmin.scoreboard.shouldClose = false
        return true
    end
end)
hook.Add("ScoreboardHide", "nadmin_close_scoreboard", function()
    if IsValid(nadmin.scoreboard.player) and istable(nadmin.scoreboard.cmd) then nadmin.scoreboard.shouldClose = true return end
    nadmin.scoreboard:Hide()
end)


-- Formerly hud_replacement.lua
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