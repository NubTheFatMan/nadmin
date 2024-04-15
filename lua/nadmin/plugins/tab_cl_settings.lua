if CLIENT then
    local saveBtn = nil
    nadmin.menu:RegisterTab({
        title = "Client Settings",
        sort = 5,
        forcedPriv = true,
        content = function(parent)
            local w, h = parent:GetWide(), parent:GetTall()

            local leftPanel = nadmin.vgui:DPanel(nil, {parent:GetWide()/6, parent:GetTall()}, parent)
            leftPanel:Dock(LEFT)
            leftPanel:DockPadding(0, 4, 4, 4)
            leftPanel.btns = {}
            leftPanel.normalPaint = leftPanel.Paint 
            function leftPanel:Paint(w, h)
                self:SetColor(nadmin.colors.gui.theme)
                self:normalPaint(w, h)
            end

            content = nadmin.vgui:DPanel(nil, {parent:GetWide() - parent:GetWide()/6, parent:GetTall()}, parent)
            content:Dock(FILL)
            content:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            function content:Paint(w, h)
                draw.Text({
                    text = "Please select an option on the left.",
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    font = "nadmin_derma",
                    color = tc
                })
            end

            local categories = {
                {"Colors", "icon16/paintbrush.png", function()
                    -- Display for colors
                    local display = nadmin.vgui:DPanel(nil, {content:GetWide()-8, 96}, content)
                    display:Dock(TOP)
                    display:DockMargin(4, 4, 4, 0)
                    display:SetColor(Color(0, 0, 0, 0))
                    
                    local theme = nadmin.vgui:DPanel({display:GetWide()/2 - display:GetTall()*2, 0}, {display:GetTall(), display:GetTall()}, display)
                    function theme:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
                        draw.RoundedBox(0, 4, 4, w-8, h-8, nadmin.colors.gui.theme)
                        draw.SimpleText("Theme Color", "nadmin_derma_small", w/2, h/2, nadmin:TextColor(nadmin.colors.gui.theme), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local blue = nadmin.vgui:DPanel({display:GetWide()/2 - display:GetTall()/2, 0}, {display:GetTall(), display:GetTall()}, display)
                    function blue:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
                        draw.RoundedBox(0, 4, 4, w-8, h-8, nadmin.colors.gui.blue)
                        draw.SimpleText("Button Color", "nadmin_derma_small", w/2, h/2, nadmin:TextColor(nadmin.colors.gui.blue), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local red = nadmin.vgui:DPanel({display:GetWide()/2 + display:GetTall(), 0}, {display:GetTall(), display:GetTall()}, display)
                    function red:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0))
                        draw.RoundedBox(0, 4, 4, w-8, h-8, nadmin.colors.gui.red)
                        draw.SimpleText("Error Color", "nadmin_derma_small", w/2, h/2, nadmin:TextColor(nadmin.colors.gui.red), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
                    end

                    local preset = nadmin.vgui:DComboBox(nil, {content:GetWide()-8, 32}, content)
                    preset:Dock(TOP)
                    preset:DockMargin(4, 4, 4, 0)
                    preset:SetColor(nadmin.colors.gui.theme)
                    preset:SetValue("Select a preset...")
                    preset:SetSortItems(false)

                    preset.normalPaint = preset.Paint 
                    function preset:Paint(w, h)
                        self:SetColor(nadmin.colors.gui.theme)
                        self:normalPaint(w, h)
                    end

                    preset:AddChoice("Default", {
                        main = nadmin.defaults.colors.gui.theme,
                        blue = nadmin.defaults.colors.gui.blue,
                        red  = nadmin.defaults.colors.gui.red
                    })
                    preset:AddChoice("Orange Sunset", {
                        main = nadmin:HexToColor("#a3586d"),
                        blue = nadmin:HexToColor("#5c4a72"),
                        red  = nadmin:HexToColor("#f3b05a")
                    })
                    preset:AddChoice("Refreshing and Invigorating", {
                        main = nadmin:HexToColor("#003d73"),
                        blue = nadmin:HexToColor("#1ecfd6"),
                        red  = nadmin:HexToColor("#c05640")
                    })
                    preset:AddChoice("Sophisticated and Calm", {
                        main = nadmin:HexToColor("#132226"),
                        blue = nadmin:HexToColor("#525b56"),
                        red  = nadmin:HexToColor("#be9063")
                    })
                    preset:AddChoice("Sunset over Swamp", {
                        main = nadmin:HexToColor("#6465a5"),
                        blue = nadmin:HexToColor("#f3e96b"),
                        red  = nadmin:HexToColor("#f05837")
                    })
                    preset:AddChoice("Vintage 1950s", {
                        main = nadmin:HexToColor("#80add7"),
                        blue = nadmin:HexToColor("#0abda0"),
                        red  = nadmin:HexToColor("#bf9d7a")
                    })

                    local thText = vgui.Create("DLabel", content)
                    thText:SetPos(4, display:GetTall() + preset:GetTall() + 16)
                    thText:SetText("")
                    thText:SetSize(parent:GetWide()/3, 19)
                    thText:SetFont("nadmin_derma")
                    function thText:Paint(w, h)
                        draw.Text({
                            text = "Theme Color:",
                            font = self:GetFont(),
                            pos = {0, h/2},
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end
                    local main = vgui.Create("DColorMixer", content)
                    main:SetPos(4, display:GetTall() + preset:GetTall() + 36)
                    main:SetSize(content:GetWide()/3 - 8, 125)
                    main:SetAlphaBar(false)
                    main:SetColor(nadmin.colors.gui.theme)
                    main:SetPalette(false)
                    function main:ValueChanged(col)
                        nadmin.colors.gui.theme = Color(col.r, col.g, col.b)
                    end

                    local blText = vgui.Create("DLabel", content)
                    blText:SetPos(content:GetWide()/3 + 2, display:GetTall() + preset:GetTall() + 16)
                    blText:SetText("")
                    blText:SetSize(content:GetWide()/3, 19)
                    blText:SetFont("nadmin_derma")
                    function blText:Paint(w, h)
                        draw.Text({
                            text = "Button Color:",
                            font = self:GetFont(),
                            pos = {0, h/2},
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end
                    local blueMix = vgui.Create("DColorMixer", content)
                    blueMix:SetPos(content:GetWide()/3 + 2, display:GetTall() + preset:GetTall() + 36)
                    blueMix:SetSize(content:GetWide()/3 - 6, 125)
                    blueMix:SetAlphaBar(false)
                    blueMix:SetColor(nadmin.colors.gui.blue)
                    blueMix:SetPalette(false)
                    function blueMix:ValueChanged(col)
                        nadmin.colors.gui.blue = Color(col.r, col.g, col.b)
                    end

                    local reText = vgui.Create("DLabel", content)
                    reText:SetPos(content:GetWide() * 2/3 + 2, display:GetTall() + preset:GetTall() + 16)
                    reText:SetText("")
                    reText:SetSize(content:GetWide()/3, 19)
                    reText:SetFont("nadmin_derma")
                    function reText:Paint(w, h)
                        draw.Text({
                            text = "Error Color:",
                            font = self:GetFont(),
                            pos = {0, h/2},
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end
                    local redMix = vgui.Create("DColorMixer", content)
                    redMix:SetPos(content:GetWide() * 2/3 + 2, display:GetTall() + preset:GetTall() + 36)
                    redMix:SetSize(content:GetWide()/3 - 6, 125)
                    redMix:SetAlphaBar(false)
                    redMix:SetColor(nadmin.colors.gui.red)
                    redMix:SetPalette(false)
                    function redMix:ValueChanged(col)
                        nadmin.colors.gui.red = Color(col.r, col.g, col.b)
                    end

                    function preset:OnSelect(ind, val, data)
                        nadmin.colors.gui.theme = data.main
                        main:SetColor(nadmin.colors.gui.theme)
        
                        nadmin.colors.gui.blue = data.blue
                        blueMix:SetColor(nadmin.colors.gui.blue)
        
                        nadmin.colors.gui.red = data.red
                        redMix:SetColor(nadmin.colors.gui.red)
                    end

                    local save = nadmin.vgui:DButton({4, display:GetTall() + preset:GetTall() + redMix:GetTall() + 40}, {content:GetWide()-8, 32}, content)
                    save:SetText("Save Configuration")
                    save.normalPaint = save.Paint 
                    function save:Paint(w, h)
                        self:SetColor(nadmin.colors.gui.blue)
                        self:normalPaint(w, h)
                    end

                    function save:DoClick()
                        nadmin.clientData.guiColors = {
                            theme = nadmin.colors.gui.theme,
                            blue  = nadmin.colors.gui.blue,
                            red   = nadmin.colors.gui.red
                        }

                        file.Write("nadmin_config.txt", util.TableToJSON(nadmin.clientData))

                        self:SetText("Saved!")
                        timer.Simple(1, function()
                            if IsValid(self) then 
                                self:SetText("Save Configuration")
                            end
                        end)
                    end
                end},
                {"Other", "icon16/wrench.png", function()
                    local noclipInWar = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    noclipInWar:Dock(TOP)
                    noclipInWar:DockMargin(4, 4, 4, 0)
                    noclipInWar:SetColor(nadmin.colors.gui.theme)
                    noclipInWar:SetText("Noclip in PVP")
                    noclipInWar:SetChecked(nadmin.clientData.allowNoclip)
                    
                    local physgunPlayers = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    physgunPlayers:Dock(TOP)
                    physgunPlayers:DockMargin(4, 4, 4, 0)
                    physgunPlayers:SetColor(nadmin.colors.gui.theme)
                    physgunPlayers:SetText("Physgun pickup other players")
                    physgunPlayers:SetChecked(nadmin.clientData.physgunOthers)

                    local afkTime = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    afkTime:Dock(TOP)
                    afkTime:DockMargin(4, 4, 4, 0)
                    afkTime:SetColor(nadmin.colors.gui.theme)
                    afkTime:SetText("Add to playtime while AFK")
                    afkTime:SetChecked(nadmin.clientData.afkTime)

                    local silentNotifs = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    silentNotifs:Dock(TOP)
                    silentNotifs:DockMargin(4, 4, 4, 0)
                    silentNotifs:SetColor(nadmin.colors.gui.theme)
                    silentNotifs:SetText("See silent notifications")
                    silentNotifs:SetChecked(nadmin.clientData.silentNotifs)

                    local hpRegen = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    hpRegen:Dock(TOP)
                    hpRegen:DockMargin(4, 4, 4, 0)
                    hpRegen:SetColor(nadmin.colors.gui.theme)
                    hpRegen:SetText("Regenerate health")
                    hpRegen:SetChecked(nadmin.clientData.hpRegen)

                    local compactSB = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 32}, content)
                    compactSB:Dock(TOP)
                    compactSB:DockMargin(4, 4, 4, 0)
                    compactSB:SetColor(nadmin.colors.gui.theme)
                    compactSB:SetText("Use compact scoreboard")
                    compactSB:SetChecked(nadmin.clientData.useCompactSB)

                    saveBtn = nadmin.vgui:DButton(nil, {content:GetWide()-8, 32}, content)
                    saveBtn:Dock(TOP)
                    saveBtn:DockMargin(4, 4, 4, 0)
                    saveBtn:SetText("Save Configuration")

                    function saveBtn:DoClick()
                        nadmin.clientData.allowNoclip   = noclipInWar:GetChecked()
                        nadmin.clientData.physgunOthers = physgunPlayers:GetChecked()
                        nadmin.clientData.afkTime       = afkTime:GetChecked()
                        nadmin.clientData.silentNotifs  = silentNotifs:GetChecked()
                        nadmin.clientData.hpRegen       = hpRegen:GetChecked()
                        nadmin.clientData.useCompactSB  = compactSB:GetChecked()

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
                    end
                end}
            }

            for i, cat in ipairs(categories) do
                local btn = nadmin.vgui:DButton(nil, {leftPanel:GetWide() - 8, 32}, leftPanel)
                btn:Dock(TOP)
                btn:DockMargin(0, 0, 0, 4)
                btn:SetText(cat[1])
                btn:SetIcon(cat[2])
                btn.selected = false

                -- if i ~= 1 then
                    btn:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                -- end

                function btn:DoClick()
                    local col = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                    for x, btn in ipairs(leftPanel.btns) do
                        btn:SetColor(col)
                        btn.selected = false
                    end
                    self:SetColor(nadmin.colors.gui.blue)
                    btn.selected = true

                    content:Clear()
                    if isfunction(cat[3]) then
                        function content:Paint() end
                        cat[3]()
                    else
                        function content:Paint(w, h)
                            draw.Text({
                                text = "Please select an option on the left.",
                                pos = {w/2, h/2},
                                xalign = TEXT_ALIGN_CENTER,
                                yalign = TEXT_ALIGN_CENTER,
                                font = "nadmin_derma",
                                color = tc
                            })
                        end
                    end
                end

                btn.normalPaint = btn.Paint 
                function btn:Paint(w, h)
                    self:normalPaint(w, h)

                    if (self.selected) then 
                        self:SetColor(nadmin.colors.gui.blue)
                    else 
                        self:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    end
                end

                table.insert(leftPanel.btns, btn)
            end
        end
    })

    net.Receive("nadmin_player_preferences", function()
        if IsValid(saveBtn) then 
            saveBtn:SetText("Saved!")
            timer.Simple(1, function()
                if IsValid(saveBtn) then 
                    saveBtn:SetText("Save Configuration")
                end
            end)
        end
    end)
else 
    util.AddNetworkString("nadmin_player_preferences")
    
    nadmin.plyPref = nadmin.plyPref or {}

    net.Receive("nadmin_player_preferences", function(len, ply)
        nadmin.plyPref[ply:SteamID()] = net.ReadTable()

        net.Start("nadmin_player_preferences")
        net.Send(ply)

        nadmin:Log("Received " .. ply:Nick() .. "'s preferences.")
    end)
end
