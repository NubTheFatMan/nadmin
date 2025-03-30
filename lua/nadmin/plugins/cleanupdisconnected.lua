local cmd = {}
cmd.title = "Cleanup Disconnected Players"
cmd.description = "Cleanup all the props of players who left the server. For this to work, you must have the prop protection module enabled."
cmd.author = "Nub"
cmd.timeCreated = "Tuesday, June 29 2021 @ 10:22 AM CST"
cmd.category = "Utility"
cmd.call = "cleanupdisconnected"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    if not istable(nadmin.pp) then 
        nadmin:Notify(caller, nadmin.colors.red, "The prop protection module is disabled, this won't work.")
    end
    local count = nadmin.pp.CDP()

    local nameCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
    nadmin:Notify(nameCol, caller:Nick(), nadmin.colors.white, " has cleaned up disconnected player's props (", nadmin.colors.blue, count, nadmin.colors.white, ").")
end

nadmin:RegisterCommand(cmd)
