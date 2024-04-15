nadmin.hpRegen       = nadmin.hpRegen       or {}
nadmin.hpRegen.cache = nadmin.hpRegen.cache or {}

nadmin.hpRegen.amount = 2              -- How much health to add
nadmin.hpRegen.rate   = 3              -- How long to wait before adding health

nadmin:RegisterPerm({
    title = "Health Regeneration",
    id = "hp_regen"
})

hook.Add("Think", "nadmin_hp_regen", function()
    local now = os.time()
    for i, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end
        local can = ply:HasPerm("hp_regen")
        
        if can then 
            if nadmin.plyPref and nadmin.plyPref[ply:SteamID()] and not nadmin.plyPref[ply:SteamID()].hpRegen then can = false end
        end

        if can then
            if not nadmin.hpRegen.cache[ply:SteamID()] then nadmin.hpRegen.cache[ply:SteamID()] = {time = now, hp = ply:Health()} end
            local cache = nadmin.hpRegen.cache[ply:SteamID()]

            -- Health was changed, so we don't want to add any hp soon
            if ply:Health() ~= cache.hp then
                cache.time = now
                cache.hp = ply:Health()
                continue -- Prevent from adding health in the next line (probably not needed)
            end

            if now - cache.time >= nadmin.hpRegen.rate and ply:Health() < ply:GetMaxHealth() then
                -- We are clamping incase the regen amount is < 0, we don't want a negative health.
                ply:SetHealth(math.Clamp(ply:Health() + nadmin.hpRegen.amount, 1, ply:GetMaxHealth()))

                -- Update the cache
                cache.time = now
                cache.hp = ply:Health()
            end
        end
    end
end)
