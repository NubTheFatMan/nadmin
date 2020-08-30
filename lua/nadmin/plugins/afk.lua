local COMMAND = {}
COMMAND.title = "AFK"
COMMAND.description = "Set yourself afk."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, May 2, 2020 @ 9:16 PM"
COMMAND.category = "Utility"
COMMAND.call = "afk"
COMMAND.server = function(caller, args)
    if not IsValid(caller) then return end

    caller.n_AFK = true
    nadmin.SilentNotify = false
    nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " is now AFK.")
end

if SERVER then
    COMMAND.afkTimeout = 120

    COMMAND.checkInterval = 3
    COMMAND.lastChecked = 0

    hook.Add("Think", "nadmin_afk_check", function()
        if not nadmin.plugins.afk then return end
        
        local now = os.time()
        if now - COMMAND.lastChecked >= COMMAND.checkInterval then
            local afk = {}
            local back = {}
            for i, ply in ipairs(player.GetAll()) do
                COMMAND.lastChecked = now

                if ply:EyeAngles() ~= ply.n_EyeAngles then
                    ply.n_EyeAngles = ply:EyeAngles()
                    ply.n_LastEyeTime = now

                    if ply.n_AFK then
                        ply.n_AFK = nil
                        nadmin:Notify(ply:GetRank().color, ply:Nick(), nadmin.colors.white, " is now back.")
                    end
                end

                if (not ply.n_AFK) and now - ply.n_LastEyeTime >= COMMAND.afkTimeout then
                    ply.n_AFK = true
                    nadmin:Notify(ply:GetRank().color, ply:Nick(), nadmin.colors.white, " is now AFK.")
                end
            end
        end
    end)
end

nadmin:RegisterCommand(COMMAND)

nadmin:RegisterPerm({
    title = "Allow AFK Time"
})
