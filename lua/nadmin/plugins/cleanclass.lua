local cmd = {}
cmd.title = "Cleanup Class"
cmd.description = "Cleanup a specific class of entities from the server."
cmd.author = "Nub"
cmd.timeCreated = "Tuesday, June 29 2021 @ 10:32 AM CST"
cmd.category = "Utility"
cmd.call = "cleanclass"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    if not istable(nadmin.pp) then 
        nadmin:Notify(caller, nadmin.colors.red, "The prop protection module is disabled, this won't work.")
    end

    local cleaned = args[1]
    if not isstring(cleaned) then 
        nadmin:Notify(caller, nadmin.colors.red, "You must list a class.")
        return
    end

    local count = nadmin.pp.CleanClass(cleaned)
    if cleaned == "npc_*" then cleaned = "all NPCs" end
    if cleaned == "prop_ragdol*" then cleaned = "all ragdolls" end

    local nameCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
    nadmin:Notify(nameCol, caller:Nick(), nadmin.colors.white, " has cleaned up class ", nadmin.colors.blue, cleaned, nadmin.colors.white, " (", nadmin.colors.blue, count, nadmin.colors.white, ").")
end

nadmin:RegisterCommand(cmd)
