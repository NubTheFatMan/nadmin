--This to to prevent errors if you do NULL:Nick() or something like that.
local ENTITY = FindMetaTable("Entity")

function ENTITY:Nick()
    return "[CONSOLE]"
end

function ENTITY:SteamID()
    return "nil"
end

function ENTITY:IPAddress()
    return game.GetIPAddress()
end

function ENTITY:PlayerToString()
    return "[CONSOLE]"
end
