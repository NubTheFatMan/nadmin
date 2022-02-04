-- This file handles picking up players with physgun
nadmin:RegisterPerm({
    title = "Physgun Players"
})
nadmin:RegisterPerm({
    title = "Always Allow Noclip"
})

hook.Add("PhysgunPickup", "nadmin_physgun_player_pickup", function(ply, ent)
    if ent:IsPlayer() and ply:HasPerm("physgun_players") and ply:BetterThan(ent) and nadmin.plyPref and nadmin.plyPref[ply:SteamID()] and nadmin.plyPref[ply:SteamID()].physgunOthers then
        ent:UnLock()
        ent.IsPickedUp = true
        ent:SetMoveType(MOVETYPE_NONE)
        return true
    end
end)

hook.Add("CanPlayerSuicide", "nadmin_prevent_suicide", function(ply)
    if ply.IsPickedUp or ply:IsFlagSet(FL_FROZEN) then return false end
end)

hook.Add("PhysgunDrop", "nadmin_physgun_player_drop", function(ply, tar)
    if tar:IsPlayer() then
        tar.IsPickedUp = false
        tar:SetMoveType(MOVETYPE_WALK)

        -- Physgun right click
        if ply:KeyDown(IN_ATTACK2) and ply:HasPerm("freeze") then
            tar:Lock()
        else
            tar:UnLock()
        end

        return true
    end
end)

hook.Add("PlayerNoClip", "nadmin_noclip_prevention", function(ply)
    if ply.IsPickedUp then return false end

    if ply:GetMoveType() == MOVETYPE_NOCLIP then
        return true
    elseif ply.n_BuildMode then
        return true
    elseif GetConVar("sbox_noclip"):GetInt() == 0 then
        -- return ply:HasPerm("always_allow_noclip")
        if ply:HasPerm("always_allow_noclip") then 
            if nadmin.plyPref and nadmin.plyPref[ply:SteamID()] and nadmin.plyPref[ply:SteamID()].allowNoclip then 
                return true 
            end
        end
        return false
    end
end)

hook.Add("PostPlayerDeath", "nadmin_save_hp", function(ply)
    ply.n_MaxHP = ply:GetMaxHealth()
end)

hook.Add("PlayerSpawn", "nadmin_reapply_features", function(ply)
    if ply:GetNWBool("nadmin_god") then ply:GodEnable() end
    if isnumber(ply.n_MaxHP) then
        timer.Simple(0.05, function()
            ply:SetMaxHealth(ply.n_MaxHP)
            ply:SetHealth(ply:GetMaxHealth())
        end)
    end
end)
