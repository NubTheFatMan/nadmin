if not nadmin.plugins.propprotec then return end

nadmin.pp = {}
nadmin.pp.propOwners = {}
nadmin.pp.propNames = {}
nadmin.pp.friends = {}

local props = nadmin.pp.propOwners
local propNames = nadmin.pp.propNames
net.Receive("nadmin_send_props", function(len)
    local nameMap = {}
    for i = 1, net.ReadUInt(8) do
        nameMap[i] = {steamid = net.ReadString(), nick = net.ReadString()}
    end
    for i = 1, net.ReadUInt(32) do 
        local id, owner = net.ReadUInt(16), nameMap[net.ReadUInt(8)]
        if owner.steamid == "-" then props[id] = nil propNames[id] = nil
        elseif owner.steamid == "W" then propNames[id] = "World"
        elseif owner.steamid == "O" then propNames[id] = "Ownerless"
        else 
            props[id] = owner.steamid
            propNames[id] = owner.nick
        end
    end
end)

function nadmin.pp.GetPropOwner(ent)
    local id = props[ent:EntIndex()]
    if id then return player.GetBySteamID(id) end
end

function nadmin.pp.PlayerCanTouch(ply, ent)
    if ent:IsWorld() then return ent:GetClass() == "worldspawn" end
    if not IsValid(ent) or not IsValid(ply) or ent:IsPlayer() or not ply:IsPlayer() then return false end

    local index = ent:EntIndex()
    if not props[index] then return false end

    if propNames[index] == "Ownerless" then return true end
    if ply:HasPerm("physgun_player_props") then return ply:BetterThan(nadmin.pp.GetPropOwner(props[index])) end
end

local font = "ChatFont"
hook.Add("HUDPaint", "nadmin_pp_hud", function()
    if not nadmin.plugins.propprotec then return end

    local tr = LocalPlayer():GetEyeTrace()
    if not tr.HitNonWorld then return end

    local ent = tr.Entity
    if ent:IsValid() and not ent:IsPlayer() then 
        surface.SetFont(font)
        
        local text = "Owner: " .. (propNames[ent:EntIndex()] or "N/A")
        local w, h = surface.GetTextSize(text)

        local boxW = w + 25
        local boxH = h + 16

        local text2 = "'" .. string.sub(table.remove(string.Explode("/", ent:GetModel() or "?")), 1, -5) .. "' [" .. ent:EntIndex() .. "]"
        local text3 = ent:GetClass()
        
        local w2, h2 = surface.GetTextSize(text2)
        local w3, h3 = surface.GetTextSize(text3)

        boxW = math.Max(w, w2, w3) + 25
        boxH = boxH + h2 + h3

        draw.RoundedBox(4, ScrW() - (boxW + 4), (ScrH()/2 - 200) - 16, boxW, boxH, nadmin:AlphaColor(nadmin.colors.gui.theme, 150))
        draw.RoundedBox(4, ScrW() - (boxW + 4), (ScrH()/2 - 200) - 16, 4, boxH, nadmin:AlphaColor(nadmin.colors.gui.blue, 150))
        draw.SimpleText(text, font, ScrW() - (w / 2) - 20, ScrH()/2 - 200, Color(255, 255, 255), 1, 1)
        draw.SimpleText(text2, font, ScrW() - (w2 / 2) - 20, ScrH()/2 - 200 + h, Color(255, 255, 255), 1, 1)
        draw.SimpleText(text3, font, ScrW() - (w3 / 2) - 20, ScrH()/2 - 200 + h + h2, Color(255, 255, 255), 1, 1)
    end
end)

hook.Add("Initialize", "nadmin_pp_send_friends", function() 
    net.Start("nadmin_receive_friends")
        net.WriteTable(nadmin.clientData.friends)
    net.SendToServer()
end)

function nadmin.pp.SetPlayerCVars()
    for i, ply in pairs(player.GetHumans()) do 
        if ply ~= LocalPlayer() then 
            CreateClientConVar("nadmin_pp_friend_" .. ply:SteamID64(), table.HasValue(nadmin.clientData.friends, ply:SteamID64()) and "1" or "0", false)
            RunConsoleCommand("nadmin_pp_friend_" .. ply:SteamID64(), table.HasValue(nadmin.clientData.friends, ply:SteamID64()) and "1" or "0")
        end
    end
end

concommand.Add("nadmin_pp_apply_friends", function()
    for i, ply in pairs(player.GetHumans()) do 
        local id = ply:SteamID64()
        local cvar = GetConVar("nadmin_pp_friend_" .. id)
        if cvar ~= nil then 
            local friends = nadmin.clientData.friends
            if cvar:GetBool() then 
                if not table.HasValue(friends, ply:SteamID64()) then 
                    table.insert(friends, ply:SteamID64())
                end
            else 
                for x, fr in ipairs(friends) do 
                    if fr == id then 
                        table.remove(friends, x) 
                        break 
                    end
                end
            end
            file.Write("nadmin_config.txt", util.TableToJSON(nadmin.clientData))
            net.Start("nadmin_receive_friends")
                net.WriteTable(friends)
            net.SendToServer()
        end
    end
    nadmin:Notify(nadmin.colors.blue, "Friends updated!")
end)

function nadmin.pp.ClientPanel(panel)
    if panel then 
        if not nadmin.pp.ClientCPanel then nadmin.pp.ClientCPanel = panel end
    end
    panel:ClearControls()
    panel:SetName("Nadmin Prop Protection - Client Settings")

    panel:Button("Cleanup My Props", "gmod_cleanup")

    local txt = panel:Help("Friends")
    txt:SetContentAlignment(TEXT_ALIGN_CENTER)
    txt:SetFont("DermaDefaultBold")
    txt:SetAutoStretchVertical(false)

    local players = player.GetHumans()
    if #players == 1 then 
        panel:Help("No other players are online. Loser. jk I love you <3")
    else 
        nadmin.pp.SetPlayerCVars()
        for i, ply in pairs(players) do 
            if ply ~= LocalPlayer() then 
                local btn = panel:CheckBox(ply:Nick(), "nadmin_pp_friend_" .. ply:SteamID64())
                if ply:HasPerm("physgun_player_props") and ply:BetterThan(LocalPlayer()) then btn:SetToolTip("This player can still touch your stuff based on Nadmin privileges") end
            end
        end
        panel:Button("Apply Friends", "nadmin_pp_apply_friends")
    end
end

nadmin.pp.config = {}
net.Receive("nadmin_update_pp", function()
    local config = net.ReadTable()
    nadmin.pp.config = config
    for cfg, v in pairs(config) do
        local val = "0"
        if isbool(v) then val = tostring(nadmin:BoolToInt(v)) end
        if isnumber(v) then val = tostring(v) end
        CreateClientConVar("nadmin_pp_admin_" .. cfg, val, false)
        RunConsoleCommand("nadmin_pp_admin_" .. cfg, val)
    end
end)

concommand.Add('nadmin_apply_pp', function() 
    for key, val in pairs(nadmin.pp.config) do 
        local cvar = GetConVar("nadmin_pp_admin_" .. key)
        if isbool(val) then nadmin.pp.config[key] = cvar:GetBool() end
        if isnumber(val) then nadmin.pp.config[key] = cvar:GetInt() end
    end
    net.Start("nadmin_update_pp")
        net.WriteTable(nadmin.pp.config)
    net.SendToServer()
end)

function nadmin.pp.AdminPanel(panel)
    if panel then 
        if not nadmin.pp.AdminCPanel then nadmin.pp.AdminCPanel = panel end 
    end
    panel:ClearControls()
    panel:SetName("Nadmin Prop Protection - Server Settings")

    if not LocalPlayer():HasPerm("manage_pp") then 
        panel:Help("You do not have permission to manage Prop Protection settings.")
        return
    end

    local protec = panel:CheckBox("Use (E) Protection", "nadmin_pp_use_protec")
    protec:SetToolTip("Stop nonfriends from entering vehicles, pushing buttons, etc")

    local cdp = panel:Help("Autoclean Disconnected Players")
    cdp:SetAutoStretchVertical(false)
    cdp:SetContentAlignment(TEXT_ALIGN_CENTER)
    cdp:SetFont("DermaDefaultBold")

    local enabled = panel:CheckBox("Enabled", "nadmin_pp_admin_cdp_enabled")
    enabled:SetToolTip("Should players props be automatically cleaned after they disconnect?")

    local cAdmins = panel:CheckBox("Clean admins?", "nadmin_pp_admin_cdp_admins")
    cAdmins:SetToolTip("Should the props of players who can touch other player's props be deleted?")

    local timeout = panel:NumSlider("Autoclean timer", "nadmin_pp_admin_cdp_time", 0, 1200, 0)
    timeout:SetToolTip("How long (in seconds) should player's props be automatically cleaned?")

    panel:Button("Apply Settings", "nadmin_apply_pp")

    if not LocalPlayer():HasPerm("pp_cleanup_panel") then return end

    local clean = panel:Help("Cleanup Panel")
    clean:SetAutoStretchVertical(false)
    clean:SetContentAlignment(TEXT_ALIGN_CENTER)
    clean:SetFont("DermaDefaultBold")

    local counts = {}
    local dccount = 0
    for i, p in pairs(props) do
        counts[p] = (counts[p] or 0) + 1
    end
    for i, p in pairs(counts) do
        if i ~= "World"and i ~= "Ownerless" then dccount = dccount + p end
    end
    for i, ply in pairs(player.GetHumans()) do 
        local steamid = ply:SteamID()
        if LocalPlayer():HasPerm("cleanup_player") then panel:Button(ply:Nick() .. " (" .. (counts[steamid] or 0) .. ")", "nadmin_cleanup", steamid) end
        dccount = dccount - (counts[steamid] or 0)
    end

    panel:Help(""):SetAutoStretchVertical(false)
    panel:Button("Cleanup Disconnected Players Props (" .. dccount .. ")", "nadmin", "cleanupdisconnected")
    panel:Button("Cleanup All NPCs", "nadmin_cleanclass", "npc_*")
    panel:Button("Cleanup All Ragdolls", "nadmin_cleanclass", "prop_ragdol*")
    panel:Button("Cleanup Clientside Ragdolls", "nadmin", "gibs")
    panel:Button("Cleanup World Ropes", "nadmin", "cleanropes")
end

-- Apparently you can only have one argument with <DForm>:Button(), so I made this ( ͡° ͜ʖ ͡°)
concommand.Add("nadmin_cleanclass", function(ply, cmd, args, argStr) 
    LocalPlayer():ConCommand("nadmin cleanclass " .. argStr)
end)
concommand.Add("nadmin_cleanup", function(ply, cmd, args, argStr)
    LocalPlayer():ConCommand("nadmin cleanup " .. argStr)
end)

function nadmin.pp.SpawnMenuOpen()
    if nadmin.pp.ClientCPanel then 
        nadmin.pp.ClientPanel(nadmin.pp.ClientCPanel)
    end
    if nadmin.pp.AdminCPanel then 
        nadmin.pp.AdminPanel(nadmin.pp.AdminCPanel)
    end
end
hook.Add("SpawnMenuOpen", "nadmin_pp_spawn_menu_open", nadmin.pp.SpawnMenuOpen)

function nadmin.pp.PopulateToolMenu()
    spawnmenu.AddToolMenuOption("Nadmin", "Client", "pp_client", "Prop Protection", "", "", nadmin.pp.ClientPanel)
    spawnmenu.AddToolMenuOption("Nadmin", "Server", "pp_server", "Prop Protection", "", "", nadmin.pp.AdminPanel)
end
hook.Add("PopulateToolMenu", "nadmin_pp_populate_tool_menu", nadmin.pp.PopulateToolMenu)

CPPI = {}

function CPPI:GetName() return "Nadmin Prop Protection" end 
function CPPI:GetVersion() return nadmin.version end

local ENTITY = debug.getregistry().Entity
function ENTITY:CPPIGetFriends() return {} end 
function ENTITY:CPPIGetOwner() return nadmin.pp.GetPropOwner(self) end
function ENTITY:CPPICanTool(ply, mode) return nadmin.pp.PlayerCanTouch(ply, self) end
function ENTITY:CPPICanPhysgun(ply) return nadmin.pp.PlayerCanTouch(ply, self) end
function ENTITY:CPPICanPickup(ply) return nadmin.pp.PlayerCanTouch(ply, self) end
function ENTITY:CPPICanPunt(ply) return nadmin.pp.PlayerCanTouch(ply, self) end