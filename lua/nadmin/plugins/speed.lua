local cmd = {}
cmd.title = "Set Speed"
cmd.description = "Set the movement speed of a player."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 26 2019 @ 11:50 PM CST"
cmd.category = "Fun"
cmd.call = "speed"
cmd.usage = "<player> [walk] [run]"
cmd.server = function(caller, args)
    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

    if #args > 0 then
        local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
        if #targ > 0 then
            local reset = (#args == 1)

            local walk = tonumber(args[2])
            if not isnumber(walk) or walk < 0 then walk = 200 end

            local run = tonumber(args[3])
            if not isnumber(run) or run < 0 then run = 400 end

            for i, ply in ipairs(targ) do
                if reset then
                    ply:SetWalkSpeed(200)
                    ply:SetRunSpeed(400)
                else
                    ply:SetWalkSpeed(walk)
                    ply:SetRunSpeed(run)
                end
            end

            if reset then
                local msg = {myCol, caller:Nick(), nadmin.colors.white, " has reset the walk and run speeds of "}
                table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                table.Add(msg, {nadmin.colors.white, "."})
                nadmin:Notify(unpack(msg))
            else
                local msg = {myCol, caller:Nick(), nadmin.colors.white, " has set the ", nadmin.colors.blue, "walk", nadmin.colors.white, " and ", nadmin.colors.red, "run", nadmin.colors.white, " speeds of "}
                table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
                table.Add(msg, {nadmin.colors.white, " to ", nadmin.colors.blue, tostring(walk), nadmin.colors.white, " and ", nadmin.colors.red, tostring(run), nadmin.colors.white, "."})
                nadmin:Notify(unpack(msg))
            end
        else
            if IsValid(caller) then
                local walk = tonumber(args[1])
                if isnumber(walk) and walk > 0 then
                    caller:SetWalkSpeed(walk)
                    local run = tonumber(args[2])
                    if isnumber(run) and run > 0 then
                        caller:SetRunSpeed(run)
                        nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their ", nadmin.colors.blue, "walk", nadmin.colors.white, " and ", nadmin.colors.red, "run", nadmin.colors.white, " speeds to ",  nadmin.colors.blue, tostring(walk), nadmin.colors.white, " and ", nadmin.colors.red, tostring(run), nadmin.colors.white, ".")
                    else
                        nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has set their ", nadmin.colors.blue, "walk", nadmin.colors.white, " speed to ", nadmin.colors.blue, tostring(walk), nadmin.colors.white, ".")
                    end
                else
                    nadmin:Notify(caller, nadmin.colors.red, "Invalid walk speed")
                end
            else
                MsgN("[Nadmin]You can't set your movement speed as console.")
            end
        end
    else
        if IsValid(caller) then
            caller:SetWalkSpeed(200)
            caller:SetRunSpeed(400)
            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has reset their walk and run speeds.")
        else
            MsgN("[Nadmin]You can't set your movement speed as console")
        end
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "Walk Speed",
        default = 200,
        type = "number"
    },
    {
        text = "Run Speed",
        default = 400,
        type = "number"
    }
}

local lightning = Material("icon16/lightning.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(lightning)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
