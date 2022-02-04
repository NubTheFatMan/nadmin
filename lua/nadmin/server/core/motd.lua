util.AddNetworkString("nadmin_fetch_motd_cfg")
util.AddNetworkString("nadmin_update_motd_cfg")
util.AddNetworkString("nadmin_open_motd")

nadmin.config.motd = nadmin.config.motd or {}

local loaded = file.Read("nadmin/config/motd.txt", "DATA")
if isstring(loaded) then
    loaded = util.JSONToTable(loaded)
    motd = loaded
end

if not isbool(nadmin.config.motd.enabled) then nadmin.config.motd.enabled = true end
if not isstring(nadmin.config.motd.using) then nadmin.config.motd.using = "Generator" end
if not istable(nadmin.config.motd.modes) then nadmin.config.motd.modes = {} end

if not istable(nadmin.config.motd.modes.gen) then
    nadmin.config.motd.modes.gen = {
        title = {
            text = "Welcome to %HostName%!",
            subtext = "Enjoy your stay!",
            bgcol = nadmin.colors.gui.blue,
            txcol = nadmin.colors.white,
        },
        contents = {}
    }
end
if not isstring(nadmin.config.motd.modes.url) then
    nadmin.config.motd.modes.url = "https://www.google.com/"
end

local PLAYER = PLAYER or FindMetaTable("Player")

function PLAYER:Nadmin_OpenMOTD()
    if not IsValid(self) then return end
    if not nadmin.config.motd.enabled then return end

    net.Start("nadmin_open_motd")
        net.WriteString(nadmin.config.motd.using) -- Writing the mode we are using
        if nadmin.config.motd.using == "Generator" then -- Only send generator info to limit information sent
            net.WriteTable(nadmin.config.motd.modes.gen)
        elseif nadmin.config.motd.using == "Local File" then -- Open the local file and check for errors
            local info = file.Read("nadmin/motd.txt", "DATA")
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
        elseif nadmin.config.motd.using == "URL" then
            net.WriteString(nadmin.config.motd.modes.url)
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
        nadmin.config.motd.enabled = enabled
    end

    local using = net.ReadString()
    if isstring(using) then
        nadmin.config.motd.using = using
    end

    if using == "Generator" then
        local data = net.ReadTable()
        if istable(data) then
            nadmin.config.motd.modes.gen = table.Copy(data)
        end
    elseif using == "URL" then
        local url = net.ReadString()
        if isstring(url) then
            nadmin.config.motd.modes.url = url
        end
    end

    file.Write("nadmin/config/motd.txt", util.TableToJSON(nadmin.config.motd))
    nadmin:Log("server_management", ply:Nick() .. " updated the MOTD.")
end)

net.Receive("nadmin_fetch_motd_cfg", function(len, ply)
    local using = net.ReadString()

    if not isstring(using) or using == "_get" then using = nadmin.config.motd.using end

    net.Start("nadmin_fetch_motd_cfg")
        net.WriteBool(nadmin.config.motd.enabled) -- Write if the MOTD is even in use
        net.WriteString(using) -- Writing the mode we are using
        if using == "Generator" then -- Only send generator info to limit information sent
            net.WriteTable(nadmin.config.motd.modes.gen)
        elseif using == "Local File" then -- Open the local file and check for errors
            local info = file.Read("nadmin/motd.txt", "DATA")
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
            net.WriteString(nadmin.config.motd.modes.url)
        end
    net.Send(ply)
end)
