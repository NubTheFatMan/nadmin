local cmd = {}
cmd.title = "Bring"
cmd.description = "Bring a player to you."
cmd.author = "Nub"
cmd.timeCreated = "Feb. 26 2020 @ 10:35 PM CST"
cmd.category = "Teleportation"
cmd.call = "bring"
cmd.usage = "<player>"

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
        MsgN("[Nadmin]You can't bring people as the console. You're not a physical object!")
        return
    end

    if #args > 0 then
        local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_SAME)

        if table.HasValue(targ, caller) then
            for i, ply in ipairs(targ) do
                if ply == caller then table.remove(targ, i) break end
            end
        end

        if #targ > 0 then
            for i, ply in ipairs(targ) do
                if ply:GetMoveType() == MOVETYPE_OBSERVER then
                    nadmin:Notify(caller, nadmin.colors.red, "Couldn't bring " .. ply:Nick() .. ": spectating another player.")
                    continue
                end

                ply:AddReturnPosition()

                if ply:InVehicle() then ply:ExitVehicle() end
                if ply:GetMoveType() == MOVETYPE_NOCLIP then
                    ply:SetPos(caller:GetPos() + caller:GetForward() * 45)
                else
                    local pos = cmd.findPosition(caller)
                    if pos then
                        ply:SetPos(pos)
                    else
                        ply:SetPos(caller:GetPos() + Vector(0, 0, 72))
                    end
                end
            end

            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has brought "}
            table.Add(msg, nadmin:FormatPlayerList(targ, "and"))
            table.Add(msg, {nadmin.colors.white, " to them."})

            nadmin:Notify(unpack(msg))
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargSame)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    }
}

local tp = Material("icon16/door_in.png")

cmd.scoreboard = {}
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(tp)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " bring " .. ply:SteamID())
end

nadmin:RegisterCommand(cmd)
