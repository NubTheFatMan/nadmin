local cmd = {}
cmd.title = "Ban"
cmd.description = "Ban a player from the server for a certain amount of time."
cmd.author = "Nub"
cmd.timeCreated = "Apr. 1, 2020 @ 9:19 PM CST"
cmd.category = "Player Management"
cmd.usage = "<player> [duration] {reason}"
cmd.call = "ban"

nadmin:RegisterPerm({
    title = "IP Ban"
})

cmd.server = function(caller, args, advArgs)
    if #args == 0 then
        if IsValid(caller) then
            nadmin:Notify(caller, nadmin.colors.red, "You need at least one argument.")
        else
            MsgN("[Nadmin]You need at least one argument for 'nadmin ban'")
        end
        return
    end

    table.remove(advArgs.__unindexed, 1)
    local id
    if advArgs.id then
        id = table.concat(advArgs.id, " ")
    else
        id = table.remove(advArgs.__unindexed, 1)
    end

    if IsValid(caller) then
        if not string.match(id, nadmin.config.steamIDMatch) and not caller:HasPerm("ip_ban") then
            nadmin:Notify(caller, nadmin.colors.red, "You aren't allowed to ban by IP.")
            return
        end
    end

    local targ = nadmin:FindPlayer(id, caller or nil, nadmin.MODE_BELOW)

    if #targ > 1 then
        if IsValid(caller) then
            nadmin:Notify(caller, nadmin.colors.red, "Did you mean ", nadmin.colors.white, nadmin:FormatPlayerList(targ, "or"), nadmin.colors.red, "?")
        else
            MsgN("[Nadmin]Did you mean " .. nadmin:FormatPlayerList(targ, "or") .. "?")
        end
        return
    end

    if #targ == 1 then id = targ[1]:SteamID() end

    if IsValid(caller) then
        if type(targ[1]) == "Player" and targ[1]:BetterThanOrEqual(caller) then
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
            return
        end
    end

    local data = nadmin.userdata[id]
    if IsValid(caller) then
        local call_rank = caller:GetRank()
        if istable(data) then
            local r = nadmin:FindRank(data.rank)
            if istable(r) and r.immunity >= call_rank.immunity then
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
                return
            end
        end
    end

    local time
    if advArgs.duration then
        time = nadmin:ParseTime(table.concat(advArgs.duration, " "))
    else
        time = nadmin:ParseTime(advArgs.__unindexed[1])
    end
    if not isnumber(time) then
        time = 0
    else
        table.remove(advArgs.__unindexed, 1)
    end

    local reason
    if advArgs.reason then
        reason = table.concat(advArgs.reason, " ")
    else
        reason = table.concat(advArgs.__unindexed, " ")
    end

    local nick = (IsValid(targ[1]) and targ[1]:Nick() == id) and targ[1]:Nick() or (istable(data) and data.lastJoined.name or nil)
    if advArgs.nick then
        nick = table.concat(advArgs.nick, " ")
    end

    local match = string.match(id, nadmin.config.steamIDMatch)
    if not isstring(nick) and match then
        nick = match
    end

    nadmin:Ban(nick, id, IsValid(caller) and caller or "[CONSOLE]", reason, time)

    local banCol = nadmin:GetNameColor(id)
    if not banCol then banCol = nadmin.colors.red end

    local callCol = nadmin:GetNameColor(caller)
    if not callCol then callCol = nadmin.colors.blue end

    nadmin:Notify(callCol, caller:Nick(), nadmin.colors.white, " has banned ", banCol, nick or "[Unkown]", nadmin.colors.white, ".")
    nadmin:Log("administration", (IsValid(caller) and caller:PlayerToString("nick (steamid)<ipaddress>") or "[CONSOLE]") .. " has banned " .. (nick or id))
end

local dis = Material("icon16/disconnect.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    },
    {
        text = "Time (0 for indefinitely)",
        type = "time",
        default = 0
    },
    {
        text = "Reason",
        type = "string"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(dis)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
