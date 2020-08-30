function nadmin:GetBanReason(id) -- Inspired by ULX. You will notice a huge similarity (basically copied)
    if not istable(nadmin.bans[id]) then return end
    local ban = table.Copy(nadmin.bans[id])

    local rep = {
        BANNED_BY  = "[Unknown]",
        STEAMID    = "[Unknown]",
        BAN_DATE   = "[Unknown]",
        TIME_LEFT  = "[Infinity]",
        BAN_DUR    = "[Permanent]",
        UNBAN_DATE = "[Never]",
        REASON     = "No reason given."
    }

    if isstring(ban.by) and ban.by ~= "" then
        rep.BANNED_BY = ban.by
    end
    if isstring(ban.by_steamid) and ban.by_steamid ~= "" then
        rep.STEAMID = ban.by_steamid
    end

    if isnumber(ban.start) then
        rep.BAN_DATE = os.date("%m/%d/%y %H:%M:%S", ban.start)
    end

    if isnumber(ban.dur) and ban.dur > 0 then
        rep.BAN_DUR = nadmin:TimeToString(ban.dur, true)
    end

    if isnumber(ban.start) and isnumber(ban.dur) and ban.dur > 0 then
        rep.TIME_LEFT  = nadmin:TimeToString((ban.start + ban.dur) - os.time(), true)
        rep.UNBAN_DATE = os.date("%m/%d/%y %H:%M:%S", ban.start + ban.dur)
    end

    if isstring(ban.reason) and ban.reason ~= "" then
        rep.REASON = ban.reason
    end

    return string.gsub(nadmin.config.banMessage, "{{([%w_]+)}}", rep)
end

function nadmin:BanAsID(name, steamid, by, by_id, reason, dur)
    if not isstring(steamid) then return end

    local ban = {}
    if isstring(by) then
        ban.by = by
    end
    if isstring(by_id) then
        ban.by_steamid = by_id
    end

    if isstring(reason) then
        ban.reason = reason
    end
    if isnumber(dur) then
        ban.dur = dur
    end

    ban.start = os.time()

    ban.targ_nick = name
    ban.targ_id = steamid

    nadmin.bans[steamid] = table.Copy(ban)

    local banMsg
    for i, ply in ipairs(player.GetAll()) do
        if ply:SteamID() == steamid or ply:IPAddress() == steamid then
            if not isstring(banMsg) then banMsg = nadmin:GetBanReason(steamid) end
            local nick = ply:Nick()
            ply:RemoveProps()
            nadmin.SilentNotify = true -- Don't show people the ban reason, and instead just show that they were disconencted from a ban.
            ply:Kick(banMsg)
            nadmin:Notify(nadmin.colors.blue, nick, nadmin.colors.white, " has been disconnected from a ban.")
        end
    end

    nadmin:Log("messages", '"' .. steamid .. "\" has been banned.")

    nadmin:SaveBans()
end

function nadmin:Ban(name, steamid, by, reason, dur)
    if not isstring(steamid) then return end

    local ban = {}
    if isentity(by) and by:IsPlayer() then
        ban.by = by:Nick()
        ban.by_steamid = by:SteamID()
    elseif isstring(by) then
        ban.by = by
        ban.by_steamid = by
    end

    if isstring(reason) then
        ban.reason = reason
    end
    if isnumber(dur) then
        ban.dur = dur
    end

    ban.start = os.time()

    ban.targ_nick = name
    ban.targ_id = steamid

    nadmin.bans[steamid] = table.Copy(ban)

    local banMsg
    for i, ply in ipairs(player.GetAll()) do
        if ply:SteamID() == steamid or ply:IPAddress() == steamid then
            if not isstring(banMsg) then banMsg = nadmin:GetBanReason(steamid) end
            local nick = ply:Nick()
            ply:RemoveProps()
            nadmin.SilentNotify = true -- Don't show people the ban reason, and instead just show that they were disconencted from a ban.
            ply:Kick(banMsg)
            nadmin:Notify(nadmin.colors.blue, nick, nadmin.colors.white, " has been disconnected from a ban.")
        end
    end

    nadmin:Log("messages", '"' .. steamid .. "\" has been banned.")

    nadmin:SaveBans()
end

function nadmin:Unban(id, noSave)
    if istable(nadmin.bans[id]) then
        nadmin.bans[id] = nil
        if not noSave then
            nadmin:SaveBans()
        end
    end
end

hook.Add("Think", "nadmin_auto_unban", function() -- Auto unban after duration is up
    local keys = table.GetKeys(nadmin.bans) -- We are going to be looping backwards instead of forwards
    local now = os.time()

    -- Only save the bans file if someone was unbanned.
    local changes = false

    for i = #keys, 1, -1 do
        local ban = nadmin.bans[keys[i]]
        if isnumber(ban.dur) and ban.dur > 0 and ban.start + ban.dur <= now then
            changes = true
            nadmin:Unban(keys[i], true)
        end
    end

    -- Save if changed
    if changes then
        nadmin:SaveBans()
    end
end)
