local cmd = {}
cmd.title = "Rocket"
cmd.description = "Rocket a player into the sky; they will explode."
cmd.author = "Nub"
cmd.timeCreated = "Sunday, May 24 2020 @ 12:20 AM CST"
cmd.category = "Fun"
cmd.call = "rocket"
cmd.usage = "<player>"
cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local rocketed = {}
        for i, targ in ipairs(targs) do
            if targ:Alive() then table.insert(rocketed, targ) end
            targ:SetMoveType(MOVETYPE_WALK)
            targ:SetVelocity(Vector(0, 0, 4000))
            ParticleEffectAttach("rockettrail", PATTACH_ABSORIGIN_FOLLOW, targ, 0)

            timer.Simple(2, function()
                local bomb = ents.Create("env_explosion")
                bomb:SetPos(targ:GetPos())
                bomb:SetOwner(targ)
                bomb:Spawn()
                bomb:SetKeyValue("iMagnitude", "1")
                bomb:Fire("Explode", 0, 0)
                bomb:EmitSound("ambient/explosions/explode_4.wav", 500, 500)
                if targ:Alive() then targ:Kill() targ:SetFrags(targ:Frags() + 1) end

                targ:StopParticles()
            end)
        end

        if #rocketed > 0 then
            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has rocketed "}
            table.Add(msg, nadmin:FormatPlayerList(rocketed, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        else
            nadmin:Notify(caller, nadmin.colors.red, "None of your targets were alive.")
        end
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

local del = Material("icon16/world.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " rocket " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
