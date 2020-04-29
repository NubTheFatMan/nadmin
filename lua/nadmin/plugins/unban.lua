local cmd = {}
cmd.title = "Unban"
cmd.description = "Remove a ban from a Steam ID or IP address."
cmd.author = "Nub"
cmd.timeCreated = "Apr. 3, 2020 @ 8:17 PM CST"
cmd.category = "Player Management"
cmd.usage = "{Steam ID | IP}"
cmd.call = "unban"

cmd.server = function(caller, args, advArgs)
    if #args > 0 then
        local id = args[1]

        if not caller:HasPerm("ip_ban") and not string.match(id, nadmin.config.steamIDMatch) then
            nadmin:Notify(caller, nadmin.colors.red, "Invalid Steam ID; you don't have permission to IP unban.")
            return
        end

        if istable(nadmin.bans[id]) then
            local nick = isstring(nadmin.bans[id].targ_nick) and nadmin.bans[id].targ_nick or "[Unknown]"
            if istable(nadmin.userdata[id]) and string.match(id, nadmin.config.steamIDMatch) then
                nick = nadmin.userdata[id].lastJoined.name
            end
            nadmin:Unban(id)

            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
            local tCol = nadmin:GetNameColor(id) or nadmin.colors.red

            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has unbanned ", tCol, nick, nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "There isn't a ban in place with this Steam ID or IP address.")
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, "First argument must be either a Steam ID or IP address.")
    end
end

cmd.advUsage = {
    {
        type = "string",
        text = "Steam ID / IP"
    }
}

nadmin:RegisterCommand(cmd)
