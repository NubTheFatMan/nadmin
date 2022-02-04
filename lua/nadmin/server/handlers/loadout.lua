hook.Add("PlayerLoadout", "nadmin_loadouts", function(ply)
    if not nadmin.plugins.loadouts then return end
    
    local rank = ply:GetRank()
    if not istable(rank) then return end
    for i, wep in ipairs(rank.loadout) do
        ply:Give(wep)
    end

    ply:SelectWeapon("weapon_physgun")

    return true --Hide default loadout
end)
