local cmd = {}
cmd.title = "PVP Mode"
cmd.description = "Switch to PVP mode (you can kill others that are in PVP mode)."
cmd.author = "Nub"
cmd.timeCreated = "Tuesday, August 25 2020 @ 12:46 AM CT"
cmd.category = "Utility"
cmd.call = "pvp"
cmd.server = function(caller, args)
    if IsValid(caller) then
        if caller.n_BuildMode then
            caller.n_BuildMode = false
            caller:Spawn()
            nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " has entered pvp mode.")
        else
            nadmin:Notify(caller, nadmin.colors.red, "You are already in PVP mode.")
        end
    else
        MsgN("[Nadmin]You can't play in pvp mode as console.")
    end
end

nadmin:RegisterCommand(cmd)
