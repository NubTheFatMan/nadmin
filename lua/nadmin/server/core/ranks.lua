function nadmin:SaveRanks()
    file.Write("nadmin/config/ranks.txt", util.TableToJSON(nadmin.ranks))
    MsgN("[Nadmin]Saving ranks...")
end

util.AddNetworkString("nadmin_send_updated_ranks")
function nadmin:SendRanksToClients()
    net.Start("nadmin_send_updated_ranks")
        net.WriteTable(nadmin.ranks)
    net.Broadcast()
end

function nadmin:ValidateRank(rank, oid, ply)
    if not istable(rank) or not isstring(oid) then return NULL, "Internal error: Invalid arguments." end --Returning NULL indicates an invalid rank

    local callerRank
    if type(ply) == "Player" then callerRank = ply:GetRank()
    elseif istable(ply) then callerRank = ply.id end

    local out = table.Copy(rank)
    if not isstring(out.title) then out.title = "Undefined" end

    if not isstring(out.id) then out.id = string.lower(string.Replace(out.title, " ", "_")) end
    -- Validate the rank ID (remove duplicates)
    local ranks = {}
    for i, r in pairs(nadmin.ranks) do
        if r.id == oid then continue end
        table.insert(ranks, r.id)
    end
    if table.HasValue(ranks, rank.id) then return NULL, "ID already exists on another rank, can't overwrite." end --This rank already exists, we don't want to overwrite it.

    if not isnumber(out.immunity) then out.immunity = 0 end
    -- Validate the immunity
    if istable(callerRank) then -- We only want to do this if the caller rank exists
        -- We don't want the immunity < 0, nor do we want this rank to be higher than the caller's rank
        -- TODO
    end

    if not isstring(out.icon) then out.icon = "icon16/user.png" end
    if not IsColor(out.color) then out.color = Color(255, 255, 255) end

    -- Validate auto promotion
    if not istable(out.autoPromote) then out.autoPromote = {when = 0, rank = "", enabled = false} end

    local ap = out.autoPromote
    if not isnumber(ap.when) then ap.when = 0 end
    if not isstring(ap.rank) then ap.rank = "" end
    if not isbool(ap.enabled) then ap.enabled = false end
    if istable(callerRank) then
        local targRank = nadmin:FindRank(ap.rank)
        if not istable(targRank) then
            ap.rank = "" --Since autopromotion isn't a critical component, we don't want to error
        else
            -- Owners should bypass all restrictions
            if targRank.access < nadmin.access.owner then
                --We don't want to keep this rank if it's higher than the current player's rank
                -- TODO
            end
        end
    end

    if ap.when < 1 then ap.enabled = false end

    return out
end
