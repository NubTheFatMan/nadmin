-- The file handle's all serverside prop protection
if not nadmin.plugins.propprotec then return end

nadmin.pp = {}
nadmin.pp.isLarge = true -- ( ͡° ͜ʖ ͡°)

nadmin.pp.list = nadmin.pp.list or {} -- Each item on this sequential table is formated like this: [entID] = {ent = <Entity>, owner = <Player>, steamid = <owner:SteamID()>, nick = <ply:Nick()>}
nadmin.pp.playerList = nadmin.pp.playerList or {} -- The list of props sent to the clients, {ent}
nadmin.pp.autoCDPTimers = nadmin.pp.autoCDPTimers or {} -- Table of disconnect timers to auto clean a player

nadmin.ppData = nadmin.ppData or {use_protec = false, cdp_enabled = true, cdp_time = 120, cdp_admins = true}

CPPI = {}

function CPPI:GetName() return "Nadmin Prop Protection" end 
function CPPI:GetVersion() return nadmin.version end

local PLAYER = debug.getregistry().Player
local ENTITY = debug.getregistry().Entity

util.AddNetworkString("nadmin_send_props")
util.AddNetworkString("nadmin_receive_friends")
util.AddNetworkString("nadmin_update_pp")

net.Receive("nadmin_receive_friends", function(len, ply) 
    ply:CheckData()
    local data = nadmin.userdata[ply:SteamID()]
    if istable(data) then 
        data.ppFriends = net.ReadTable()
    end
    MsgN("[Nadmin]Receieved " .. ply:Nick() .. "'s friends. Count: " .. #data.ppFriends)
end)

-- Pretty much copied from Nadmod :)
function nadmin.pp.SendProps(props, ply)
    net.Start("nadmin_send_props")
        local nameMap = {}
        local nameMapi = 0
        local count = 0
        for i, p in pairs(props) do
            if not nameMap[p.steamid] then 
                nameMapi = nameMapi + 1
                nameMap[p.steamid] = nameMapi
                nameMap[nameMapi] = p
            end
            count = count + 1
        end
        net.WriteUInt(nameMapi, 8)
        for i = 1, nameMapi do
            net.WriteString(nameMap[i].steamid)
            net.WriteString(nameMap[i].nick) 
        end
        net.WriteUInt(count, 32)
        for i, p in pairs(props) do
            net.WriteUInt(i, 16)
            net.WriteUInt(nameMap[p.steamid], 8)
        end
    if IsValid(ply) and ply:IsPlayer() then net.Send(ply) else net.Broadcast() end
end

function nadmin.pp.RefreshOwners() 
    if not timer.Exists("nadmin_pp_refresh_owners") then 
        timer.Create("nadmin_pp_refresh_owners", 0, 1, function()
            nadmin.pp.SendProps(nadmin.pp.playerList)
            nadmin.pp.playerList = {}
        end)
    end
end

function nadmin.pp.SendConfig(ply)
    net.Start("nadmin_update_pp")
        net.WriteTable(nadmin.ppData)
    if IsValid(ply) and ply:IsPlayer() then net.Send(ply) else net.Broadcast() end
end

net.Receive("nadmin_update_pp", function(len, ply)
    if not ply:HasPerm("manage_pp") then 
        nadmin:Notify(ply, nadmin.colors.red, "You don't have access to manage Prop Protection settings.")
        return
    end
    
    nadmin.ppData = net.ReadTable()
    nadmin.pp.SendConfig()
    nadmin:SavePPData()

    local nameCol = nadmin:GetNameColor(ply) or nadmin.colors.blue
    nadmin:Notify(nameCol, ply:Nick(), nadmin.colors.white, " has updated ", nadmin.colors.blue, "prop protection", nadmin.colors.white, " settings.")
end)

function nadmin.pp.InitPlayer(ply)
    if IsValid(ply) and ply:IsPlayer() then 
        local steamid = ply:SteamID()
        for i, p in pairs(nadmin.pp.list) do
            if p.steamid == steamid then 
                p.owner = ply
                p.ent.nadmin_owner = ply
                if p.ent.SetPlayer then p.ent:SetPlayer(ply) end
            end
        end
        nadmin.pp.SendProps(nadmin.pp.list, ply)

        nadmin.pp.SendConfig(ply)
    end
end
hook.Add("PlayerInitialSpawn", "nadmin_pp_init_player", nadmin.pp.InitPlayer)

function nadmin.pp.OwnWeapons(ply)
    timer.Create("nadmin_pp_own_weapons", 0.2, 1, function()
        if not IsValid(ply) then return end
        for i, w in pairs(ply:GetWeapons()) do
            if IsValid(w) then 
                nadmin.pp.SetOwnerWorld(w)
            end
        end
    end)
end
hook.Add("PlayerSpawn", "nadmin_pp_own_weapons", nadmin.pp.OwnWeapons)

function nadmin.pp.PlayerCanTouch(ply, ent) 
    if not IsValid(ply)   then return false end
    if not IsValid(ent)   then return false end
    if not ply:IsPlayer() then return false end
    if     ent:IsPlayer() then 
        local pref = nadmin.plyPref[ply:SteamID()]
        if istable(pref) then 
            return ply:BetterThan(ent)
        end
        return false
    end 

    if ent:IsWorld() then return ent:GetClass() == "worldspawn" end

    local index = ent:EntIndex()
    if not nadmin.pp.list[index] then 
        if index == 0 then 
            nadmin.pp.SetOwnerWorld(ent)
            return false
        end

        local class = ent:GetClass()
        if class == "predicted_viewmodel" or class == "gmod_hands" or class == "physgun_beam" then 
            nadmin.pp.SetOwnerWorld(ent)
        elseif ent.GetPlayer and IsValid(ent:GetPlayer()) then 
            nadmin.pp.SetOwnerPlayer(ent:GetPlayer(), ent)
        elseif ent.GetOwner and (IsValid(ent:GetOwner()) or ent:GetOwner():IsWorld()) then 
            nadmin.pp.SetOwnerPlayer(ent:GetOwner(), ent)
        else 
            nadmin.pp.SetOwnerPlayer(ply, ent)
            nadmin:Notify(ply, nadmin.colors.blue, "You now own this ", nadmin.colors.white, class, nadmin.colors.blue, " (", nadmin.colors.white, string.sub(table.remove(string.Explode("/", ent:GetModel() or "?")), 1, -5), nadmin.colors.blue, ")")
            return true
        end
    end

    local prop = nadmin.pp.list[index]
    if prop.steamid == "O" then return true end -- Ownerless
    if prop.steamid == ply:SteamID() then return true end -- Owned by the player grabbing it
    if prop.steamid == "W" then return ply:HasPerm("touch_world_props") end -- Has permission to touch world props

    local owner = nadmin.userdata[prop.steamid]
    if istable(owner) then 
        if table.HasValue(owner.ppFriends, ply:SteamID64()) then 
            return true
        end
    end

    if ply:HasPerm("physgun_player_props") then 
        return ply:BetterThan(prop.steamid)
    end

    return false
end

function nadmin.pp.PlayerCanTouchSafe(ply, ent)
    if not nadmin.pp.PlayerCanTouch(ply, ent) then return false end
end
hook.Add("PhysgunPickup", "nadmin_pp_physgun_pickup", nadmin.pp.PlayerCanTouchSafe)
hook.Add("CanProperty", "nadmin_pp_can_property", function(ply, mode, ent) return nadmin.pp.PlayerCanTouchSafe(ply, ent) end)
hook.Add("CanEditVariable", "nadmin_pp_can_edit_var", function(ent, ply) return nadmin.pp.PlayerCanTouchSafe(ply, ent) end)

function nadmin.pp.OnPhysgunReload(weapon, ply)
    if not IsValid(weapon) or not IsValid(ply) then return end

    local tr = util.TraceLine(util.GetPlayerTrace(ply))
    if not tr.HitNonWorld or not tr.Entity:IsValid() or tr.Entity:IsPlayer() then return end
    if not nadmin.pp.PlayerCanTouch(ply, tr.Entity) then return false end
end
hook.Add("OnPhysgunReload", "nadmin_pp_physgun_reload", nadmin.pp.OnPhysgunReload)

function nadmin.pp.GravGunPickup(ply, ent)
    if not IsValid(ent) or not IsValid(ent) then return end 
    if ent:IsPlayer() then return end 
    if nadmin.pp.list[ent:EntIndex()] and nadmin.pp.list[ent:EntIndex()].steamid == "W" then return end
    if not nadmin.pp.PlayerCanTouch(ply, ent) then return false end
end
hook.Add("GravGunPunt", "nadmin_pp_grav_gun_punt", nadmin.pp.GravGunPickup)
hook.Add("GravGunPickupAllowed", "nadmin_pp_grav_gun_pickup", nadmin.pp.GravGunPickup)

nadmin.pp.weirdTraces = {"wire_winch", "wire_hydraulic", "slider", "hydraulic", "winch", "muscle"}
function nadmin.pp.CanTool(ply, tr, mode)
    local ent = tr.Entity
    if not ent:IsWorld() and (not ent:IsValid() or ent:IsPlayer()) then return false end 
    if not nadmin.pp.PlayerCanTouch(ply, ent) then 
        -- if not ((nadmin.pp.list[ent:EntIndex()] or {}).nick == "W" and (mode == "wire_debugger" or mode == "wire_adv")) then return false end
        if not ent:IsWorld() and (nadmin.pp.list[ent:EntIndex()] or {}).steamid == "W" and not ply:HasPerm("touch_world_props") then return false end
    elseif mode == "nail" then 
        local Trace = {}
        Trace.start = tr.HitPos 
        Trace.endpos = tr.HitPos + (ply:GetAimVector() * 16)
        Trace.filter = {ply, tr.Entity}
        local tr2 = util.TraceLine(Trace)
        if tr2.Hit and IsValid(tr2.Entity) and not tr2.Entity:IsPlayer() then 
            if not nadmin.pp.PlayerCanTouch(ply, tr2.Entity) then return false end
        end
    elseif table.HasValue(nadmin.pp.weirdTraces, mode) then 
        local Trace = {}
        Trace.start = tr.HitPos 
        Trace.endpos = Trace.start + (tr.HitNormal * 16384)
        Trace.filter = {ply}
        local tr2 = util.TraceLine(Trace)
        if tr2.Hit and IsValid(tr2.Entity) and not tr2.Entity:IsPlayer() then 
            if not nadmin.pp.PlayerCanTouch(ply, tr2.Entity) then return false end
        end
    elseif mode == "remover" then 
        if ply:KeyDown(IN_ATTACK2) or ply:KeyDownLast(IN_ATTACK2) then 
            for i, c in pairs(constraint.GetAllConstrainedEntities(ent) or {}) do
                if not nadmin.pp.PlayerCanTouch(ply, c) then return false end
            end
        end
    end
end
hook.Add("CanTool", "nadmin_pp_can_tool", nadmin.pp.CanTool)

function nadmin.pp.PlayerUse(ply, ent)
    if not nadmin.ppData.use_protec then return end -- Let them touch if use protection is disabled
    if nadmin.pp.PlayerCanTouch(ply, ent) then return end -- Let them use if they can touch it
    if ent:IsValid() and nadmin.pp.list[ent:EntIndex()].nick == "W" then return end -- Let them use world props
    return false
end
hook.Add("PlayerUse", "nadmin_pp_player_use", nadmin.pp.PlayerUse)

function nadmin.pp.SetOwnerPlayer(ply, ent)
    if not IsValid(ent)   then return end 
    if     ent:IsPlayer() then return end 
    if not IsValid(ply)   then return end 
    if not ply:IsPlayer() then return end

    local index = ent:EntIndex()
    nadmin.pp.list[index] = {
        ent = ent, 
        owner = ply,
        steamid = ply:SteamID(),
        steamid64 = ply:SteamID64(),
        nick = ply:Nick()
    }
    nadmin.pp.playerList[index] = nadmin.pp.list[index]
    ent.nadmin_owner = ply
    nadmin.pp.RefreshOwners()
end

if cleanup then 
    local oldCleanupAdd = cleanup.Add
    function cleanup.Add(ply, enttype, ent)
        if IsValid(ent) and ply:IsPlayer() then 
            nadmin.pp.SetOwnerPlayer(ply, ent)
        end
        oldCleanupAdd(ply, enttype, ent)
    end
end

if PLAYER.AddCount then 
    local oldAddCount = PLAYER.AddCount
    function PLAYER:AddCount(enttype, ent)
        nadmin.pp.SetOwnerPlayer(self, ent)
        oldAddCount(self, enttype, ent)
    end
end

hook.Add("PlayerSpawnedSENT", "nadmin_pp_ply_spawn_sent", nadmin.pp.SetOwnerPlayer)
hook.Add("PlayerSpawnedVehicle", "nadmin_pp_ply_spawn_vehicle", nadmin.pp.SetOwnerPlayer)
hook.Add("PlayerSpawnedSWEP", "nadmin_pp_ply_spawn_swep", nadmin.pp.SetOwnerPlayer)

function ENTITY:CPPISetOwnerless(bool)
    if not IsValid(self) then return end 
    if self:IsPlayer() then return end

    if bool then 
        local index = self:EntIndex()
        nadmin.pp.list[index] = {
            ent = self,
            owner = game.GetWorld(),
            steamid = "O",
            steamid64 = "O",
            nick = "O"
        }
        nadmin.pp.playerList[index] = nadmin.pp.list[index]
        self.nadmin_owner = game.GetWorld()
        nadmin.pp.RefreshOwners()
    else 
        nadmin.pp.EntityRemoved(self)
    end
end

function nadmin.pp.SetOwnerWorld(ent)
    if not IsValid(ent) then return end
    if ent:IsPlayer() then return end

    local index = ent:EntIndex()
    nadmin.pp.list[index] = {
        ent = ent,
        owner = game.GetWorld(),
        steamid = "W",
        steamid64 = "W",
        nick = "W"
    }
    nadmin.pp.playerList[index] = nadmin.pp.list[index]
    ent.nadmin_owner = game.GetWorld()
    nadmin.pp.RefreshOwners()
end

function nadmin.pp.WorldOwner()
    local worldEnts = 0
    for i, e in pairs(ents.GetAll()) do
        if (not e:IsPlayer() and (e:EntIndex() == 0 or not nadmin.pp.list[e:EntIndex()])) and not IsValid(e.nadmin_owner) then 
            if e:GetClass() == "func_brush" and game.GetMap() == "gm_construct" then 
                e:CPPISetOwnerless(true)
            else 
                nadmin.pp.SetOwnerWorld(e)
            end
            worldEnts = worldEnts + 1
        end
    end
    print("Nadmin Prop Protection Module: " .. worldEnts .. " props belong to the world.")
end

if CurTime() < 5 then timer.Create("nadmin_pp_find_world_props", 7, 1, nadmin.pp.WorldOwner) end
hook.Add("PostCleanupMap", "nadmin_pp_map_cleaned", function()
    timer.Simple(0, function() nadmin.pp.WorldOwner() end)
end)

function nadmin.pp.EntityRemoved(ent)
    nadmin.pp.list[ent:EntIndex()] = nil
    nadmin.pp.playerList[ent:EntIndex()] = {steamid = "-", nick = "-"}
    nadmin.pp.RefreshOwners()
    if ent:IsValid() and ent:IsPlayer() and not ent:IsBot() then 
        local steamid, nick = ent:SteamID(), ent:Nick()
        
        if nadmin.ppData.cdp_enabled then 
            if not nadmin.ppData.cdp_admins then 
                if ent:HasPerm("physgun_player_props") then return end
            end
            timer.Create("nadmin_autoclean_dc_ply_" .. steamid, nadmin.ppData.cdp_time, 1, function()
                local count = nadmin.pp.CleanupPlayerProps(steamid)

                local nameCol = nadmin:GetNameColor(ent) or nadmin.colors.blue
                if count > 0 then nadmin:Notify(nameCol, nick, nadmin.colors.white, "'s props (", nadmin.colors.blue, count, nadmin.colors.white, ") have been autocleaned.") end
            end)
        end
    end
end
hook.Add("EntityRemoved", "nadmin_pp_ent_removed", nadmin.pp.EntityRemoved)

function nadmin.pp.ClearAutoCDP(ply, steamid, uniqueid)
    timer.Remove("nadmin_autoclean_dc_ply_" .. steamid)
end
hook.Add("PlayerAuthed", "nadmin_pp_clear_auto_cdp", nadmin.pp.ClearAutoCDP)
hook.Add("PlayerConnect", "nadmin_pp_clear_auto_cdp", function(nick, address)
    nadmin.pp.ClearAutoCDP(nil, nadmin.pp.autoCDPTimers[nick] or "")
end)

function nadmin.pp.CleanupPlayerProps(steamid)
    local count = 0
    for i, p in pairs(nadmin.pp.list) do
        if p.steamid == steamid then 
            if IsValid(p.ent) then 
                if not p.ent:GetPersistent() then 
                    p.ent:Remove()
                    count = count + 1
                end
            else 
                nadmin.pp.EntityRemoved(p.ent)
            end
        end
    end
    return count
end

function nadmin.pp.CDP()
    local count = 0
    for i, p in pairs(nadmin.pp.list) do
        if not p.ent:IsValid() then 
            nadmin.pp.EntityRemoved(p.ent)
        elseif not IsValid(p.owner) and (p.nick ~= "O" and p.nick ~= "W") and not p.ent:GetPersistent() then 
            p.ent:Remove()
            count = count + 1
        end
    end
    return count
end

function nadmin.pp.CleanClass(cl)
    local count = 0
    for i, ent in ipairs(ents.FindByClass(cl)) do 
        ent:Remove()
        count = count + 1
    end
    return count
end
function nadmin.pp.CleanWorldRopes()
    local count = 0
    for i, r in pairs(ents.FindByClass("keyframe_rope")) do
        if r.Ent1 and r.Ent1:IsWorld() and r.Ent2 and r.Ent2:IsWorld() then r:Remove() count = count + 1 end
    end
    return count
end

function PLAYER:CPPIGetFriends()
    local out = {}
    if istable(nadmin.userdata[self:SteamID()]) and istable(nadmin.userdata[self:SteamID()].ppFriends) then 
        local friends = nadmin.userdata[self:SteamID()].ppFriends
        for i, ply in ipairs(friends) do 
            local found = nadmin:FindPlayer(ply)
            if #found == 1 then 
                table.insert(out, found[1])
            end
        end
    end
    for i, ply in pairs(player.GetAll()) do
        if ply:HasPerm("physgun_player_props") and ply:BetterThan(self) then table.insert(out, ply) end
    end
end

function ENTITY:CPPIGetOwner() return self.nadmin_owner end
function ENTITY:CPPISetOwner(ply) return nadmin.pp.SetOwnerPlayer(ply, self) end 
function ENTITY:CPPICanTool(ply, mode) return nadmin.pp.CanTool(ply, {Entity = self}, mode) ~= false end
function ENTITY:CPPICanPhysgun(ply) return nadmin.pp.PlayerCanTouch(ply, self) end 
function ENTITY:CPPICanPickup(ply) return nadmin.pp.GravGunPickup(ply, self) ~= false end
function ENTITY:CPPICanPunt(ply) return nadmin.pp.GravGunPickup(ply, self) ~= false end

if E2Lib and E2Lib.replace_function then 
    E2Lib.replace_function("isOwner", function(ply, entity)
        return nadmin.pp.PlayerCanTouch(ply, entity)
    end)
end