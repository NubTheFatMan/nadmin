function nadmin:RegisterRank(tbl)
    local rank = tbl or {}

    rank.title       = isstring(tbl.title)      and tbl.title       or "Undefined"
    rank.id          = isstring(tbl.id)         and tbl.id          or string.lower(string.Replace(rank.title, " ", "_"))
    rank.icon        = isstring(tbl.icon)       and tbl.icon        or "icon16/user.png"
    rank.immunity    = isnumber(tbl.immunity)   and tbl.immunity    or nadmin.immunity.everyone
    rank.ownerRank   = isbool(tbl.ownerRank)    and tbl.ownerRank   or false
    rank.autoPromote = istable(tbl.autoPromote) and tbl.autoPromote or {when = 0, rank = "", enabled = false}

    -- Default gmod loadout
    rank.loadout = (istable(tbl.loadout) and table.IsSequential(tbl.loadout)) and tbl.loadout, {"weapon_crowbar", "weapon_physcannon", "weapon_physgun", "weapon_pistol", "weapon_357", "weapon_smg1", "weapon_ar2", "weapon_shotgun", "weapon_crossbow", "weapon_frag", "weapon_rpg", "gmod_camera", "gmod_tool"}

    if IsColor(tbl.color) then rank.color = tbl.color
    elseif istable(tbl.color) then rank.color = Color(tbl.color.r, tbl.color.g, tbl.color.b, tbl.color.a)
    else rank.color = Color(255, 255, 255) end

    rank.restrictions = (istable(tbl.restrictions) and table.IsSequential(tbl.restrictions)) and tbl.restrictions or {}
    rank.privileges   = (istable(tbl.privileges)   and table.IsSequential(tbl.privileges))   and tbl.privileges   or {}

    nadmin.ranks[rank.id] = table.Copy(rank)
    -- MsgN("Registered Rank: " .. rank.title .. " | " .. rank.id)
    return nadmin.ranks[rank.id]
end

function nadmin:RegisterPerm(tbl)
    local perm = tbl
    if not istable(perm) then return end

    perm.title = isstring(tbl.title) and tbl.title or "Undefined"
    perm.id    = isstring(tbl.id)    and    tbl.id or string.lower(string.Replace(perm.title, " ", "_"))

    if perm.forcedPriv then
        self.forcedPrivs[perm.id] = true
    end

    nadmin.perms[perm.id] = perm

    -- MsgN("Registered Permission: " .. perm.title .. " | " .. perm.id)
    return nadmin.perms[perm.id]
end

function nadmin:FindRank(id)
    if istable(nadmin.ranks[id]) then return nadmin.ranks[id] end
    for i, rank in pairs(nadmin.ranks) do
        if string.lower(id) == string.lower(rank.title) then return rank end
    end
end

function nadmin:DefaultRank()
    ranks = {}
    for i, rank in pairs(nadmin.ranks) do --Convert to numeric indexed table (for `ipairs()`)
        table.insert(ranks, rank)
    end
    table.sort(ranks, function(a, b) return a.immunity < b.immunity end)
    return ranks[1]
end
