if SERVER then
    local defRanks = ''
    if not file.Exists("nadmin/config/ranks.txt", "DATA") then
        defRanks = '{"owner":{"icon":"icon16/key.png","color":{"r":180,"b":0,"a":255,"g":0},"title":"Owner","access":5,"privileges":[],"immunity":0,"restrictions":[],"inheritFrom":"","autoPromote":{"when":-1,"rank":"","enabled":false},"id":"owner"},"regular":{"icon":"icon16/user.png","color":{"r":62,"b":62,"a":255,"g":255},"restrictions":[],"id":"regular","immunity":10,"access":2,"inheritFrom":"","privileges":[],"autoPromote":{"rank":"","enabled":false,"when":-1},"title":"Regular"},"admin":{"icon":"icon16/shield.png","color":{"r":180,"b":0,"a":255,"g":180},"id":"admin","access":3,"privileges":[],"title":"Admin","inheritFrom":"","restrictions":[],"immunity":0,"autoPromote":{"when":-1,"enabled":false,"rank":""}},"superadmin":{"icon":"icon16/shield_add.png","id":"superadmin","restrictions":[],"privileges":["ranks","manage_ranks"],"autoPromote":{"when":-1,"rank":"","enabled":false},"title":"SuperAdmin","immunity":0,"inheritFrom":"","access":4,"color":{"r":180,"b":0,"a":255,"g":114}},"guest":{"icon":"icon16/user.png","color":{"r":0,"b":255,"a":255,"g":255},"immunity":0,"access":1,"privileges":[],"autoPromote":{"enabled":true,"rank":"regular","when":43200},"title":"Guest","restrictions":[],"inheritFrom":"","id":"guest"},"respected":{"icon":"icon16/user_add.png","color":{"r":100,"b":255,"a":255,"g":65},"privileges":[],"access":2,"autoPromote":{"enabled":false,"when":-1,"rank":""},"title":"Respected","restrictions":[],"inheritFrom":"","immunity":20,"id":"respected"}}'
        file.Write("nadmin/config/ranks.txt", defRanks)
    else 
        defRanks = file.Read("nadmin/config/ranks.txt", "DATA")
    end

    -- Since the file already exists, we want to register them all
    local ranks = util.JSONToTable(defRanks)
    for id, rank in pairs(ranks) do
        nadmin:RegisterRank(rank)
    end

    nadmin:SendRanksToClients()
end
