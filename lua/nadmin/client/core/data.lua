nadmin.clientData = nadmin.clientData or {}

if not file.Exists("nadmin_config.txt", "DATA") then    
    nadmin.clientData.allowNoclip   = true 
    nadmin.clientData.physgunOthers = true 
    nadmin.clientData.afkTime       = false 
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

    -- lua "ternary" is weird. (condition) and (truthy_value) or (falsey_value)
    nadmin.clientData.allowNoclip   = not isbool(json.allowNoclip)   and true              or json.allowNoclip
    nadmin.clientData.physgunOthers = not isbool(json.physgunOthers) and true              or json.physgunOthers
    nadmin.clientData.afkTime       =     isbool(json.afkTime)       and json.afkTime      or false
    nadmin.clientData.silentNotifs  = not isbool(json.silentNotifs)  and true              or json.silentNotifs
    nadmin.clientData.hpRegen       = not isbool(json.hpRegen)       and true              or json.hpRegen
    nadmin.clientData.useCompactSB  =     isbool(json.useCompactSB)  and json.useCompactSB or false
    nadmin.clientData.useCustomHud  = not isbool(json.useCustomHud)  and true              or json.useCustomHud

    -- nadmin.clientData.allowNoclip   = nadmin:Ternary(isbool(json.allowNoclip),   json.allowNoclip,   true)
    -- nadmin.clientData.physgunOthers = nadmin:Ternary(isbool(json.physgunOthers), json.physgunOthers, true)
    -- nadmin.clientData.afkTime       = nadmin:Ternary(isbool(json.afkTime),       json.afkTime,       false)
    -- nadmin.clientData.silentNotifs  = nadmin:Ternary(isbool(json.silentNotifs),  json.silentNotifs,  true)
    -- nadmin.clientData.hpRegen       = nadmin:Ternary(isbool(json.hpRegen),       json.hpRegen,       true)
    -- nadmin.clientData.useCompactSB  = nadmin:Ternary(isbool(json.useCompactSB),  json.useCompactSB,  false)
    -- nadmin.clientData.useCustomHud  = nadmin:Ternary(isbool(json.useCustomHud),  json.useCustomHud,  true)
    
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
