local COMMAND = {}
COMMAND.title = "MOTD"
COMMAND.description = "Open the Message Of The Day Popup."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, September 1st, 2020 @ 12:10 PM"
COMMAND.category = "Menu"
COMMAND.call = "motd"

COMMAND.server = function(caller, args)
    if not caller:Nadmin_OpenMOTD() then
        nadmin:Notify(caller, nadmin.colors.red, "The MOTD is currently disabled by server administration.")
    end
end

nadmin:RegisterCommand(COMMAND)
