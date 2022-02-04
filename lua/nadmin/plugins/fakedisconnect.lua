local COMMAND = {}
COMMAND.title = "Fake Disconnect"
COMMAND.description = "Appear to Disconnect, being ghosted and sending a message"
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, March 23, 2021 @ 10:18 PM"
COMMAND.category = "Fun"
COMMAND.call = "fakedisconnect"
COMMAND.server = function(caller, args)
    if IsValid(caller) then 
        if caller.n_Ghosted then 
            caller.n_Ghosted = nil

            caller:SetRenderMode(RENDERMODE_NORMAL)
            caller:SetColor(nadmin:AlphaColor(caller:GetColor(), 255))

            local weps = caller:GetWeapons()
            for i, w in ipairs(weps) do
                w:SetRenderMode(RENDERMODE_NORMAL)
                w:SetColor(nadmin:AlphaColor(w:GetColor(), 255))
            end
        else 
            caller.n_Ghosted = true 
            
            local col = nadmin:GetNameColor(caller:SteamID()) or nadmin:DefaultRank().color

            nadmin.SilentNotify = true 
            nadmin:Notify(col, caller:Nick(), nadmin.colors.white, " has fake disconnected.")

            nadmin:Notify(col, caller:Nick(), nadmin.colors.white, " (", col, caller:SteamID(),  nadmin.colors.white, ") has disconnected (", nadmin.colors.blue, "Disconnect by user.", nadmin.colors.white, ").")
        end
    else 
        MsgN("You're the console, you can't disconnect in any capacity.")
    end
end

nadmin:RegisterCommand(COMMAND)