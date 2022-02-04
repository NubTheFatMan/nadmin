MsgN("[Nadmin]Initializing client...")
include("nadmin/variables.lua")

local coreFiles, _ = file.Find("nadmin/client/core/*.lua", "LUA")
for _, core in pairs(coreFiles) do
    include("nadmin/client/core/" .. core)
end
local coreShared = file.Find("nadmin/shared/core/*.lua", "LUA")
for _, core in pairs(coreShared) do
    include("nadmin/shared/core/" .. core)
end

local handlers, _ = file.Find("nadmin/client/handlers/*.lua", "LUA")
for _, handler in pairs(handlers) do
    include("nadmin/client/handlers/" .. handler)
end

local handlersShared, _ = file.Find("nadmin/shared/handlers/*.lua", "LUA")
for _, handler in pairs(handlersShared) do
    include("nadmin/shared/handlers/" .. handler)
end

local plugins, _ = file.Find("nadmin/plugins/*.lua", "LUA")
for _, plug in pairs(plugins) do
    include("nadmin/plugins/" .. plug)
end

MsgN("[Nadmin]Successfully initialized.")
