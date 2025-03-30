local cmd = {}
cmd.title = "Set Play Time"
cmd.description = "Set the amount of time a player has been on the server."
cmd.author = "Nub"
cmd.timeCreated = "Feb. 24 2020 @ 11:00 PM CST"
cmd.category = "Player Management"
cmd.call = "playtime"
cmd.usage = "<player> [time]"
cmd.defaultAccess = nadmin.access.superadmin
cmd.server = function(caller, args)
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ == 1 then
                local am = nadmin:ParseTime(args[2])
                if isnumber(am) and am >= 0 then
                    targ[1]:SetPlayTime(am)

                    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                    local tCol = targ[1]:GetRank().color

                    local time = nadmin:TimeToString(targ[1]:GetPlayTime(), true)
                    if time == "" then time = "0 seconds" end

                    nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set the playtime of ", tCol, targ[1]:Nick(), nadmin.colors.white, " to ", nadmin.colors.red, time, nadmin.colors.white, ".")
                else
                    nadmin:Notify(caller, nadmin.colors.red, "You must input a valid time for the second argument.")
                end
            elseif #targ > 1 then
                nadmin:Notify(caller, nadmin.colors.red, "Too many players, did you mean ", nadmin.colors.white, nadmin:FormatPlayerList(targ, "or"), nadmin.colors.red, "?")
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        elseif #args == 1 and IsValid(caller) then
            local am = nadmin:ParseTime(args[1])
            if isnumber(am) and am > 0 then
                caller:SetPlayTime(am)
                nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has set their playtime to ", nadmin.colors.red, nadmin:FormatTime(caller:GetPlayTime()), nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/time for the first argument.")
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
        end
    else
        caller:SetPlayTime(0)
        nadmin:Notify(nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has reset their playtime.")
    end
end

local clock = Material("icon16/clock.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "Playtime",
        default = "0d",
        type = "time"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(clock)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
