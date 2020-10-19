local COMMAND = {}
COMMAND.title = "Addons"
COMMAND.description = "Open the workshop collection."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, September 1st, 2020 @ 8:53 PM"
COMMAND.category = "Menu"
COMMAND.call = "addons"

COMMAND.url = "https://steamcommunity.com/sharedfiles/filedetails/?id=2029284539"

COMMAND.client = function(caller, args)
    gui.OpenURL(COMMAND.url)
end

nadmin:RegisterCommand(COMMAND)
