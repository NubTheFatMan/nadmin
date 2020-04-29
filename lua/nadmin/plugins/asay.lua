local COMMAND = {}
COMMAND.title = "Admin Say"
COMMAND.description = "Sends a message to all connected admins (ranks with permission to view)."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Sunday, April 26, 2020 @ 8:13 PM"
COMMAND.category = "Utility"
COMMAND.call = "asay"
COMMAND.usage = "{message}"
COMMAND.server = function(caller, args)
    if #args > 0 then
        local plys = {}
        for i, ply in ipairs(player.GetHumans()) do
            if ply == caller then continue end -- Prevent caller being on there twice
            if ply:HasPerm("view_admin_messages") then table.insert(plys, ply) end
        end

        table.insert(plys, caller) -- The caller should be able to see it

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #plys > 0 then
            for i, ply in ipairs(plys) do
                nadmin:Notify(ply, myCol, caller:Nick(), nadmin.colors.white, " to ", nadmin.colors.red, "admins", nadmin.colors.white, ": ", nadmin.colors.blue, table.concat(args, " "))
            end
        end

    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

COMMAND.advUsage = {
    {
        type = "string",
        text = "Message"
    }
}

nadmin:RegisterPerm({
    title = "View Admin Messages"
})

nadmin:RegisterCommand(COMMAND)
