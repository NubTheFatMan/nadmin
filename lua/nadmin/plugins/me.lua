local COMMAND = {}
COMMAND.title = "Me"
COMMAND.description = "Represents you doing an action."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, April 17, 2020 @ 10:27 PM"
COMMAND.category = "Fun"
COMMAND.call = "me"
COMMAND.usage = "{action}"
COMMAND.server = function(caller, args)
    if #args > 0 then
        nadmin.SilentNotify = false
        nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " ", table.concat(args, " "))
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

COMMAND.advUsage = {
    {
        type = "string",
        text = "Action"
    }
}

nadmin:RegisterCommand(COMMAND)
