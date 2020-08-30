local cmd = {}
cmd.title = "Cleanup Player"
cmd.description = "Clean a player's props."
cmd.author = "Nub"
cmd.timeCreated = "Wednesday, May 20 2020 @ 11:07 PM CST"
cmd.category = "Utility"
cmd.call = "cleanup"
cmd.usage = "<player>"
cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        for i, targ in ipairs(targs) do
            targ:RemoveProps()
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has removed the props of "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, "."})
        nadmin:Notify(unpack(msg))
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    }
}

local del = Material("icon16/brick_delete.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " cleanup " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
