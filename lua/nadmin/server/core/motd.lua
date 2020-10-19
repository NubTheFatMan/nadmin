util.AddNetworkString("nadmin_fetch_motd_cfg")
util.AddNetworkString("nadmin_update_motd_cfg")
util.AddNetworkString("nadmin_open_motd")

nadmin.config.motd = nadmin.config.motd or {}
local motd = nadmin.config.motd

local loaded = file.Read("nadmin/config/motd.txt", "DATA")
if isstring(loaded) then
    loaded = util.JSONToTable(loaded)
    motd = loaded
end

if not isbool(motd.enabled) then motd.enabled = true end
if not isstring(motd.using) then motd.using = "Generator" end
if not istable(motd.modes) then motd.modes = {} end

if not istable(motd.modes.gen) then
    motd.modes.gen = {
        title = {
            text = "Welcome to %HostName%!",
            font = "nadmin_derma",
            bgcol = nadmin.colors.gui.blue
        },
        subtitle = {
            text = "Enjoy your stay!",
            font = "nadmin_derma_small_b"
        },
        contents = {}
    }
end
if not isstring(motd.modes.url) then
    motd.modes.url = "https://www.google.com/"
end

local PLAYER = PLAYER or FindMetaTable("Player")

function PLAYER:Nadmin_OpenMOTD()
    if not IsValid(self) then return end
    if not motd.enabled then return end

    net.Start("nadmin_open_motd")
        net.WriteString(motd.using) -- Writing the mode we are using
        if motd.using == "Generator" then -- Only send generator info to limit information sent
            net.WriteTable(motd.modes.gen)
        elseif motd.using == "Local File" then -- Open the local file and check for errors
            local info = file.Read("addons/nadmin/motd.txt", "GAME")
            if isstring(info) then
                if string.len(info) <= 65523 then
                    net.WriteBool(false) -- No error occured
                    net.WriteString(info)
                else
                    net.WriteBool(true) -- Is Errored check
                    net.WriteString("413: File length exceeded 65523, and was too large to be sent.") -- What error occured
                end
            else
                net.WriteBool(true) -- Is Errored check
                net.WriteString("404: File \"garrysmod/addons/nadmin/motd.txt\" not found.") -- What error occured
            end
        elseif motd.using == "URL" then
            net.WriteString(motd.modes.url)
        end
    net.Send(self)

    return true
end

net.Receive("nadmin_update_motd_cfg", function(len, ply)
    if not ply:HasPerm("manage_server_settings") then
        nadmin:Notify(ply, nadmin.colors.red, "You aren't allowed to manage server settings.")
        return
    end

    local enabled = net.ReadBool()
    if isbool(enabled) then
        motd.enabled = enabled
    end

    local using = net.ReadString()
    if isstring(using) then
        motd.using = using
    end

    if using == "Generator" then
        local gen = net.ReadTable()
        if istable(gen) then
            motd.modes.gen = gen
        end
    elseif using == "URL" then
        local url = net.ReadString()
        if isstring(url) then
            motd.modes.url = url
        end
    end

    file.Write("nadmin/config/motd.txt", util.TableToJSON(motd))
end)

net.Receive("nadmin_fetch_motd_cfg", function(len, ply)
    local using = net.ReadString()

    if using == "%GETMODE%" then using = motd.using end

    net.Start("nadmin_fetch_motd_cfg")
        net.WriteBool(motd.enabled) -- Write if the MOTD is even in use
        net.WriteString(using) -- Writing the mode we are using
        if using == "Generator" then -- Only send generator info to limit information sent
            net.WriteTable(motd.modes.gen)
        elseif using == "Local File" then -- Open the local file and check for errors
            local info = file.Read("addons/nadmin/motd.txt", "GAME")
            if isstring(info) then
                if string.len(info) <= 65523 then
                    net.WriteBool(false) -- No error occured
                    net.WriteString(info)
                else
                    net.WriteBool(true) -- Is Errored check
                    net.WriteString("413: File length exceeded 65523, and was too large to be sent.") -- What error occured
                end
            else
                net.WriteBool(true) -- Is Errored check
                net.WriteString("404: File \"garrysmod/addons/nadmin/motd.txt\" not found.") -- What error occured
            end
        elseif using == "URL" then
            net.WriteString(motd.modes.url)
        end
    net.Send(ply)
end)
