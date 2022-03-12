hook.Add("CheckPassword", "nadmin_disconnect_bans", function(id64, ip, svPass, clPass, nick)
    local steamID = util.SteamIDFrom64(id64)

    local hasID = istable(nadmin.bans[steamID])
    local hasIP = istable(nadmin.bans[ip])

    if hasID or hasIP then
        local banReason
        if hasID then
            banReason = nadmin:GetBanReason(steamID)
        else
            banReason = nadmin:GetBanReason(ip)
        end

        nadmin:Log("messages", nick .. " (" .. steamID .. ")<" .. ip .. "> attempted to connect to the server, however was unable to due to their ban.")
        return false, banReason
    end
end)

--We are using this so we can kick players while they are joining, such as reserved admin slots
gameevent.Listen("player_connect")
hook.Add("player_connect", "nadmin_connect", function(ply)
    local tCol = nadmin:GetNameColor(ply.networkid) or nadmin:DefaultRank().color

    local data = nadmin.userdata[ply.networkid]

    local name = ply.name 
    if istable(data) then 
        if isstring(data.name) and data.name ~= "" then 
            name = data.name
        end
    end

    if nadmin.plugins.joinMessages then
        nadmin:Notify(tCol, name, nadmin.colors.white, " (", tCol, ply.networkid, nadmin.colors.white, ") has connected to the server.")
    end
    nadmin:Log("messages", ply.name .. " (" .. ply.networkid .. ")<" .. ply.address .. "> has connected to the server.")
end)

hook.Add("PlayerInitialSpawn", "nadmin_spawn", function(ply)
    -- If they were banned while joining, we want to waste their time and
    -- kick them once they spawn :^)

    local hasID = istable(nadmin.bans[ply:SteamID()])
    local hasIP = istable(nadmin.bans[ply:IPAddress()])

    if hasID or hasIP then
        local banReason
        if hasID then
            banReason = nadmin:GetBanReason(ply:SteamID())
        else
            banReason = nadmin:GetBanReason(ply:IPAddress())
        end

        local tCol = nadmin:GetNameColor(ply:SteamID()) or nadmin:DefaultRank().color

        nadmin:Notify(tCol, ply:Nick(), nadmin.colors.white, " has been disconnected from a ban.")

        timer.Simple(0.5, function()
            nadmin.SilentNotify = true
            ply:Kick(banReason)
        end)

        return
    end

    --Set their data
    if not ply:IsBot() then
        ply:CheckData()
        timer.Simple(1, function()
            ply:Nadmin_OpenMOTD()
        end)
        if istable(nadmin.userdata[ply:SteamID()]) then
            local data = nadmin.userdata[ply:SteamID()]

            local rank = data.rank
            if data.rank == "" or data.rank == "NULL" then 
                rank = nadmin:DefaultRank()
            end

            ply:SetRank(rank)
            ply:SetPlayTime(data.playtime or 0)
            ply:SetLevel(data.level.lvl or 1, data.level.xp or 0)
            if isstring(data.forcedName) and data.forcedName ~= "" then ply:SetNick(data.forcedName, true) end

            -- This is done incase they leave before they are saved.
            data.lastJoined.name = ply:Nick()
            data.lastJoined.when = os.time()
        else
            local defRank = nadmin:DefaultRank()
            ply:SetRank(defRank)
            ply:SetPlayTime(0)
            ply:SetLevel(1)
            nadmin.userdata[ply:SteamID()].lastJoined.name = ply:Nick()
        end

        -- Add this new player to the save table
        -- I check for duplicates incase they relogged
        if not table.HasValue(nadmin.plyToSave, ply:SteamID()) then
            table.insert(nadmin.plyToSave, ply:SteamID())
        end

        if isstring(nadmin.needs_update) then
            timer.Simple(5, function() -- Wait for them to spawn in
                nadmin:Notify(ply, nadmin.colors.red, "Nadmin (administration mod) is out of date!")
                nadmin:Notify(ply, nadmin.colors.red, "Current version: " .. nadmin.version)
                nadmin:Notify(ply, nadmin.colors.red, "Latest version: " .. nadmin.needs_update)
            end)
        end
    else
        ply:SetRank(nadmin:DefaultRank())
        ply:SetPlayTime(0)
        ply:SetLevel(1)
    end

    local lastLeft = 0
    local lastName = ply:Nick()
    local user = nadmin.userdata[ply:SteamID()]
    if user then
        lastLeft = user.lastJoined.when
        lastName = user.lastJoined.name
    end

    local now = os.time()
    local time = now - lastLeft
    local first = false
    if time == now then first = true end

    local col = nadmin:GetNameColor(ply)
    if not first then
        local t = nadmin:FormatTime(time)
        if lastName == ply:Nick() or lastName == "" then
            if nadmin.plugins.joinMessages then
                nadmin:Notify(col, ply:Nick(), nadmin.colors.white, " (", col, ply:SteamID(),  nadmin.colors.white, ") last joined ", nadmin.colors.red, t .. " ago", nadmin.colors.white, ".")
            end
            nadmin:Log("messages", ply:Nick() .. " (" .. ply:SteamID() .. ")<" .. ply:IPAddress() .. "> last joined " .. t .. " ago.")
        else
            if nadmin.plugins.joinMessages then
                nadmin:Notify(col, ply:Nick(), nadmin.colors.white, " (", col, ply:SteamID(),  nadmin.colors.white, ") last joined ", nadmin.colors.red, t .. " ago", nadmin.colors.white, " as ", col, lastName, nadmin.colors.white, ".")
            end
            nadmin:Log("messages", ply:Nick() .. " (" .. ply:SteamID() .. ")<" .. ply:IPAddress() .. "> last joined " .. t .. " ago as " .. lastName .. ".")
        end
    else
        if nadmin.plugins.joinMessages then
            nadmin:Notify(col, ply:Nick(), nadmin.colors.white, " (", col, ply:SteamID(), nadmin.colors.white, ") has joined for the first time.")
        end
        nadmin:Log("messages", ply:Nick() .. " (" .. ply:SteamID() .. ")<" .. ply:IPAddress() .. "> has joined for the first time.")
    end

    net.Start("nadmin_send_register")
        net.WriteTable(nadmin.entities)
        net.WriteTable(nadmin.npcs)
        net.WriteTable(nadmin.tools)
        net.WriteTable(nadmin.vehicles)
        net.WriteTable(nadmin.weapons)
        net.WriteTable(nadmin.maps)
    net.Send(ply)

    nadmin:SendRanksToClients()
end)

hook.Add("PlayerDisconnected", "nadmin_player_freeze_ban", function(ply)
    local banned = ply:GetNWBool("FrozenBanned")
    local banner = ply:GetNWEntity("FrozenBanner")

    if banned and IsValid(banner) then
        nadmin:Notify(nadmin:GetNameColor(ply:SteamID()) or nadmin:DefaultRank().color, ply:Nick(), nadmin.colors.white, " has been banned.")
        nadmin:Ban(ply:Nick(), ply:SteamID(), banner, "Leaving while frozen banned.", 0)
    end
end)

gameevent.Listen("player_disconnect")
hook.Add("player_disconnect", "nadmin_disconnect", function(ply)
	local name = ply.name
	local steamid = ply.networkid
	local reason = ply.reason

    local col = nadmin:GetNameColor(steamid) or nadmin:DefaultRank().color

    -- Leaving during a voteban
    if reason == "Disconnect by user." then -- Only ban if it was a purposeful disconnect (not a crash)
        local ban = nadmin.voteBans[steamid]
        if ban ~= nil then
            nadmin:BanAsID(name, steamid, ban[1], ban[2], "Leaving during voteban against you.", 3600)
            nadmin:Notify(col, name, nadmin.colors.white, " has been banned for an hour for leaving to avoid punishment.")
            return
        end
    end

    if nadmin.plugins.joinMessages then
        nadmin:Notify(col, name, nadmin.colors.white, " (", col, steamid,  nadmin.colors.white, ") has disconnected (", nadmin.colors.blue, reason, nadmin.colors.white, ").")
    end
    nadmin:Log("messages", name .. " (" .. steamid .. ") has disconnected (" .. reason .. ").")

    if not istable(nadmin.userdata[steamid]) then
        nadmin.userdata[steamid] = table.Copy(nadmin.defaults.userdata)
    end
    nadmin.userdata[steamid].lastJoined.when = os.time()
    nadmin.userdata[steamid].lastJoined.name = name
end)
