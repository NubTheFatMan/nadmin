if CLIENT then
    nadmin.uiColorPresets = {
        ["Default"] = {
            theme = nadmin.defaults.colors.gui.theme,
            blue = nadmin.defaults.colors.gui.blue,
            red = nadmin.defaults.colors.gui.red
        },
        ["Orange Sunset"] = {
            theme = nadmin:HexToColor("#a3586d"),
            blue = nadmin:HexToColor("#5c4a72"),
            red  = nadmin:HexToColor("#f3b05a")
        },
        ["Refreshing and Invigorating"] = {
            theme = nadmin:HexToColor("#003d73"),
            blue = nadmin:HexToColor("#1ecfd6"),
            red  = nadmin:HexToColor("#c05640")
        },
        ["Sophisticated and Calm"] = {
            theme = nadmin:HexToColor("#132226"),
            blue = nadmin:HexToColor("#525b56"),
            red  = nadmin:HexToColor("#be9063")
        },
        ["Sunset Over Swamp"] = {
            theme = nadmin:HexToColor("#6465a5"),
            blue = nadmin:HexToColor("#f3e96b"),
            red  = nadmin:HexToColor("#f05837")
        },
        ["Vintage 1950s"] = {
            theme = nadmin:HexToColor("#80add7"),
            blue = nadmin:HexToColor("#0abda0"),
            red  = nadmin:HexToColor("#bf9d7a")
        }
    }

    local saveBtn = nil
    nadmin.menu:RegisterTab({
        title = "Client Settings",
        sort = 5,
        forcedPriv = true,
        content = function(parent)
            local tabMenu = vgui.Create("NadminTabMenu", parent)
            tabMenu:SetPos(4, 4)
            tabMenu:SetSize(parent:GetWide() - 8, parent:GetTall() - 8)
            tabMenu:SetTabWidth(tabMenu:GetWide()/4)
            tabMenu:UseVerticalTabs(true)

            local colorsTab = tabMenu:AddTab("UI/Colors", function(parent)
                tabMenu:SetColor(nadmin.colors.gui.theme)

                local save = vgui.Create("NadminButton")
                local simplifyScoreboard = vgui.Create("NadminCheckBox")

                local function enableSave()
                    save:SetText("Click to save - keep changes after closing the game")
                    save:SetEnabled(true)
                end

                local colorDisplay = vgui.Create("DPanel", parent)
                colorDisplay:SetTall(128)
                colorDisplay:Dock(TOP)
                colorDisplay:DockMargin(4, 4, 4, 0)
                colorDisplay.black = Color(0, 0, 0) -- This is so I don't have to create the color black 3 times every frame
                function colorDisplay:Paint(w, h)
                    local gap = w/10
                    local themeX = w/2 - h/2 - h - gap
                    local inputX = w/2 - h/2
                    local errorX = w/2 + h/2 + gap

                    -- Draw background squares
                    draw.RoundedBox(0, themeX, 0, h, h, self.black)
                    draw.RoundedBox(0, inputX, 0, h, h, self.black)
                    draw.RoundedBox(0, errorX, 0, h, h, self.black)

                    -- Draw colors
                    draw.RoundedBox(0, themeX + 6, 6, h - 12, h - 12, nadmin.colors.gui.theme)
                    draw.RoundedBox(0, inputX + 6, 6, h - 12, h - 12, nadmin.colors.gui.blue)
                    draw.RoundedBox(0, errorX + 6, 6, h - 12, h - 12, nadmin.colors.gui.red)

                    -- Draw text
                    draw.SimpleText("Theme Color", "nadmin_derma_small", themeX + h/2, h/2, nadmin:TextColor(nadmin.colors.gui.theme), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Input Color", "nadmin_derma_small", inputX + h/2, h/2, nadmin:TextColor(nadmin.colors.gui.blue), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Error Color", "nadmin_derma_small", errorX + h/2, h/2, nadmin:TextColor(nadmin.colors.gui.red), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local presetColors = vgui.Create("NadminComboBox", parent)
                presetColors:Dock(TOP)
                presetColors:DockMargin(4, 4, 4, 0)
                presetColors:SetValue("Select a preset...")

                for name, colors in pairs(nadmin.uiColorPresets) do 
                    presetColors:AddChoice(name, colors)
                end

                local mixerWidth = (parent:GetWide() - 8)/3 - 8

                local colorMixers = vgui.Create("DPanel", parent)
                colorMixers:Dock(TOP)
                colorMixers:DockMargin(4, 4, 4, 0)
                colorMixers:DockPadding(0, 28, 0, 0)
                colorMixers:SetTall(153)
                function colorMixers:Paint(w, h)      
                    local textColor = nadmin:TextColor(nadmin.colors.gui.theme)         
                    draw.SimpleText("Theme Color:", "nadmin_derma", mixerWidth/2 - 50, 12, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Input Color:", "nadmin_derma", w/2 - 50, 12, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    draw.SimpleText("Error Color:", "nadmin_derma", w - mixerWidth/2 - 50, 12, textColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                end

                local themeMixer = vgui.Create("DColorMixer", colorMixers)
                themeMixer:Dock(LEFT)
                themeMixer:DockMargin(0, 0, 4, 0)
                themeMixer:SetWide(mixerWidth)
                themeMixer:SetAlphaBar(false)
                themeMixer:SetColor(nadmin.colors.gui.theme)
                themeMixer:SetPalette(false)
                function themeMixer:ValueChanged(color)
                    local theme = Color(color.r, color.g, color.b)
                    nadmin.colors.gui.theme = theme

                    -- Apply colors to everything open
                    presetColors:SetColor(nadmin:DarkenColor(theme, 25))
                    nadmin.menu.panel:SetColor(theme)
                    nadmin.menu.panel.tabMenu:SetColor(presetColors:GetColor())
                    tabMenu:SetColor(theme)
                    simplifyScoreboard:SetColor(theme)

                    enableSave()
                end

                local blueMixer = vgui.Create("DColorMixer", colorMixers)
                blueMixer:Dock(FILL)
                blueMixer:SetWide(mixerWidth)
                blueMixer:SetAlphaBar(false)
                blueMixer:SetColor(nadmin.colors.gui.blue)
                blueMixer:SetPalette(false)
                function blueMixer:ValueChanged(color)
                    local blue = Color(color.r, color.g, color.b)
                    nadmin.colors.gui.blue = blue

                    -- Apply colors to everything open
                    nadmin.menu.panel.closeButton:SetColor(blue)
                    nadmin.menu.panel.tabMenu:SetTabColor(blue)
                    tabMenu:SetTabColor(blue)
                    save:SetColor(blue)

                    enableSave()
                end

                local redMixer = vgui.Create("DColorMixer", colorMixers)
                redMixer:Dock(RIGHT)
                redMixer:DockMargin(4, 0, 0, 0)
                redMixer:SetWide(mixerWidth)
                redMixer:SetAlphaBar(false)
                redMixer:SetColor(nadmin.colors.gui.red)
                redMixer:SetPalette(false)
                function redMixer:ValueChanged(color)
                    nadmin.colors.gui.red = Color(color.r, color.g, color.b)
                    -- Colors don't need to be applied to anything since nothing using red should be on screen

                    enableSave()
                end

                function presetColors:OnSelect(ind, val, data)
                    nadmin.colors.gui.theme = data.theme
                    nadmin.colors.gui.blue = data.blue
                    nadmin.colors.gui.red = data.red

                    -- Apply colors to everything open
                    self:SetColor(nadmin:DarkenColor(data.theme, 25))
                    
                    nadmin.menu.panel:SetColor(data.theme)

                    nadmin.menu.panel.closeButton:SetColor(data.blue)

                    nadmin.menu.panel.tabMenu:SetColor(self:GetColor())
                    nadmin.menu.panel.tabMenu:SetTabColor(data.blue)

                    tabMenu:SetColor(data.theme)
                    tabMenu:SetTabColor(data.blue)

                    simplifyScoreboard:SetColor(data.theme)

                    save:SetColor(data.blue)

                    themeMixer:SetColor(data.theme)
                    blueMixer:SetColor(data.blue)
                    redMixer:SetColor(data.red)

                    enableSave()
                end

                local divider = vgui.Create("DPanel", parent)
                divider:Dock(TOP)
                divider:DockMargin(0, 8, 0, 4)
                divider:SetTall(2)
                function divider:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                end

                simplifyScoreboard:SetParent(parent)
                simplifyScoreboard:Dock(TOP)
                simplifyScoreboard:DockMargin(4, 4, 4, 0)
                simplifyScoreboard:SetText("Use Compact Scoreboard")
                simplifyScoreboard:SetChecked(nadmin.clientData.useCompactSB)
                function simplifyScoreboard:OnChange(use)
                    nadmin.clientData.useCompactSB = use

                    enableSave()
                end

                local divider2 = vgui.Create("DPanel", parent)
                divider2:Dock(TOP)
                divider2:DockMargin(0, 8, 0, 4)
                divider2:SetTall(2)
                divider2.Paint = divider.Paint

                save:SetParent(parent)
                save:Dock(TOP)
                save:DockMargin(4, 4, 4, 0)
                save.defaultText = "Make a change and click me to save!"
                save:SetText(save.defaultText)
                save:SetEnabled(false)

                function save:DoClick()
                    nadmin.clientData.guiColors = {
                        theme = nadmin.colors.gui.theme,
                        blue  = nadmin.colors.gui.blue,
                        red   = nadmin.colors.gui.red
                    }

                    file.Write("nadmin_config.txt", util.TableToJSON(nadmin.clientData))

                    self:SetText("Saved!")
                    self:SetEnabled(false)
                    timer.Simple(1, function()
                        if IsValid(self) then 
                            self:SetText(self.defaultText)
                        end
                    end)
                end
            end, true)

            local otherTab = tabMenu:AddTab("Server Preferences", function(parent)
                tabMenu:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                local save = vgui.Create("NadminButton")

                local options = {
                    {
                        setting = "allowNoclip",
                        title = "Noclip Anytime",
                        description = "Allows your noclip bind to work regardless of sbox_noclip convar. Requires \"Always Allow Noclip\" permission from the server."
                    },
                    {
                        setting = "physgunOthers",
                        title = "Physgun Pickup Other Players",
                        description = "Allows you to use your physgun to pickup other players. Requires \"Physgun Players\" permission from the server."
                    },
                    {
                        setting = "afkTime",
                        title = "Add to Playtime While AFK",
                        description = "Your playtime will not be paused if AFK. Requires \"Allow AFK Time\" permission from the server."
                    },
                    {
                        setting = "silentNotifs",
                        title = "See Silent Messages",
                        description = "Allows you to see commands that are ran silently. Requires \"See Silent Commands\" permission from the server."
                    },
                    {
                        setting = "hpRegen",
                        title = "Regenerate Health",
                        description = "Allows you to passively regenerate health when not taking damage. Requires \"Health Regeneration\" permission from the server."
                    },
                }
                
                for i, option in ipairs(options) do 
                    local container = vgui.Create("NadminPanel", parent)
                    container:Dock(TOP)
                    if i == 1 then 
                        container:DockMargin(4, 0, 0, 0)
                    else 
                        container:DockMargin(4, 4, 0, 0)
                    end
                    container:DockPadding(4, 4, 4, 0)
    
                    local toggle = vgui.Create("NadminCheckBox", container)
                    toggle:Dock(TOP)
                    toggle:SetText(option.title)
                    toggle:SetChecked(nadmin.clientData[option.setting])
                    function toggle:OnChange(val)
                        nadmin.clientData[option.setting] = val

                        save:SetEnabled(true)
                    end
    
                    local label = vgui.Create("NadminLabel", container)
                    label:Dock(TOP)
                    label:DockMargin(0, 4, 0, 0)
                    label:SetFont("nadmin_derma_small")
                    label:SetText(option.description)
    
                    container:InvalidateLayout(true)
                    container:SizeToChildren(false, true)
                end

                save:SetParent(parent)
                save:Dock(TOP)
                save:DockMargin(4, 4, 4, 0)
                save:SetText("Save Settings")
                save:SetEnabled(false)

                function save:DoClick()
                    net.Start("nadmin_player_preferences")
                        net.WriteTable({
                            allowNoclip   = nadmin.clientData.allowNoclip,
                            physgunOthers = nadmin.clientData.physgunOthers,
                            afkTime       = nadmin.clientData.afkTime,
                            silentNotifs  = nadmin.clientData.silentNotifs,
                            hpRegen       = nadmin.clientData.hpRegen
                        })
                    net.SendToServer()

                    file.Write("nadmin_config.txt", util.TableToJSON(nadmin.clientData))
                    save:SetEnabled(false)
                end
            end)
        end
    })
else 
    util.AddNetworkString("nadmin_player_preferences")
    
    nadmin.plyPref = nadmin.plyPref or {}

    net.Receive("nadmin_player_preferences", function(len, ply)
        nadmin.plyPref[ply:SteamID()] = net.ReadTable()

        MsgN("[Nadmin]Received " .. ply:Nick() .. "'s server preferences.")
    end)
end
