if SERVER then
    local defRanks = '{"owner":{"icon":"icon16/key.png","id":"owner","restrictions":[],"loadout":["weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","gmod_camera","gmod_tool","weapon_physgun","pist_weagon","weapon_rpg","weapon_shotgun","weapon_smg1","weapon_ar2","weapon_pistol","weapon_357","none"],"immunity":100.0,"autoPromote":{"enabled":false,"when":-1.0,"rank":""},"color":{"r":180.0,"b":0.0,"a":255.0,"g":0.0},"ownerRank":true,"title":"Owner","privileges":[]},"regular":{"icon":"icon16/user.png","id":"regular","ownerRank":false,"privileges":[],"title":"Regular","autoPromote":{"when":-1.0,"rank":"","enabled":false},"loadout":["gmod_camera","gmod_tool","weapon_physgun","weapon_357","weapon_pistol","weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","weapon_ar2","weapon_rpg","weapon_shotgun","weapon_smg1","none"],"immunity":20.0,"restrictions":[],"color":{"r":62.0,"b":62.0,"a":255.0,"g":255.0}},"admin":{"icon":"icon16/shield.png","id":"admin","ownerRank":false,"privileges":[],"title":"Admin","color":{"r":180.0,"b":0.0,"a":255.0,"g":180.0},"immunity":60.0,"restrictions":[],"autoPromote":{"rank":"","when":-1.0,"enabled":false},"loadout":["gmod_camera","gmod_tool","weapon_physgun","weapon_357","weapon_pistol","weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","weapon_ar2","weapon_rpg","weapon_shotgun","weapon_smg1","pist_weagon","none"]},"superadmin":{"icon":"icon16/shield_add.png","id":"superadmin","restrictions":[],"privileges":[],"title":"SuperAdmin","loadout":["gmod_camera","gmod_tool","weapon_physgun","weapon_357","weapon_pistol","weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","weapon_ar2","weapon_rpg","weapon_shotgun","weapon_smg1","pist_weagon","none"],"autoPromote":{"enabled":false,"when":-1.0,"rank":""},"immunity":80.0,"ownerRank":false,"color":{"r":180.0,"b":0.0,"a":255.0,"g":114.0}},"guest":{"icon":"icon16/user.png","autoPromote":{"when":43200.0,"enabled":true,"rank":"regular"},"restrictions":[],"privileges":[],"title":"Guest","id":"guest","loadout":["gmod_camera","gmod_tool","weapon_physgun","weapon_357","weapon_pistol","weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","weapon_ar2","weapon_rpg","weapon_shotgun","weapon_smg1","none"],"ownerRank":false,"immunity":0.0,"color":{"r":0.0,"b":255.0,"a":255.0,"g":255.0}},"respected":{"icon":"icon16/user_add.png","autoPromote":{"rank":"","enabled":false,"when":-1.0},"restrictions":[],"privileges":[],"title":"Respected","color":{"r":100.0,"b":255.0,"a":255.0,"g":65.0},"immunity":40.0,"ownerRank":false,"loadout":["gmod_camera","gmod_tool","weapon_physgun","weapon_357","weapon_pistol","weapon_crossbow","weapon_crowbar","weapon_frag","weapon_physcannon","weapon_ar2","weapon_rpg","weapon_shotgun","weapon_smg1","none"],"id":"respected"}}'


    if not file.Exists("nadmin/config/ranks.txt", "DATA") then
        file.Write("nadmin/config/ranks.txt", defRanks)
    end

    -- Since the file already exists, we want to register them all
    local ranks = util.JSONToTable(file.Read("nadmin/config/ranks.txt", "DATA"))
    local reg = 0
    for id, rank in pairs(ranks) do
        reg = reg + 1
        nadmin:RegisterRank(rank)
    end

    nadmin:SendRanksToClients()
end
