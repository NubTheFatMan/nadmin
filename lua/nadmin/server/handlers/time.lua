local lastTime = SysTime()
hook.Add("Think", "nadmin_time_handle", function()
    if SysTime() - lastTime >= 1 then
        lastTime = SysTime()
        for i, ply in ipairs(player.GetAll()) do
            if ply:GetPlayTime() >= math.huge then continue end
            
            local afkTime = (nadmin.plyPref and nadmin.plyPref[ply:SteamID()] and nadmin.plyPref[ply:SteamID()].afkTime) 
            if ply.n_AFK then 
                if ply:HasPerm("allow_afk_time") then 
                    if not afkTime then continue end
                else 
                    continue 
                end
            end

            -- if afk and afkTime then continue end -- Don't give time to AFK players.

            ply:SetPlayTime(ply:GetPlayTime() + 1)

            local rank = ply:GetRank()
            if istable(rank) then
                if not rank.autoPromote.enabled then continue end

                local bc = rank.color

                if ply:GetPlayTime() >= rank.autoPromote.when then
                    local newRank = nadmin:FindRank(rank.autoPromote.rank)
                    if istable(newRank) then
                        local ac = newRank.color
                        ply:SetRank(newRank.id)
                        nadmin:Notify(bc, ply:Nick(), nadmin.colors.white, " has been promoted to ", ac, newRank.title, nadmin.colors.white, ".")
                    end
                end
            end
        end
    end
end)
