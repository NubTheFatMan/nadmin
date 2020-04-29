nadmin:RegisterPerm({
    title = "Health Regeneration",
    id = nadmin.hpRegen.perm
})

hook.Add("Think", "nadmin_hp_regen", function()
    local now = os.time()
    for i, ply in ipairs(player.GetAll()) do
        if not ply:Alive() then continue end
        local can = ply:HasPerm(nadmin.hpRegen.perm)

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
