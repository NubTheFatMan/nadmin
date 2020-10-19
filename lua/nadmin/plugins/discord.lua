local COMMAND = {}
COMMAND.title = "Discord Invitation"
COMMAND.description = "Open the Discord invitation."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, September 1st, 2020 @ 8:53 PM"
COMMAND.category = "Menu"
COMMAND.call = "discord"

COMMAND.url = "https://discord.gg/pjbemj4"

COMMAND.client = function(caller, args)
    gui.OpenURL(COMMAND.url)
end

nadmin:RegisterCommand(COMMAND)
