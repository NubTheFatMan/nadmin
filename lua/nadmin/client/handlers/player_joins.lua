net.Receive("nadmin_send_register", function(len)
    nadmin.entities = {}
    nadmin.npcs     = {}
    nadmin.tools    = {}
    nadmin.vehicles = {}
    nadmin.weapons  = {}
    nadmin.maps     = {}

    nadmin.entities = table.Copy(net.ReadTable())
    nadmin.npcs     = table.Copy(net.ReadTable())
    nadmin.tools    = table.Copy(net.ReadTable())
    nadmin.vehicles = table.Copy(net.ReadTable())
    nadmin.weapons  = table.Copy(net.ReadTable())
    nadmin.maps     = table.Copy(net.ReadTable())
end)

hook.Add("Initialize", "nadmin_send_preferences", function()
    timer.Simple(1, function()
        if (nadmin.clientData) then 
            net.Start("nadmin_player_preferences")
                net.WriteTable({
                    allowNoclip   = nadmin.clientData.allowNoclip,
                    physgunOthers = nadmin.clientData.physgunOthers,
                    afkTime       = nadmin.clientData.afkTime,
                    silentNotifs  = nadmin.clientData.silentNotifs,
                    hpRegen       = nadmin.clientData.hpRegen
                })
            net.SendToServer()
            end
    end)
end)