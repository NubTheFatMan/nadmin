local cmd = {}
cmd.title = "Announce"
cmd.description = "Send an announcement to all the players on the server."
cmd.author = "Nub"
cmd.timeCreated = "Apr. 1 2020 @ 3:01 PM CST"
cmd.category = "Utility"
cmd.call = "announce"
cmd.usage = "[duration] {message}"
cmd.server = function(caller, args)
    local numArgs = #args
    if numArgs == 0 then 
        return nadmin:Notify(caller, nadmin.colors.red, "You need at least one argument.")
    elseif numArgs == 1 then 
        return nadmin:Notify(caller, nadmin.colors.red, "You must specify an announcement message.")
    end

    local dur = nadmin:ParseTime(table.remove(args, 1))
    if not isnumber(dur) then 
        return nadmin:Notify(caller, nadmin.colors.red, "First argument must be the duration.")
    end

    if dur >= 1 then
        nadmin:Announce(table.concat(args, " "), dur)
        nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has made an announcement.")
    else
        nadmin:Notify(caller, nadmin.colors.red, "The duration must be at least 1 second.")
    end
end

cmd.advUsage = {
    {
        type = "time",
        text = "Duration"
    },
    {
        type = "string",
        text = "Action"
    }
}

nadmin:RegisterCommand(cmd)
