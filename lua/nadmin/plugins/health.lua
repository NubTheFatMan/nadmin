local cmd = {}
cmd.title = "Set Health"
cmd.description = "Set the health of a player"
cmd.author = "Nub"
cmd.timeCreated = "Oct. 16 2019 @ 10:44 AM CST"
cmd.category = "Fun"
cmd.call = "hp"
cmd.usage = "<player> [health]"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
    if #args > 0 then
        if #args > 1 then
            local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
            if #targ > 0 then
                local am = tonumber(args[2])
                if not (isnumber(am) and am > 0) then am = 0 end

                for i, ply in ipairs(targ) do
                    if am == 0 then ply:SetHealth(ply:GetMaxHealth())
                    else ply:SetHealth(am) end
                end
                if am == 0 then
                    local msg = {myCol, caller:Nick(), nadmin.colors.white, " has reset the health of "}
                    table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                    table.Add(msg, {nadmin.colors.white, "."})
                    nadmin:Notify(unpack(msg))
                else
                    local msg = {myCol, caller:Nick(), nadmin.colors.white, " has set the health of "}
                    table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                    table.Add(msg, {nadmin.colors.white, " to ", nadmin.colors.red, tostring(am), nadmin.colors.white, "."})
                    nadmin:Notify(unpack(msg))
                end
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            end
        else
            if IsValid(caller) then
                local am = tonumber(args[1])
                if isnumber(am) and am > 0 then
                    caller:SetHealth(am)
                    nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their health to ", nadmin.colors.red, caller:Health(), nadmin.colors.white, ".")
                else
                    nadmin:Notify(caller, nadmin.colors.red, "You must input a valid player/number for the first argument.")
                end
            else
                MsgN("[Nadmin]You can't set your health as console.")
            end
        end
    else
        if IsValid(caller) then
            caller:SetHealth(caller:GetMaxHealth())
            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has reset their health.")
        else
            MsgN("[Nadmin]You can't set your health as console.")
        end
    end
end

local hp = Material("icon16/heart.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "New Health",
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
