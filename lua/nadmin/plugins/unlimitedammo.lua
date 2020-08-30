local COMMAND = {}
COMMAND.title = "Unlimited Ammo"
COMMAND.description = "Give a player unlimited ammo."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, May 23, 2020 @ 9:47 PM CT"
COMMAND.category = "Fun"
COMMAND.call = "ua"
COMMAND.usage = "<player> [1|0]"
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local granted = {}
        local revoked = {}
        for i, ply in ipairs(targs) do
            if tonumber(args[2]) then
                local en = nadmin:IntToBool(tonumber(args[2]))
                if en then
                    table.insert(granted, ply)
                    ply.n_UnlimitedAmmo = true
                    COMMAND.fillClips(ply, ply:GetActiveWeapon())
                else
                    table.insert(revoked, ply)
                    ply.n_UnlimitedAmmo = false
                end
            else
                if ply.n_UnlimitedAmmo then
                    table.insert(revoked, ply)
                    ply.n_UnlimitedAmmo = false
                else
                    table.insert(granted, ply)
                    ply.n_UnlimitedAmmo = true
                    COMMAND.fillClips(ply, ply:GetActiveWeapon())
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #granted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has granted unlimited ammo upon "}
            table.Add(msg, nadmin:FormatPlayerList(granted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
        if #revoked > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has revoked unlimited ammo from from "}
            table.Add(msg, nadmin:FormatPlayerList(revoked, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

if SERVER then
    COMMAND.fillClips = function(ply, wep)
        if (!wep:IsValid()) then return end
        if (wep:Clip1() < 250) then wep:SetClip1(250) end
        if (wep:Clip2() < 250) then wep:SetClip2(250) end

        if wep:GetPrimaryAmmoType() == 10 or wep:GetPrimaryAmmoType() == 8 then
            ply:GiveAmmo(9 - ply:GetAmmoCount(wep:GetPrimaryAmmoType()), wep:GetPrimaryAmmoType())
        elseif wep:GetSecondaryAmmoType() == 9 or wep:GetSecondaryAmmoType() == 2 then
            ply:GiveAmmo( 9 - ply:GetAmmoCount(wep:GetSecondaryAmmoType()), wep:GetSecondaryAmmoType())
        end
    end

    hook.Add("Think", "nadmin_ua_update", function()
        for i, ply in ipairs(player.GetHumans()) do
            if ply.n_UnlimitedAmmo and ply:Alive() and ply:GetActiveWeapon() then
                COMMAND.fillClips(ply, ply:GetActiveWeapon())
            end
        end
    end)
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "checkbox",
        text = "Has Ammo"
    }
}

local god = Material("icon16/coins_add.png")
local ungod = Material("icon16/coins_delete.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nadmin:Ternary(ply.n_UnlimitedAmmo, ungod, god))
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText(nadmin:Ternary(ply:HasGodMode(), "Revoke UA", "Grant UA"))
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " ua " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
