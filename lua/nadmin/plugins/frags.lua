local cmd = {}
cmd.title = "Set Frags"
cmd.description = "Set the number of frags (kills) a player has."
cmd.author = "Nub"
cmd.timeCreated = "May 22 2020 @ 12:06 AM CT"
cmd.category = "Fun"
cmd.call = "frags"
cmd.usage = "<player> [frags]"
cmd.server = function(caller, args)
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ > 0 then
                local am = tonumber(args[2])
                if not (isnumber(am) and am > 0) then am = 0 end

                for i, ply in ipairs(targ) do
                    ply:SetFrags(am)
                end

                local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

                local toUnpack = {myCol, caller:Nick(), nadmin.colors.white, " has set the frags of "}
                table.Add(toUnpack, nadmin:FormatPlayerList(targ, "and"))
                table.Add(toUnpack, {nadmin.colors.white, " to ", nadmin.colors.red, tostring(am), nadmin.colors.white, "."})

                nadmin:Notify(unpack(toUnpack))
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        else
            local am = tonumber(args[1])
            if isnumber(am) and am >= 0 then
                caller:SetFrags(am)

                local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their frags to ", nadmin.colors.red, caller:Frags(), nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/number for the first argument.")
            end
        end
    else
        caller:SetFrags(0)

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their frags to ", nadmin.colors.red, caller:Frags(), nadmin.colors.white, ".")
    end
end

local shield = Material("icon16/user_add.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player"
    },
    {
        text = "Frags",
        type = "number"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(shield)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
