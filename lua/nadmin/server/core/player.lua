local PLAYER = PLAYER or FindMetaTable("Player")

--Managing their data
local function ct(tbl, temp) -- Copy Table
    local out = table.Copy(tbl)
    for key, val in pairs(temp) do -- Loop through all items on the table
        if istable(val) then -- If it's a table, we want to re-iterate
            if not istable(out[key]) then out[key] = {} end
            out[key] = ct(out[key], val)
        elseif type(out[key]) ~= type(val) then -- If it's not a table, we want to make sure the types match
            out[key] = val;
        end
    end
    return out
end

function PLAYER:CheckData()
    if not IsValid(self) then return end

    local d = table.Copy(nadmin.defaults.userdata)
    if self:IsBot() then return d end -- We don't want to save bot data, nor should they have any data
    nadmin.userdata[self:SteamID()] = ct(nadmin.userdata[self:SteamID()] or {}, d)
    return nadmin.userdata[self:SteamID()]
end

function nadmin:CheckData(id)
    if not isstring(id) then return end 
    
    local d = table.Copy(nadmin.defaults.userdata)
    nadmin.userdata[id] = ct(nadmin.userdata[id] or {}, d)
    return nadmin.userdata[id]
end

function PLAYER:SaveData()
    if not IsValid(self) then return end
    if self:IsBot() then return end -- We don't want to save bot data
    self:CheckData()
    file.Write("nadmin/userdata/" .. string.lower(string.Replace(self:SteamID(), ":", ",")) .. ".txt",  util.TableToJSON(nadmin.userdata[self:SteamID()], true))
end

function nadmin:SaveData(id)
    if not isstring(id) then return end
    local user = nadmin:CheckData(id)
    file.Write("nadmin/userdata/" .. string.lower(string.Replace(id, ":", ",")) .. ".txt",  util.TableToJSON(user, true))
end

--HasGodMode fix for client
if not isfunction(PLAYER.oldGodEnable) then PLAYER.oldGodEnable = PLAYER.GodEnable end
if not isfunction(PLAYER.oldGodDisable) then PLAYER.oldGodDisable = PLAYER.GodDisable end
function PLAYER:GodEnable()
    if not IsValid(self) then return end
    self:SetNWBool("nadmin_god", true)
    self:oldGodEnable()
end
function PLAYER:GodDisable()
    if not IsValid(self) then return end
    self:SetNWBool("nadmin_god", false)
    self:oldGodDisable()
end

-- Teleportation
function PLAYER:AddReturnPosition(pos)
    if not IsValid(self) then return end

    local store = pos
    if not isvector(pos) then store = self:GetPos() end

    if not nadmin.plyReturns[self:SteamID()] then nadmin.plyReturns[self:SteamID()] = {} end
    local ret = nadmin.plyReturns[self:SteamID()]
    table.insert(ret, store)
    if #ret > 5 then
        table.remove(ret, 1)
    end
end

--Rank stuff
function PLAYER:SetRank(rank)
    if not IsValid(self) then return false end

    self:CheckData()
    local r = nadmin:FindRank(rank)
    if istable(r) then
        self:SetNWString("nadmin_rank", r.id)
        if not self:IsBot() then
            nadmin.userdata[self:SteamID()].rank = r.id
        end
        self:SetUserGroup(r.id)
        return true
    end
    return false
end

-- Level stuff
function PLAYER:SetLevel(level, exp)
    if not IsValid(self) then return end
    if not isnumber(level) then return end

    local newLevel = nadmin:Ternary(level < 0, math.ceil(level), math.floor(level))
    local xpToLevel = GetXpToLevel(level)
    local xp = (level - newLevel) * xpToLevel
    if isnumber(exp) then xp = xp + exp end

    self:SetNWInt("nadmin_level", newLevel)
    self:SetNWInt("nadmin_xp", xp)

    if not self:IsBot() then
        self:CheckData()
        nadmin.userdata[self:SteamID()].level.lvl = newLevel
        nadmin.userdata[self:SteamID()].level.xp  = xp
    end
end

function PLAYER:AddExperience(xp)
    if not IsValid(self) then return end
    if self:IsBot() then return end
    if not isnumber(xp) then return end

    local maxChanges = 128 --Prevent an infinite while loop
    local changes = 0

    local level = self:GetNWInt("nadmin_level", 1)
    local oldLevel = level
    local c = self:GetNWInt("nadmin_xp", 0) + xp

    local xpToLevel = GetXpToLevel(level)
    while (c >= xpToLevel or c < 0) and changes < maxChanges do
        changes = changes + 1

        if c >= xpToLevel then
            level = level + 1
            c = c - xpToLevel
        else --Must be less than xpToLevel
            level = level - 1
            c = c + xpToLevel
        end
        xpToLevel = GetXpToLevel(level)
    end

    self:SetNWInt("nadmin_level", level)
    self:SetNWInt("nadmin_xp", c)

    if not self:IsBot() then
        self:CheckData()
        nadmin.userdata[self:SteamID()].level.lvl = level
        nadmin.userdata[self:SteamID()].level.xp  = c
    end

    if oldLevel ~= level then
        nadmin:Notify(self, nadmin.colors.blue, "You have leveled up ", nadmin.colors.white, tostring(level - oldLevel), nadmin.colors.blue, " " .. nadmin:Ternary(level - oldLevel == 1, "time", "times") .. ", now you are level ", nadmin.colors.white, level, nadmin.colors.blue, ".")
        return true
    end
    return false
end

--Nicknaming
function PLAYER:SetNick(nick, no_save)
    if not IsValid(self) then return end

    if isstring(nick) then
        if nick == self:RealName() then
            self:SetNWString("nadmin_nickname", self:RealName())
            if not no_save then nadmin.userdata[self:SteamID()].forcedName = "" end
        else
            self:SetNWString("nadmin_nickname", nick)
            if not no_save then nadmin.userdata[self:SteamID()].forcedName = nick end
        end
    else
        self:SetNWString("nadmin_nickname", self:RealName())
        if not no_save then nadmin.userdata[self:SteamID()].forcedName = "" end
    end
end

-- Playtime
function PLAYER:SetPlayTime(time)
    if not IsValid(self) then return false end
    self:SetNWInt("nadmin_playtime", tonumber(time))
    if not self:IsBot() then
        self:CheckData()
        nadmin.userdata[self:SteamID()].playtime = time
    end
end

-- Remove props
function PLAYER:RemoveProps()
    if not IsValid(self) then return end

    for i, ent in ipairs(ents.GetAll()) do
        if CPPI and ent.CPPIGetOwner then
            if ent:CPPIGetOwner() == self then
                ent:Remove()
            end
        else
            if ent.nadmin_owner == self then
                ent:Remove()
            end
        end
    end
end
