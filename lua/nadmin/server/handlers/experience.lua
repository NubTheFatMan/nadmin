-- We want to add xp after a certain amount of time
hook.Add("Think", "nadmin_xp_time", function()
    if nadmin.plugins.levels then 
        local now = os.time()
        for i, ply in ipairs(player.GetAll()) do
            if ply.n_AFK and not ply:HasPerm("allow_afk_time") then continue end -- Don't give XP to AFK players.
            if not isnumber(nadmin.xp.cache[ply:SteamID()]) then nadmin.xp.cache[ply:SteamID()] = now end

            if now - nadmin.xp.cache[ply:SteamID()] >= nadmin.xp.rate then
                ply:AddExperience(nadmin.xp.amount)
                nadmin.xp.cache[ply:SteamID()] = now
            end
        end
    end
end)
