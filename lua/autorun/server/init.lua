MsgN("/--               Nadmin               --\\")
MsgN("|----------------------------------------|")

AddCSLuaFile("nadmin/variables.lua")
include("nadmin/variables.lua")
MsgN("Loaded variables")
local sf = 1

include("nadmin/update.lua")

local coreFiles, _ = file.Find("nadmin/server/core/*.lua", "LUA")
local ci = 0
for _, core in pairs(coreFiles) do
    ci = ci + 1
    include("nadmin/server/core/" .. core)
end
local coreShared = file.Find("nadmin/shared/core/*.lua", "LUA")
for _, core in pairs(coreShared) do
    ci = ci + 1
    sf = sf + 1
    AddCSLuaFile("nadmin/shared/core/" .. core)
    include("nadmin/shared/core/" .. core)
end
MsgN(tostring(ci) .." core files loaded!")

local handlers, _ = file.Find("nadmin/server/handlers/*.lua", "LUA")
local hi = 0
for _, handler in pairs(handlers) do
    hi = hi + 1
    include("nadmin/server/handlers/" .. handler)
end
local handlerShared = file.Find("nadmin/shared/handlers/*.lua", "LUA")
for _, handler in pairs(handlerShared) do 
    hi = hi + 1
    include("nadmin/shared/handlers/" .. handler)
    AddCSLuaFile("nadmin/shared/handlers/" .. handler)
end
MsgN(tostring(hi) .. " handler files loaded!")

local plugins, _ = file.Find("nadmin/plugins/*.lua", "LUA")
local pi = 0
for _, plug in pairs(plugins) do
    pi = pi + 1
    include("nadmin/plugins/" .. plug)
    sf = sf + 1
    AddCSLuaFile("nadmin/plugins/" .. plug)
end
MsgN(tostring(pi) .. " plugin files loaded!")

-- Send files to clients
local cores, _ = file.Find("nadmin/client/core/*.lua", "LUA")
for _, core in pairs(cores) do
    sf = sf + 1
    AddCSLuaFile("nadmin/client/core/" .. core)
end

local handlers = file.Find("nadmin/client/handlers/*.lua", "LUA")
for _, handler in pairs(handlers) do
    sf = sf + 1
    AddCSLuaFile("nadmin/client/handlers/" .. handler)
end

MsgN(tostring(sf) .. " client files marked for download.")


include("nadmin/default_ranks.lua")
MsgN("Ranks loaded!")

-- Sounds
resource.AddFile("sound/nadmin/clickdown.ogg")
resource.AddFile("sound/nadmin/clickup.ogg")

MsgN("|----------------------------------------|")
MsgN("\\--               Nadmin               --/")