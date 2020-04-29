net.Receive("nadmin_send_register", function(len)
    nadmin.entities = {}
    nadmin.npcs     = {}
    nadmin.tools    = {}
    nadmin.vehicles = {}
    nadmin.weapons  = {}

    nadmin.entities = table.Copy(net.ReadTable())
    nadmin.npcs     = table.Copy(net.ReadTable())
    nadmin.tools    = table.Copy(net.ReadTable())
    nadmin.vehicles = table.Copy(net.ReadTable())
    nadmin.weapons  = table.Copy(net.ReadTable())
end)
