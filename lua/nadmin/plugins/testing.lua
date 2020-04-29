local COMMAND = {}
COMMAND.title = "Test"
COMMAND.call = "test"

-- COMMAND.server = function(caller, args)
--     nadmin:Notify(nadmin.colors.white, "Connected players: ", nadmin.colors.red, nadmin:FormatPlayerList(player.GetAll(), "and"), nadmin.colors.white, ".")
-- end
COMMAND.client = function(caller, args)
    local panel = nadmin.vgui:DPanel({0, 0}, {25, 25})
    timer.Simple(1, function() panel:Remove() end)
end

-- nadmin:RegisterCommand(COMMAND)
