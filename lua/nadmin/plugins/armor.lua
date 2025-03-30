local cmd = {}
cmd.title = "Set Armor"
cmd.description = "Set the armor of a player"
cmd.author = "Nub"
cmd.timeCreated = "Oct. 16 2019 @ 2:49 PM CST"
cmd.category = "Fun"
cmd.call = "armor"
cmd.usage = "<player> [armor]"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ > 0 then
                local am = tonumber(args[2])
                if not (isnumber(am) and am > 0) then am = 0 end

                for i, ply in ipairs(targ) do
                    ply:SetArmor(am)
                end

                local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

                local toUnpack = {myCol, caller:Nick(), nadmin.colors.white, " has set the armor of "}
                table.Add(toUnpack, nadmin:FormatPlayerList(targ, "and"))
                table.Add(toUnpack, {nadmin.colors.white, " to ", nadmin.colors.red, tostring(am), nadmin.colors.white, "."})

                nadmin:Notify(unpack(toUnpack))
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        else
            local am = tonumber(args[1])
            if isnumber(am) and am >= 0 then
                caller:SetArmor(am)

                local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their armor to ", nadmin.colors.red, caller:Armor(), nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/number for the first argument.")
            end
        end
    else
        caller:SetArmor(0)

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their armor to ", nadmin.colors.red, caller:Armor(), nadmin.colors.white, ".")
    end
end

local shield = Material("icon16/shield.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player"
    },
    {
        text = "New Armor",
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
