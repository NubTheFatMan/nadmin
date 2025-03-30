local cmd = {}
cmd.title = "Return"
cmd.description = "Return a player who was teleported."
cmd.author = "Nub"
cmd.timeCreated = "Feb. 26 2020 @ 10:59 PM CST"
cmd.category = "Teleportation"
cmd.call = "return"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin

cmd.server = function(caller, args)
    local targ = nadmin:FindPlayer(args[1] or "^", caller, nadmin.MODE_BELOW)
    if #targ == 1 then
        if istable(nadmin.plyReturns[targ[1]:SteamID()]) and #nadmin.plyReturns[targ[1]:SteamID()] > 0 then
            -- Move them to the most recent position.
            local pos = table.remove(nadmin.plyReturns[targ[1]:SteamID()])

            if targ[1]:InVehicle() then targ[1]:ExitVehicle() end
            targ[1]:SetPos(pos)

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has returned ", targ[1]:GetRank().color, targ[1]:Nick(), nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "No position to return this player to.")
        end
    elseif #targ > 1 then
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargSame)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    }
}

local tp = Material("icon16/door_out.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(tp)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " return " .. ply:SteamID())
end

nadmin:RegisterCommand(cmd)
