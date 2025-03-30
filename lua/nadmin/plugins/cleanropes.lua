local cmd = {}
cmd.title = "Cleanup Ropes"
cmd.description = "Cleanup all ropes."
cmd.author = "Nub"
cmd.timeCreated = "Tuesday, June 29 2021 @ 10:36 AM CST"
cmd.category = "Utility"
cmd.call = "cleanropes"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    if not istable(nadmin.pp) then 
        nadmin:Notify(caller, nadmin.colors.red, "The prop protection module is disabled, this won't work.")
    end
    local count = nadmin.pp.CleanWorldRopes()

    local nameCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
    nadmin:Notify(nameCol, caller:Nick(), nadmin.colors.white, " has cleaned up world ropes (", nadmin.colors.blue, count, nadmin.colors.white, ").")
end

nadmin:RegisterCommand(cmd)
