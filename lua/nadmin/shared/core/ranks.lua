nadmin.null_rank = {
    title = "Unranked",
    id = "null", 
    icon = "no_texture",
    immunity = 0,
    access = nadmin.access.user,
    autoPromote = {when = 0, rank = "", enabled = false},
    color = Color(255, 255, 255),
    restrictions = {},
    privileges = {}
}

function nadmin:RegisterRank(tbl)
    local rank = table.Copy(tbl or {})

    rank.title       = isstring(tbl.title)       and tbl.title       or "Undefined"
    rank.id          = isstring(tbl.id)          and tbl.id          or string.lower(string.Replace(rank.title, " ", "_"))
    rank.icon        = isstring(tbl.icon)        and tbl.icon        or "icon16/user.png"
    rank.inheritFrom = isstring(tbl.inheritFrom) and tbl.inheritFrom or ""
    rank.access      = isnumber(tbl.access)      and tbl.access      or nadmin.access.user
    rank.immunity    = isnumber(tbl.immunity)    and tbl.immunity    or 0
    rank.autoPromote = istable(tbl.autoPromote)  and tbl.autoPromote or {when = 0, rank = "", enabled = false}

    if IsColor(tbl.color) then rank.color = tbl.color
    elseif istable(tbl.color) then rank.color = Color(tbl.color.r, tbl.color.g, tbl.color.b, tbl.color.a)
    else rank.color = Color(255, 255, 255) end

    -- Restrictions are for the spawn menu. Acts as a blacklist unless the rank access is "Restricted". Entities, Weapons, Vehicles, etc get put in here.
    rank.restrictions = (istable(tbl.restrictions) and table.IsSequential(tbl.restrictions)) and tbl.restrictions or {}

    -- Privileges are for nadmin features, acts as a whitelist. Commands, permissions, tabs, etc get put in here.
    rank.privileges   = (istable(tbl.privileges)   and table.IsSequential(tbl.privileges))   and tbl.privileges   or {}

    nadmin.ranks[rank.id] = table.Copy(rank)
    -- MsgN("Registered Rank: " .. rank.title .. " | " .. rank.id)
    return nadmin.ranks[rank.id]
end

function nadmin:RegisterPerm(tbl)
    if not istable(tbl) then return end
    local perm = table.Copy(tbl or {})

    perm.title = isstring(tbl.title) and tbl.title or "Undefined"
    perm.id    = isstring(tbl.id)    and tbl.id    or string.lower(string.Replace(perm.title, " ", "_"))

    perm.category = isstring(tbl.category) or "Uncategorized"
    -- subCategory can also be defined as a string

    if perm.forcedPriv then
        self.forcedPrivs[perm.id] = true
    elseif SERVER and nadmin.serverInitialized then
        if isnumber(perm.defaultAccess) then
            -- If there is a default access set, it should only apply the first time the permission is registered
            if table.HasValue(nadmin.defaultPermData, perm.id) then return end

            for id, rank in pairs(nadmin.ranks) do 
                if rank.access < perm.defaultAccess then continue end
                if table.HasValue(rank.privileges, perm.id) then continue end
                table.insert(rank.privileges, perm.id)
            end

            table.insert(nadmin.defaultPermData, perm.id)
            nadmin:SaveDefaultPermData()
            nadmin:SaveRanks()
            nadmin:SendRanksToClients()
        end
    end

    nadmin.perms[perm.id] = table.Copy(perm)

    -- MsgN("Registered Permission: " .. perm.title .. " | " .. perm.id)
    return nadmin.perms[perm.id]
end

function nadmin:FindRank(id)
    if istable(nadmin.ranks[id]) then return nadmin.ranks[id] end
    for i, rank in pairs(nadmin.ranks) do
        if string.lower(id) == string.lower(rank.title) then return rank end
    end
    return nadmin.null_rank
end

function nadmin:RankBetterThan(c, t)
    if istable(c) and istable(t) then 
        if c.access == t.access then 
            return c.immunity > t.immunity
        else
            return c.access > t.access
        end
    end
    return false
end
function nadmin:RankBetterThanOrEqual(c, t)
    if istable(c) and istable(t) then 
        if c.access == t.access then 
            return c.immunity >= t.immunity
        else
            return c.access > t.access
        end
    end
    return false
end

function nadmin:DefaultRankDeprecated()
    ranks = {}
    for i, rank in pairs(nadmin.ranks) do --Convert to numeric indexed table (for `ipairs()`)
        table.insert(ranks, rank)
    end
    table.sort(ranks, function(a, b) return a.immunity < b.immunity end)
    return ranks[1]
end

function nadmin:DefaultRank()
    for id, rank in pairs(nadmin.ranks) do
        if rank.access == nadmin.access.default then
            return rank
        end
    end
    return nadmin.null_rank
end