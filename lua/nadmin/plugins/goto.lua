local cmd = {}
cmd.title = "Goto"
cmd.description = "Teleport to another player."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 25 2019 @ 10:46 PM CST"
cmd.category = "Teleportation"
cmd.call = "goto"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin

cmd.positions = {Vector(0, 0, 1)}
for i = 0, 360, 45 do table.insert(cmd.positions, Vector(math.cos(i), math.sin(i), 0)) end

cmd.findPosition = function(ply)
    local size = Vector(32, 32, 32)
    local startPos = ply:GetPos() + Vector(0, 0, size.z / 2)
    for i, v in ipairs(cmd.positions) do
        local pos = startPos + v * size * 1.5
        local tr = {}
        tr.start = pos
        tr.endpos = pos
        tr.mins = size / 2 * -1
        tr.maxs = size / 2
        local trace = util.TraceHull(tr)
        if not trace.Hit then
            return pos - Vector(0, 0, size.z / 2)
        end
    end
    return false
end

cmd.server = function(caller, args)
    if not IsValid(caller) then
        MsgN("[Nadmin]You can't teleport to anyone, you're not a physical object!")
        return
    end

    if #args > 0 then
        local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_ALL)
        if table.HasValue(targ, caller) then -- Remove caller from table
            for i, t in ipairs(targ) do
                if t == caller then
                    table.remove(targ, i)
                    break
                end
            end
        end

        if #targ == 1 then
            if targ[1]:GetMoveType() == MOVETYPE_OBSERVER then
                nadmin:Notify(caller, nadmin.colors.red, "This player is spectating another player.")
                return
            end
            -- This is for the n!return command
            caller:AddReturnPosition()

            if caller:InVehicle() then caller:ExitVehicle() end
            if caller:GetMoveType() == MOVETYPE_NOCLIP then
                caller:SetPos(targ[1]:GetPos() + targ[1]:GetForward() * 45)
            else
                local pos = cmd.findPosition(targ[1])
                if pos then
                    caller:SetPos(pos)
                else
                    caller:SetPos(targ[1]:GetPos() + Vector(0, 0, 72))
                end
            end

            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.gui.blue
            local targCol = targ[1]:GetRank().color

            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has gone to ", targCol, targ[1]:Nick(), nadmin.colors.white, ".")
        elseif #targ > 1 then
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargets)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_ALL,
        canTargetSelf = false
    }
}

local tp = Material("icon16/group_go.png")

cmd.scoreboard = {}
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.targetMode = nadmin.MODE_SAME
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(tp)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " goto " .. ply:SteamID())
end

nadmin:RegisterCommand(cmd)
