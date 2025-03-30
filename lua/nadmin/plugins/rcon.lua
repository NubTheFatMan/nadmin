local cmd = {}
cmd.title = "RCON"
cmd.description = "Run a command on the console through your client. This is a dangerous permission to grant as someone could basically hijack your server. Only allow ranks who are given complete trust."
cmd.author = "Nub"
cmd.timeCreated = "Sunday, May 24 2020 @ 12:32 AM CST"
cmd.category = "Server Management"
cmd.call = "rcon"
cmd.usage = "{command}"
cmd.defaultAccess = nadmin.access.superadmin
cmd.server = function(caller, args)
    if #args > 0 then
        local col = nadmin:GetNameColor(caller) or nadmin.colors.blue
        nadmin:Notify(col, caller:Nick(), nadmin.colors.white, " has rconned ", nadmin.colors.red, table.concat(args, " "), nadmin.colors.white, ".")
        game.ConsoleCommand(table.concat(args, " ") .. "\n")
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

cmd.advUsage = {
    {
        type = "string",
        text = "Command",
    }
}

nadmin:RegisterCommand(cmd)
