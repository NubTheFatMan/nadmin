local COMMAND = {}
COMMAND.title = "Strip"
COMMAND.description = "Strip a player of their weapons."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, April 30, 2020 @ 10:56 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "strip"
COMMAND.usage = "<player>"
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)

    if #targs > 0 then
        for i, ply in ipairs(targs) do
            ply:StripWeapons()
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has stripped "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, " of all weapons."})
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

local say = Material("icon16/lorry.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(say)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " strip " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
