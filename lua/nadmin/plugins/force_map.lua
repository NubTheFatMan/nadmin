local COMMAND = {}
COMMAND.title = "Force Map"
COMMAND.description = "Force a map change."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, March 25, 2021 @ 11:12 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "map"
COMMAND.usage = "[map name/index]"
COMMAND.defaultAccess = nadmin.access.admin

nadmin.votemapChange = true

COMMAND.server = function(caller, args)
    local index = tonumber(args[1])
    local map
    if isnumber(index) and index > 0 and index <= #nadmin.maps then 
        map = nadmin.maps[index]
    elseif table.HasValue(nadmin.maps, string.lower(args[1])) then 
        for i, m in ipairs(nadmin.maps) do
            if m == args[1] then map = m break end
        end
    end

    if map then 
        game.ConsoleCommand("changelevel " .. map .. "\n")
    else 
        nadmin:Notify(caller, nadmin.colors.red, "Invalid map specified.")
    end
end

nadmin:RegisterCommand(COMMAND)