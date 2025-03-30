local cmd = {}
cmd.title = "Reload Command"
cmd.description = "Reload a command."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 26 2019 @ 9:08 PM CST"
cmd.category = "Server Management"
cmd.call = "reload"
cmd.usage = "{file}"
cmd.defaultAccess = nadmin.access.superadmin
cmd.server = function(caller, args)
    if #args > 0 then
        local succ = nadmin:ReloadCommand(args[1])
        if succ then
            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has reloaded command ", nadmin.colors.red, args[1], nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "Error including file.")
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, "You need one argument.")
    end
end

cmd.advUsage = {
    {
        type = "string",
        text = "file"
    }
}

nadmin:RegisterCommand(cmd)
