local cmd = {}
cmd.title = "Slay"
cmd.description = "Kill a player."
cmd.author = "Nub"
cmd.timeCreated = "Feb. 22 2020 @ 10:49 PM CST"
cmd.category = "Fun"
cmd.call = "slay"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        for i, targ in ipairs(targs) do
            targ:Kill()
            targ:SetFrags(targ:Frags() + 1)
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has slain "}
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

local del = Material("icon16/user_delete.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " slay " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
