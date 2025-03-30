local cmd = {}
cmd.title = "Buildmode"
cmd.description = "Switch to build mode (you can't hurt anyone and nobody can hurt you)."
cmd.author = "Nub"
cmd.timeCreated = "Friday, August 21 2020 @ 11:18 PM CT"
cmd.category = "Utility"
cmd.call = "build"
cmd.defaultAccess = nadmin.access.default
cmd.server = function(caller, args)
    if IsValid(caller) then
        if not caller.n_BuildMode then
            caller.n_BuildMode = true
            nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " has entered build mode.")
        else
            nadmin:Notify(caller, nadmin.colors.red, "You are already in build mode.")
        end
    else
        MsgN("[Nadmin]You can't play in build mode as console.")
    end
end

if SERVER then
    hook.Add("EntityTakeDamage", "nadmin_build_nodamage", function(ent, dmg)
        -- Block damage to the player if they're in build mode
        if ent:IsPlayer() and ent.n_BuildMode then
            return true
        elseif ent:IsPlayer() then -- If the thing taking damage is a player, check whether to block
            -- Get the person doing the attacking
            local attacker = dmg:GetAttacker()

            -- If the attacker is in build mode, block their damage
            if IsValid(attacker) and attacker:IsPlayer() and attacker.n_BuildMode then
                return true
            end

            -- If the attacker is a weapon, check the owner for build mode
            if IsValid(attacker) and attacker.IsWeapon and attacker:IsWeapon() then
                attacker = attacker.Owner
                if isentity(attacker) and attacker:IsPlayer() and attacker.n_BuildMode then
                    return true
                end
            end

            -- If the attacker is a prop, get the owner of that prop and check for build mode
            if isfunction(attacker.CPPIGetOwner) then
                attacker = attacker:CPPIGetOwner()
                if isentity(attacker) and attacker:IsPlayer() and attacker.n_BuildMode then
                    return true
                end
            end
        end
    end)
end

nadmin:RegisterCommand(cmd)
