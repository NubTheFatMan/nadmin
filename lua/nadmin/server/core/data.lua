if not file.Exists("nadmin", "DATA") then
    file.CreateDir("nadmin/userdata")
    file.CreateDir("nadmin/logs")
    file.CreateDir("nadmin/config")
end

local userfiles,_ = file.Find("nadmin/userdata/*.txt", "DATA")
for _, userfile in pairs(userfiles) do
    local ID = string.upper(string.Replace(string.sub(userfile, 1, #userfile - 4), ",", ":"))
    local data = file.Read("nadmin/userdata/" .. userfile)
    nadmin.userdata[ID] = util.JSONToTable(data)
end

if file.Exists("nadmin/config/bans.txt", "DATA") then
    nadmin.bans = util.JSONToTable(file.Read("nadmin/config/bans.txt"))
end

if file.Exists("nadmin/config/pp.txt", "DATA") then 
    nadmin.ppData = util.JSONToTable(file.Read("nadmin/config/pp.txt"))
end

function nadmin:SaveDefaultPermData()
    file.Write("nadmin/config/setperms.txt", table.concat(nadmin.defaultPermData, ","))
end

function nadmin:SavePPData()
    file.Write("nadmin/config/pp.txt", util.TableToJSON(nadmin.ppData))
    MsgN("[Nadmin]Updated Prop Protection Config.")
end

function nadmin:SaveUserData(id)
    if not isstring(id) then return end
    if not istable(nadmin.userdata[id]) then return end
    file.Write("nadmin/userdata/" .. string.lower(string.Replace(id, ":", ",")) .. ".txt",  util.TableToJSON(nadmin.userdata[id]))
    MsgN("[Nadmin]Performing save on userdata " .. id)
end
function nadmin:RemoveUserData(id)
    if not isstring(id) then return end
    if nadmin.userdata[id] ~= nil then nadmin.userdata[id] = nil end
    if file.Exists("nadmin/userdata/" .. string.lower(string.Replace(id, ":", ",")) .. ".txt", "DATA") then
        file.Delete("nadmin/userdata/" .. string.lower(string.Replace(id, ":", ",")) .. ".txt")
    end
end

function nadmin:SaveBans()
    file.Write("nadmin/config/bans.txt", util.TableToJSON(nadmin.bans))
    MsgN("[Nadmin]Performing a save on bans.")
end

nadmin.defaultPermData = nadmin.defaultPermData or {}
if file.Exists("nadmin/config/setperms.txt", "DATA") then 
    nadmin.defaultPermData = string.Explode(",", file.Read("nadmin/config/setperms.txt"))
end

hook.Add("Initialize", "nadmin_init", function()
    nadmin.serverInitialized = true

    -- Load ranks
    local rank = file.Read("nadmin/config/ranks.txt")
    if isstring(rank) and rank ~= "" then
        table.Merge(nadmin.ranks, util.JSONToTable(rank))
    end

    local changed = false
    -- Make sure new first time registered permissions get access granted to their default ranks
    for _, cmd in pairs(nadmin.commands) do
        if not isnumber(cmd.defaultAccess) then continue end
        if table.HasValue(nadmin.defaultPermData, cmd.id) then continue end
        
        for _, rank in pairs(nadmin.ranks) do 
            if rank.access < cmd.defaultAccess then continue end
            if table.HasValue(rank.privileges, cmd.id) then continue end
            table.insert(rank.privileges, cmd.id)
            MsgN("[Nadmin]Granted \"" .. cmd.id .. "\" to " .. rank.id)
        end

        table.insert(nadmin.defaultPermData, cmd.id)
        changed = true
    end

    for _, perm in pairs(nadmin.perms) do
        if not isnumber(perm.defaultAccess) then continue end
        if table.HasValue(nadmin.defaultPermData, perm.id) then continue end
        
        for _, rank in pairs(nadmin.ranks) do 
            if rank.access < perm.defaultAccess then continue end
            if table.HasValue(rank.privileges, perm.id) then continue end
            table.insert(rank.privileges, perm.id)
            MsgN("[Nadmin]Granted \"" .. perm.id .. "\" to " .. rank.id)
        end

        table.insert(nadmin.defaultPermData, perm.id)
        changed = true
    end

    if changed then 
        nadmin:SaveDefaultPermData()
        nadmin:SaveRanks()
    end
end)

local lastSaved = 0
hook.Add("Think", "nadmin_save_userdata", function()
    local now = os.time()
    if now - lastSaved >= nadmin.config.saveInterval then
        lastSaved = now
        local c = #nadmin.plyToSave
        -- Save all players in the tosave table. I do it this way to save
        -- player data even after they disconnect, this stops it from
        -- disregarded changes to them.
        if c > 0 then
            for _, id in ipairs(nadmin.plyToSave) do
                nadmin.userdata[id].lastJoined.when = os.time()
                file.Write("nadmin/userdata/" .. string.lower(string.Replace(id, ":", ",")) .. ".txt",  util.TableToJSON(nadmin.userdata[id], true))
            end
            -- MsgN("[Nadmin]Performed a save on " .. tostring(c) .. " player" .. nadmin:Ternary(c > 1, "s", "") .. ".")
            nadmin.plyToSave = {} -- Clear the table
        end

        -- Add all human players back to the table, we don't want to save
        -- bots
        for i, ply in ipairs(player.GetHumans()) do
            table.insert(nadmin.plyToSave, ply:SteamID())
        end
    end
end)
