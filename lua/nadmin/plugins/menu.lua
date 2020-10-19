local COMMAND = {}
COMMAND.title = "Menu"
COMMAND.description = "Open the menu for Nadmin."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, June 13, 2019 @ 10:36 PM"
COMMAND.category = "Menu"
COMMAND.call = "menu"

COMMAND.client = function(caller, args)
    nadmin.menu:Open()
end

nadmin:RegisterCommand(COMMAND)
