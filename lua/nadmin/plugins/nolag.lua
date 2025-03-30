local COMMAND = {}
COMMAND.title = "No Lag"
COMMAND.description = "Freezes every single prop on the server to stop lag"
COMMAND.author = "Nub"
COMMAND.timeCreated = "Wednesday, July 14, 2021 @ 4:37 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "nolag"
COMMAND.defaultAccess = nadmin.access.admin
COMMAND.server = function(caller, args)
    local count = 0
    for i, ent in ipairs(ents.GetAll()) do
        if not ent:GetUnFreezable() and not ent:IsPlayer() then 
            ent:SetMoveType(MOVETYPE_NONE)
            ent.n_frozen = true
            count = count + 1
        end
    end
    nadmin:Notify(caller:GetRank().color, caller:Nick(), nadmin.colors.white, " has frozen all props (", nadmin.colors.blue, count, nadmin.colors.white, ").")
end

hook.Add("OnPhysgunPickup", "nadmin_unfreeze_props", function(ply, ent)
    if ent.n_frozen then 
        ent:SetMoveType(MOVETYPE_VPHYSICS)
        ent.n_frozen = nil
    end
end)

nadmin:RegisterCommand(COMMAND)