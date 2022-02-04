local COMMAND = {}
COMMAND.title = "Test"
COMMAND.call = "test"

-- COMMAND.server = function(caller, args)
--     nadmin:Notify(nadmin.colors.white, "Connected players: ", nadmin.colors.red, nadmin:FormatPlayerList(player.GetAll(), "and"), nadmin.colors.white, ".")
-- end
COMMAND.client = function(caller, args)
    LocalPlayer():ConCommand("disconnect")
end

-- nadmin:RegisterCommand(COMMAND)
