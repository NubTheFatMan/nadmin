-- Block spawning props if they are being frozen-banned
hook.Add("PlayerSpawnProp", "nadmin.block.freezebanspawning", function(ply, model)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(model) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessProp)
            return false
        end
    end
end)

--Spawning weapons with toolgun or middle mouse click.
hook.Add("PlayerSpawnSWEP", "nadmin.restrictions.SpawnSwep", function(ply, class)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(class) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessSWEP)
            return false
        end
    end
end)

hook.Add("PlayerSpawnedSWEP", "nadmin.restrict.SpawnSwep", function(ply, swep)
    local remove = false
    if ply.FreezeBan then remove = true end

    if ply:HasRestriction(swep:GetClass()) then
        nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessSWEP)
        remove = true
    end

    if remove then
        timer.Simple(0.05, function()
            swep:Remove()
        end)
    end
end)

--Spawning weapons with left click
hook.Add("PlayerGiveSWEP", "nadmin.restrictions.GiveSwep", function(ply, class)
    if ply.FreezeBan then
        return false
    end

    if ply.n_Giving then ply.n_Giving = nil return true end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(class) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessSWEP)
            return false
        end
    end
end)

--Stop them from picking up a weapon if it's restricted.
hook.Add("PlayerCanPickupWeapon", "nadmin.restrictions.PickupSwep", function(ply, ent)
    if ply.FreezeBan then
        return false
    end

    if ply.n_Giving then ply.n_Giving = nil return true end

    if GAMEMODE.IsSandboxDerived then
        local class = ent:GetClass()
        if ply:HasRestriction(class) then
            return false
        end
    end
end)

--Spawning scripted entities
hook.Add("PlayerSpawnSENT", "nadmin.restrictions.SpawnSent", function(ply, class)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(class) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessEnt)
            return false
        end
    end
end)

hook.Add("PlayerSpawnedSENT", "nadmin.restrict.SpawnSent", function(ply, ent)
    local remove = false
    if ply.FreezeBan then remove = true end

    if ply:HasRestriction(ent:GetClass()) then
        nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessEnt)
        remove = true
    end

    if remove then
        timer.Simple(0.05, function()
            ent:Remove()
        end)
    end
end)

--Restrict the tool gun
hook.Add("CanTool", "nadmin.restrictions.tools", function(ply, tr, class)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(class) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessTool)
            return false
        end
    end
end)

-- Restrict vehicles
hook.Add("PlayerSpawnVehicle", "nadmin.restrictions.vehicles", function(ply, model, name, v)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(name) or ply:HasRestriction(v.ClassName) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessVehicle)
            return false
        end
    end
end)

hook.Add("PlayerSpawnedVehicle", "nadmin.restrict.vehicles", function(ply, vh)
    local remove = false
    if ply.FreezeBan then remove = true end

    if ply:HasRestriction(vh:GetClass()) or ply:HasRestriction(vh.ClassName) then
        nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessVehicle)
        remove = true
    end

    if remove then
        timer.Simple(0.05, function()
            vh:Remove()
        end)
    end
end)

-- Restrict NPCs
hook.Add("PlayerSpawnNPC", "nadmin.restrictions.npcs", function(ply, npc, wep)
    if ply.FreezeBan then
        return false
    end

    if GAMEMODE.IsSandboxDerived then
        if ply:HasRestriction(npc) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessNPC)
            return false
        end
    end
end)

hook.Add("PlayerSpawnedNPC", "nadmin.restrict.npcs", function(ply, npc)
    local remove = false
    if ply.FreezeBan then remove = true end

    if ply:HasRestriction(npc:GetClass()) then
        nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noAccessNPC)
        remove = true
    end

    if remove then
        timer.Simple(0.05, function()
            npc:Remove()
        end)
    end
end)
