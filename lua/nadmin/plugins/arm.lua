local COMMAND = {}
COMMAND.title = "Arm"
COMMAND.description = "Strip a player of their weapons and give them the default loadout."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, April 30, 2020 @ 11:04 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "arm"
COMMAND.usage = "<player>"

COMMAND.loadout = {"weapon_crowbar", "weapon_physcannon", "weapon_physgun", "weapon_pistol", "weapon_357", "weapon_smg1", "weapon_ar2", "weapon_shotgun", "weapon_crossbow", "weapon_frag", "weapon_rpg", "gmod_camera", "gmod_tool"}

COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)

    if #targs > 0 then
        for i, ply in ipairs(targs) do
            ply:StripWeapons()

            local rank = ply:GetRank()
            for i, wep in ipairs(COMMAND.loadout) do
                ply:Give(wep)
            end

            ply:SelectWeapon("weapon_physgun")
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has armed "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, "."})
        nadmin:Notify(unpack(msg))
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    }
}

local say = Material("icon16/wand.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(say)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " arm " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
