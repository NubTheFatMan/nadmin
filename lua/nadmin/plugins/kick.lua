local cmd = {}
cmd.title = "Kick"
cmd.description = "Kick a player from the server."
cmd.author = "Nub"
cmd.timeCreated = "Apr. 1, 2020 @ 7:36 PM CST"
cmd.category = "Player Management"
cmd.usage = "<player> {reason}"
cmd.call = "kick"

cmd.server = function(caller, args)
    if #args > 0 then
        local targ = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
        if table.HasValue(targ, caller) then
            for i, t in ipairs(targ) do
                if t == caller then table.remove(targ, i) break end
            end
        end

        if #targ > 0 then
            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has kicked "}
            table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

            local list = nadmin:FormatPlayerListNoColor(targ, "and")
            nadmin:Log("administration", caller:PlayerToString("nick (steamid)<ipaddress>") .. " has kicked " .. list)

            local reason = nil
            if #args > 0 then
                reason = table.concat(args, " ")
            end

            for i, ply in ipairs(targ) do
                ply:RemoveProps()
                ply:Kick(reason)
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, "First argument must be a player.")
    end
end

local dis = Material("icon16/disconnect.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    },
    {
        text = "Reason",
        type = "string"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.canTargSelf = true
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(dis)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
