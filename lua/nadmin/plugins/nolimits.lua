local COMMAND = {}
COMMAND.title = "Remove Limits"
COMMAND.description = "Removes prop limits, as well as any other type of limit from a player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Wednesday, July 14, 2021 @ 8:09 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "nolimits"

local notLimiting = {}
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local granted = {}
        local revoked = {}
        for i, ply in ipairs(targs) do
            if tonumber(args[2]) then
                local en = nadmin:IntToBool(tonumber(args[2]))
                if en then
                    table.insert(granted, ply) 
                    if not table.HasValue(notLimiting, ply) then 
                        table.insert(notLimiting, ply)
                    end
                else
                    table.insert(revoked, ply)
                    table.RemoveByValue(notLimiting, ply)
                end
            else
                if table.HasValue(notLimiting, ply) then
                    table.insert(revoked, ply)
                    table.RemoveByValue(notLimiting, ply)
                else
                    table.insert(granted, ply)
                    table.insert(notLimiting, ply)
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #granted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has removed limits from "}
            table.Add(msg, nadmin:FormatPlayerList(granted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

        end
        if #revoked > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has reset limits on "}
            table.Add(msg, nadmin:FormatPlayerList(revoked, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
    end
end

hook.Add("PlayerCheckLimit", "nadmin_no_limits", function(ply, limitName, current, defMax)
    if table.HasValue(notLimiting, ply) or ply:HasPerm("no_limits") then return true end
end)

nadmin:RegisterPerm({
    title = "No Limits"
})

nadmin:RegisterCommand(COMMAND)