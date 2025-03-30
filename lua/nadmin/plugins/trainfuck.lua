local cmd = {}
cmd.title = "Trainfuck"
cmd.description = "Trainfuck a player ( ͡° ͜ʖ ͡°)."
cmd.author = "Nub"
cmd.timeCreated = "Thursday, May 21 2020 @ 12:08 AM CT"
cmd.category = "Fun"
cmd.call = "trainfuck"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin

cmd.models = {
    "models/props_trainstation/train001.mdl",
    "models/props_trainstation/train002.mdl",
    "models/props_trainstation/train003.mdl"
}

cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)

    if #targs > 0 then
        for i, targ in ipairs(targs) do
            local tPos, tDir = targ:GetPos() + targ:GetForward() * 2000 + Vector(0, 0, 100), targ:GetForward() * -1
            local tModel = cmd.models[math.random(1, #cmd.models)]
            local train = ents.Create("prop_physics")
            train:SetModel(tModel)
            train:SetAngles(tDir:Angle() + Angle(0, 270, 0))
            train:SetPos(tPos)
            train:Spawn()
            train:Activate()
            targ:EmitSound("ambient/alarms/train_horn2.wav", 511, 100)
            local obj = train:GetPhysicsObject()
            if (IsValid(obj)) then
                obj:EnableGravity(false)
                obj:EnableCollisions(false)
                obj:SetVelocity(tDir * 100000)
            end
            timer.Simple(0.6,function()
                local dmg = DamageInfo()
                dmg:AddDamage(2^31-1)
                dmg:SetDamageForce(tDir * 500000)
                dmg:SetInflictor(train)
                dmg:SetAttacker(train)
                targ:TakeDamageInfo(dmg)
                targ:Kill()
                targ:TakeDamageInfo(dmg)
                targ:SetFrags(targ:Frags() + 1)
            end)
            timer.Simple(3,function()
                train:Remove()
            end)
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has trainfucked "}
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

local del = Material("icon16/lorry.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " trainfuck " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
