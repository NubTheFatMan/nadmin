local cmd = {}
cmd.title = "Teleport"
cmd.description = "Teleport you or another player to where your aiming."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 26 2019 @ 10:46 PM CST"
cmd.category = "Teleportation"
cmd.call = "tp"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin

cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local size = Vector(32, 32, 72)
        local tr = {}
        tr.start = caller:GetShootPos()
        tr.endpos = caller:GetShootPos() + caller:GetAimVector() * 100000000
        tr.filter = caller
        local trace = util.TraceEntity(tr, caller)
        local eyeTrace = caller:GetEyeTraceNoCursor()
        if trace.HitPos:Distance(eyeTrace.HitPos) > size:Length() then
            trace = eyeTrace
            trace.HitPos = trace.HitPos + trace.HitNormal * size * 1.2
        end
        size = size * 1.5
        for i, ply in ipairs(targs) do
            ply:AddReturnPosition()

            if ply:InVehicle() then ply:ExitVehicle() end
            ply:SetPos(trace.HitPos + trace.HitNormal * (i - 1) * size)
            ply:SetLocalVelocity(Vector(0, 0, 0))
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has teleported "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, "."})
        nadmin:Notify(unpack(msg))
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    }
}

nadmin:RegisterCommand(cmd)
