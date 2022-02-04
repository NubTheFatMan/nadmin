local PLAYER = PLAYER or FindMetaTable("Player")

--Finding players
function nadmin:FindPlayer(needle, caller, mode)
    local found = {} --Create an empty table.
    if isstring(needle) then --Is the needle a string?
        for i, ply in ipairs(player.GetAll()) do --Loop through players
            --Does the needle contain their name or steam id?
            if string.find(string.lower(ply:Nick()), string.lower(needle), 1, true) or string.find(string.lower(ply:SteamID()),     string.lower(needle), 1, true) then
                table.insert(found, ply) --Add them to our table.
            end
        end
        if type(caller) == "Player" and #found == 0 then --Is the caller a player and was anybody found?
            if needle == "^" then --Put themself in the table
                table.insert(found, caller)
            elseif needle == "*" then --Put everyone in the server in the table.
                for i, ply in ipairs(player.GetAll()) do
                    table.insert(found, ply)
                end
            elseif needle == "@" then --Put whoever they're looking at in the table
                local targ = caller:GetEyeTraceNoCursor().Entity
                if targ:IsPlayer() then 
                    table.insert(found, targ)
                end
            end
        end
    else --If the needle wasn't a string
        if type(caller) == "Player" then --Are they a player?
            table.insert(found, caller) --Put them in the table
        end
    end

    if #found > 0 then --Was more than one player found?
        if type(caller) == "Player" and isnumber(mode) then
            for i, ply in ipairs(found) do --Loop through found players
                if mode == nadmin.MODE_SAME then --Flag for people with equal immunity
                    if ply:BetterThan(caller) then --Is the target's immunity higher than the caller's?
                        table.remove(found, i) --Remove them the found players
                    end
                elseif mode == nadmin.MODE_BELOW then --Flag for people with lower immunity
                    if not (ply == caller) then
                        if ply:BetterThanOrEqual(caller) then
                            table.remove(found, i)
                        end
                    end
                end
            end
        end
    end

    return found
end
function nadmin:FindPlayersWithRank(id)
    local out = {}
    for i, ply in ipairs(player.GetAll()) do
        if ply:GetRank().id == string.lower(id) then table.insert(out, ply) end
    end
    return out
end
function nadmin:GetPlayers(sort)
    local out = {}
    local ranks = {}
    for i, ply in ipairs(player.GetAll()) do
        local rank = ply:GetRank()
        if sort then
            if not table.HasValue(ranks, rank.id) then table.insert(ranks, rank) end
        else
            if not out[rank.id] then out[rank.id] = {} end
            table.insert(out[rank.id], ply)
        end
    end
    if sort then
        table.sort(ranks, function(a, b) return a.immunity > b.immunity end)
        for i, rank in ipairs(ranks) do
            out[rank.id] = {}
        end
        for i, ply in ipairs(player.GetAll()) do
            local rank = ply:GetRank()
            if not out[rank.id] then out[rank.id] = {} end
            table.insert(out[rank.id], ply)
        end
    end
    return out
end

--HasGodMode fix for client
if not isfunction(PLAYER.oldHasGodMode) then PLAYER.oldHasGodMode = PLAYER.HasGodMode end
function PLAYER:HasGodMode()
    if not IsValid(self) then return false end
    return self:GetNWBool("nadmin_god")
end

--Rank stuff
function PLAYER:GetRank()
    if not IsValid(self) then return NULL end
    return nadmin:FindRank(self:GetNWString("nadmin_rank", nadmin:DefaultRank().id))
end

function PLAYER:HasPerm(perm)
    if not IsValid(self) then return false end

    if nadmin.forcedPrivs[perm] then return true end

    if self:IsOwner() then return true end
    local rank = self:GetRank()
    if not rank then return false end

    return table.HasValue(rank.privileges, perm)
end

function PLAYER:HasRestriction(perm)
    if not IsValid(self) then return true end

    if self:IsOwner() then return false end
    local rank = self:GetRank()
    if not rank then return true end

    return table.HasValue(rank.restrictions, perm)
end

function PLAYER:BetterThan(ply)
    if not IsValid(self) then return false end

    if IsValid(ply) and ply:IsPlayer() then 
        local targRank = ply:GetRank()
        if not targRank then return true end

        local callRank = self:GetRank()
        if not callRank then return false end

        return callRank.immunity > targRank.immunity
    elseif isstring(ply) then 
        local targ = nadmin.userdata[ply]
        if istable(targ) then 
            local targRank = nadmin:FindRank(targ.rank)
            if not targRank then return true end

            local callRank = self:GetRank()
            if not callRank then return false end

            return callRank.immunity > targRank.immunity
        end
    end
    return false
end
function PLAYER:BetterThanOrEqual(ply)
    if not IsValid(self) then return false end

    if IsValid(ply) and ply:IsPlayer() then 
        local targRank = ply:GetRank()
        if not targRank then return true end

        local callRank = self:GetRank()
        if not callRank then return false end

        return callRank.immunity >= targRank.immunity
    elseif isstring(ply) then 
        local targ = nadmin.userdata[ply]
        if istable(targ) then 
            local targRank = nadmin:FindRank(targ.rank)
            if not targRank then return true end

            local callRank = self:GetRank()
            if not callRank then return false end

            return callRank.immunity >= targRank.immunity
        end
    end
    return false
end

-- Level stuff
function PLAYER:GetLevel()
    if not IsValid(self) then return {level = 0, xp = 0, need = 40} end

    local lvl = self:GetNWInt("nadmin_level", 1)
    local xp = self:GetNWInt("nadmin_xp", 0)
    local xpToLevel = GetXpToLevel(lvl)

    return {level = lvl, xp = xp, need = xpToLevel}
end

function GetXpToLevel(level)
    local x = nadmin:Ternary(isnumber(level), level, 0)
    return nadmin.levelReq.mult*x + nadmin.levelReq.base
end

--Nicknaming
if not isfunction(PLAYER.RealName) then PLAYER.RealName = PLAYER.Nick end
function PLAYER:Nick()
    if not IsValid(self) then return "[CONSOLE]" end
    if self:RealName() ~= self:GetNWString("nadmin_nickname") then return self:GetNWString("nadmin_nickname", self:RealName()) end
    return self:RealName()
end
PLAYER.Name = PLAYER.Nick
PLAYER.GetName = PLAYER.Nick

--Playtime
function PLAYER:GetPlayTime()
    if not IsValid(self) then return 0 end
    return self:GetNWInt("nadmin_playtime", 0)
end


--Admin stuff
function PLAYER:IsAdmin()
    if not IsValid(self) then return false end

    local rank = self:GetRank()
    if not rank then return false end

    if self:GetUserGroup() == "admin" or rank.immunity >= nadmin.immunity.admin then return true end
    if self:GetUserGroup() == "superadmin" or rank.immunity >= nadmin.immunity.superadmin then return true end
    if self:GetUserGroup() == "owner" or rank.immunity >= nadmin.immunity.owner or rank.ownerRank then return true end
    return false
end
function PLAYER:IsSuperAdmin()
    if not IsValid(self) then return false end

    local rank = self:GetRank()
    if not rank then return false end

    if self:GetUserGroup() == "superadmin" or rank.immunity >= nadmin.immunity.superadmin then return true end
    if self:GetUserGroup() == "owner" or rank.immunity >= nadmin.immunity.owner or rank.ownerRank then return true end
    return false
end
function PLAYER:IsOwner()
    if not IsValid(self) then return false end

    local rank = self:GetRank()
    if not rank then return false end

    if self:GetUserGroup() == "owner" or rank.immunity >= nadmin.immunity.owner or rank.ownerRank then return true end
    return false
end

--Formatting
function PLAYER:PlayerToString(str)
    if not IsValid(self) then return str end

    if isstring(str) then
        local s = str
        s = string.Replace(s, "nick", self:Nick())
        s = string.Replace(s, "steamid", self:SteamID())
        if SERVER then s = string.Replace(s, "ipaddress", self:IPAddress()) end
        return s
    end
    return str
end

function nadmin:FormatPlayerList(plys, join, sepCol)
    local p = istable(plys) and plys or player.GetAll()
    local j = isstring(join) and join or "or"
    local c = IsColor(sepCol) and sepCol or nadmin.colors.white

    local out = {}
    for i, ply in ipairs(p) do
        if not (isentity(ply) and ply:IsPlayer()) then continue end

        if i ~= 1 and i ~= #p then
            table.insert(out, c)
            table.insert(out, ", ")
        end
        if i == #p and i ~= 1 then
            table.insert(out, c)
            table.insert(out, ", " .. j .. " ")
        end

        local r = ply:GetRank()
        if istable(r) then table.insert(out, r.color) end

        table.insert(out, ply:Nick())
    end
    return out
end
function nadmin:FormatPlayerListNoColor(plys, join, format)
    local p = istable(plys) and plys or player.GetAll()
    local j = isstring(join) and join or "or"

    local out = ""
    for i, ply in ipairs(plys) do
        if not (isentity(ply) and ply:IsPlayer()) then continue end

        if i ~= 1 and i ~= #p then
            out = out .. ", "
        end
        if i == #p and i ~= 1 then
            out = out .. ", " .. j .. " "
        end

        local nick = ply:Nick()
        if isstring(format) then 
            nick = ply:PlayerToString(format)
        end
        out = out .. ply:Nick()
    end

    return out
end
