nadmin.clientData = nadmin.clientData or {}

if not file.Exists("nadmin_config.txt", "DATA") then    
    nadmin.clientData.allowNoclip   = true 
    nadmin.clientData.physgunOthers = true 
    nadmin.clientData.afkTime       = true 
    nadmin.clientData.silentNotifs  = true
    nadmin.clientData.hpRegen       = true
    nadmin.clientData.useCompactSB  = false
    nadmin.clientData.useCustomHud  = true
    
    nadmin.clientData.hudStyle      = "Fluid"
    
    nadmin.clientData.guiColors = {
        theme = nadmin.defaults.colors.gui.theme,
        blue  = nadmin.defaults.colors.gui.blue,
        red   = nadmin.defaults.colors.gui.red,
    }

    nadmin.clientData.friends = {}

    file.Write("nadmin_config.txt", util.TableToJSON(nadmin.clientData))
else 
    local json = file.Read("nadmin_config.txt", "DATA")
    json = util.JSONToTable(json)

    nadmin.clientData.allowNoclip   = json.allowNoclip   or true
    nadmin.clientData.physgunOthers = json.physgunOthers or true
    nadmin.clientData.afkTime       = json.afkTime       or true
    nadmin.clientData.silentNotifs  = json.silentNotifs  or true
    nadmin.clientData.hpRegen       = json.hpRegen       or true
    nadmin.clientData.useCompactSB  = json.useCompactSB  or false
    nadmin.clientData.useCustomHud  = json.useCustomHud  or true
    
    nadmin.clientData.hudStyle = json.hudStyle or "Fluid"
    
    local t = json.guiColors.theme or nadmin.defaults.colors.gui.theme
    local b = json.guiColors.blue  or nadmin.defaults.colors.gui.blue
    local r = json.guiColors.red   or nadmin.defaults.colors.gui.red
    
    local theme = Color(t.r, t.g, t.b, t.a)
    local blue  = Color(b.r, b.g, b.b, b.a)
    local red   = Color(r.r, r.g, r.b, r.a)

    nadmin.clientData.guiColors = {
        theme = theme,
        blue  = blue,
        red   = red
    }

    nadmin.colors.gui.theme = theme
    nadmin.colors.gui.blue  = blue
    nadmin.colors.gui.red   = red

    nadmin.clientData.friends = json.friends or {}
end
