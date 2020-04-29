local cmd = {}
cmd.title = "Set Level"
cmd.description = "Set the level of a player."
cmd.author = "Nub"
cmd.timeCreated = "Saturday, April 25 2020 @ 12:55 AM CST"
cmd.category = "Player Management"
cmd.call = "level"
cmd.usage = "<player> [level]"
cmd.server = function(caller, args)
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ == 1 then
                local am = tonumber(args[2])
                if isnumber(am) and am >= 0 then
                    targ[1]:SetLevel(am)

                    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                    local tCol = targ[1]:GetRank().color

                    nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set the level of ", tCol, targ[1]:Nick(), nadmin.colors.white, " to ", nadmin.colors.red, tostring(am), nadmin.colors.white, ".")
                else
                    nadmin:Notify(caller, nadmin.colors.red, "You must input a valid time for the second argument.")
                end
            elseif #targ > 1 then
                nadmin:Notify(caller, nadmin.colors.red, "Too many players, did you mean ", nadmin.colors.white, nadmin:FormatPlayerList(targ, "or"), nadmin.colors.red, "?")
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        elseif #args == 1 then
            local am = tonumber(args[1])
            if isnumber(am) and am >= 0 then
                caller:SetLevel(am)
                nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has set their level to ", nadmin.colors.red, tostring(am), nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/time for the first argument.")
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
        end
    else
        caller:SetLevel(0)
        nadmin:Notify(nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has reset their level.")
    end
end

local ctr = Material("icon16/controller.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "Level",
        default = "0",
        type = "number"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(ctr)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
