local cmd = {}
cmd.title = "Set Max Health"
cmd.description = "Set the maximum health of a player"
cmd.author = "Nub"
cmd.timeCreated = "Oct. 16 2019 @11:17 AM CST"
cmd.category = "Fun"
cmd.call = "mhp"
cmd.usage = "<player> [max-health]"
cmd.server = function(caller, args)
    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ > 0 then
                local am = tonumber(args[2])
                if not (isnumber(am) and am > 0) then am = 0 end

                for i, ply in ipairs(targ) do
                    if am == 0 then ply:SetMaxHealth(100)
                    else ply:SetMaxHealth(am) end
                end
                if am == 0 then
                    local msg = {myCol, caller:Nick(), nadmin.colors.white, " has reset the max health of "}
                    table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                    table.Add(msg, {nadmin.colors.white, "."})
                    nadmin:Notify(unpack(msg))
                else
                    local msg = {myCol, caller:Nick(), nadmin.colors.white, " has set the max health of "}
                    table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                    table.Add(msg, {nadmin.colors.white, " to ", nadmin.colors.red, tostring(am), nadmin.colors.white, "."})
                    nadmin:Notify(unpack(msg))
                end
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        else
            if IsValid(calller) then
                local am = tonumber(args[1])
                if isnumber(am) and am > 0 then
                    caller:SetMaxHealth(am)
                    nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their max health to ", nadmin.colors.red, caller:GetMaxHealth(), nadmin.colors.white, ".")
                else
                    nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/number for the first argument.")
                end
            else
                MsgN("[Nadmin]You can't set your max health as console.")
            end
        end
    else
        if IsValid(caller) then
            caller:SetMaxHealth(100)
            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has reset their max health.")
        else
            MsgN("[Nadmin]You can't set your max health as console.")
        end
    end
end

local hp = Material("icon16/heart_add.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "Maximum Health",
        default = 100,
        type = "number"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(hp)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
