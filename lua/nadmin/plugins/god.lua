local COMMAND = {}
COMMAND.title = "God"
COMMAND.description = "Grant/Revoke godmode upon a player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, June 13, 2019 @ 9:49 AM"
COMMAND.category = "Fun"
COMMAND.call = "god"
COMMAND.usage = "<player> [1|0]"
COMMAND.defaultAccess = nadmin.access.admin
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
                    ply:GodEnable()
                else
                    table.insert(revoked, ply)
                    ply:GodDisable()
                end
            else
                if ply:HasGodMode() then
                    table.insert(revoked, ply)
                    ply:GodDisable()
                else
                    table.insert(granted, ply)
                    ply:GodEnable()
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #granted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has granted godmode upon "}
            table.Add(msg, nadmin:FormatPlayerList(granted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

        end
        if #revoked > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has revoked godmode from "}
            table.Add(msg, nadmin:FormatPlayerList(revoked, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "checkbox",
        text = "Godded"
    }
}

local god = Material("icon16/user.png")
local ungod = Material("icon16/shield.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nadmin:Ternary(ply:HasGodMode(), ungod, god))
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText(nadmin:Ternary(ply:HasGodMode(), "Ungod", "God"))
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " god " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
