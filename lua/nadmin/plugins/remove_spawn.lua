local cmd = {}
cmd.title = "Remove Spawn"
cmd.description = "Remove your spawn point."
cmd.author = "Nub"
cmd.timeCreated = "Sunday, May 24 2020 @ 12:58 AM CT"
cmd.category = "Utility"
cmd.call = "removespawn"
cmd.defaultAccess = nadmin.access.default
cmd.server = function(caller, args)
    if IsValid(caller) then
        if isvector(caller.n_SpawnPoint) then
            caller.n_SpawnPoint = nil
            caller.n_SpawnEye = nil
            nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " has removed their spawn point.")
        else
            nadmin:Notify(caller, nadmin.colors.red, "You don't have a spawn point set.")
        end
    else
        MsgN("[Nadmin]You can't set your spawn as console.")
    end
end

nadmin:RegisterCommand(cmd)
