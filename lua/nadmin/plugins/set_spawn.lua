local cmd = {}
cmd.title = "Set Spawn"
cmd.description = "Set a spawn point for yourself."
cmd.author = "Nub"
cmd.timeCreated = "Sunday, May 24 2020 @ 12:48 AM CT"
cmd.category = "Utility"
cmd.call = "setspawn"
cmd.server = function(caller, args)
    if IsValid(caller) then
        if caller:Alive() then
            if not caller.n_BuildMode then
                caller.n_SpawnPoint = caller:GetPos()
                caller.n_SpawnEye = caller:EyeAngles()
                nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " has set their spawn point.")
            else
                nadmin:Notify(caller, nadmin.colors.red, "You don't have a reason to set your spawn in build mode.")
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, "You must be alive to set your spawn.")
        end
    else
        MsgN("[Nadmin]You can't set your spawn as console.")
    end
end

if SERVER then
    hook.Add("PlayerSpawn", "nadmin_custom_spawns", function(ply, transition)
        if isvector(ply.n_SpawnPoint) then
            timer.Simple(0, function()
                ply:SetPos(ply.n_SpawnPoint)
                if isangle(ply.n_SpawnEye) then
                    ply:SetEyeAngles(ply.n_SpawnEye)
                end
            end)
        end
    end)
end

nadmin:RegisterCommand(cmd)
