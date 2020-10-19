nadmin:RegisterPerm({
    title = "Manage Server Settings"
})
if CLIENT then
    nadmin.serverConfig = nadmin.serverConfig or {}
    nadmin.serverConfig.options = nadmin.serverConfig.options or {}

    function nadmin.serverConfig:RegisterOption(cfg)
        
    end

    local content
    nadmin.menu:RegisterTab({
        title = "Server Settings",
        sort = 2,
        content = function(parent, data)
            local tc = nadmin:TextColor(nadmin.colors.gui.theme)
            local function loadingAnim(w, h)
                draw.Circle(w/2, h/2, 16, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                draw.Circle(w/2, h/2, 16, 360, 270, (SysTime() % 360) * 180, tc)
                draw.Circle(w/2, h/2, 14, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 0))
            end

            local leftPanel = nadmin.vgui:DPanel(nil, {parent:GetWide()/6, parent:GetTall()}, parent)
            leftPanel:Dock(LEFT)
            leftPanel:DockPadding(0, 4, 4, 4)
            leftPanel.btns = {}

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
                {"Sandbox", "icon16/box.png"},
                {"Adverts", "icon16/newspaper.png", function()
                    -- function content:Paint(w, h)
                    --     loadingAnim(w, h)
                    -- end

                    content.adverts = nadmin.vgui:DPanel(nil, {content:GetWide()*0.7, content:GetTall()}, content)
                    content.adverts:Dock(LEFT)
                    content.adverts:DockMargin(2, 2, 0, 2)

                    local adv = content.adverts -- Ease of typing

                    adv.title = nadmin.vgui:DPanel(nil, {adv:GetWide(), 24}, adv)
                    adv.title:Dock(TOP)
                    adv.title.normalPaint = adv.title.Paint
                    function adv.title:Paint(w, h)
                        self:normalPaint(w, h)
                        draw.Text({
                            text = "Adverts",
                            pos = {w/2, h/2-2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            font = "nadmin_derma",
                            color = nadmin:TextColor(self:GetColor())
                        })

                        draw.RoundedBox(0, 0, h-2, w, 2, nadmin:DarkenColor(self:GetColor(), 25))
                    end

                    adv.advs = nadmin.vgui:DScrollPanel(nil, {adv:GetWide(), adv:GetTall()-adv.title:GetTall()}, adv)
                    adv.advs:Dock(FILL)
                    function adv.advs:Paint(w, h)
                        loadingAnim(w, h)
                    end

                    content.settings = nadmin.vgui:DPanel(nil, {content:GetWide()*0.3, content:GetTall()}, content)
                    content.settings:Dock(FILL)
                    content.settings:DockMargin(2, 2, 2, 2)

                    local cfg = content.settings -- Ease of typing

                    cfg.title = nadmin.vgui:DPanel(nil, {cfg:GetWide(), 24}, cfg)
                    cfg.title:Dock(TOP)
                    cfg.title.normalPaint = cfg.title.Paint
                    function cfg.title:Paint(w, h)
                        self:normalPaint(w, h)
                        draw.Text({
                            text = "Options",
                            pos = {w/2, h/2-2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            font = "nadmin_derma",
                            color = nadmin:TextColor(self:GetColor())
                        })

                        draw.RoundedBox(0, 0, h-2, w, 2, nadmin:DarkenColor(self:GetColor(), 25))
                    end

                    cfg.message = nadmin.vgui:DTextEntry(nil, {cfg:GetWide()-8, 24}, cfg)
                    cfg.message:Dock(TOP)
                    cfg.message:DockMargin(4, 4, 4, 0)
                    cfg.message:SetPlaceholderText("Advert Message...")

                    cfg.repText = nadmin.vgui:DLabel(nil, "Repeat every (minutes):", cfg)
                    cfg.repText:SetTall(24)
                    cfg.repText:Dock(TOP)
                    cfg.repText:DockMargin(4, 4, 4, 0)

                    cfg.rep = nadmin.vgui:DSlider(nil, {cfg:GetWide()-8, 24}, cfg)
                    cfg.rep:Dock(TOP)
                    cfg.rep:DockMargin(4, 4, 4, 0)
                    cfg.rep:SetText("")
                    cfg.rep:SetClampValue(1, 15)

                    cfg.col = nadmin.vgui:DColorMixer(nil, {cfg:GetWide()-8, 120}, cfg)
                    cfg.col:Dock(TOP)
                    cfg.col:DockMargin(4, 4, 4, 0)
                    cfg.col:SetColor(Color(255, 255, 255))

                    cfg.manage = nadmin.vgui:DPanel(nil, {cfg:GetWide()-8, 28}, cfg)
                    cfg.manage:Dock(BOTTOM)
                    cfg.manage:DockMargin(4, 0, 4, 4)

                    cfg.save = nadmin.vgui:DButton(nil, {cfg.manage:GetWide()/2-2, cfg.manage:GetTall()}, cfg.manage)
                    cfg.save:Dock(LEFT)
                    cfg.save:DockMargin(0, 0, 4, 0)
                    cfg.save:SetText("Update")
                    cfg.save:SetIcon("icon16/disk.png")

                    cfg.del = nadmin.vgui:DButton(nil, {cfg.manage:GetWide()/2-2, cfg.manage:GetTall()}, cfg.manage)
                    cfg.del:Dock(FILL)
                    cfg.del:SetText("Delete")
                    cfg.del:SetIcon("icon16/bin_closed.png")
                    cfg.del:SetColor(nadmin.colors.gui.red)

                    cfg.new = nadmin.vgui:DButton(nil, {cfg:GetWide()-2, cfg.manage:GetTall()}, cfg)
                    cfg.new:Dock(BOTTOM)
                    cfg.new:DockMargin(4, 0, 4, 4)
                    cfg.new:SetText("New")
                    cfg.new:SetIcon("icon16/add.png")
                    cfg.new:SetMouseInputEnabled(false)

                    cfg.manage:SetTall(0)
                    cfg.manage:DockMargin(0, 0, 0, 0)

                    local function checkError()
                        if string.Trim(cfg.message:GetText()) == "" then
                            cfg.new:SetMouseInputEnabled(false)
                        elseif cfg.rep:GetValue() <= 0 then
                            cfg.new:SetMouseInputEnabled(false)
                        else
                            cfg.new:SetMouseInputEnabled(true)
                        end
                    end

                    function cfg.message:OnTextChanged()
                        checkError()
                    end

                    function cfg.rep:OnValueChanged(val)
                        checkError()
                    end

                    function cfg.new:DoClick()
                        checkError()
                        if self:IsMouseInputEnabled() then
                            local col = cfg.col:GetColor()

                            net.Start("nadmin_add_advert")
                                net.WriteString(string.Trim(cfg.message:GetText()))
                                net.WriteInt(cfg.rep:GetValue(), 32)
                                net.WriteTable({col.r, col.g, col.b})
                                net.WriteInt(0, 32)
                            net.SendToServer()
                        end
                    end

                    function cfg.save:DoClick()
                        local col = cfg.col:GetColor()

                        local ind = cfg.index
                        if not isnumber(ind) then ind = 0 end

                        net.Start("nadmin_add_advert")
                            net.WriteString(string.Trim(cfg.message:GetText()))
                            net.WriteInt(cfg.rep:GetValue(), 32)
                            net.WriteTable({col.r, col.g, col.b})
                            net.WriteInt(ind, 32)
                        net.SendToServer()
                    end

                    function cfg.del:DoClick()
                        local ind = cfg.index
                        if not isnumber(ind) then ind = 0 end

                        net.Start("nadmin_add_advert")
                            net.WriteString("")
                            net.WriteInt(0, 32)
                            net.WriteTable({0, 0, 0})
                            net.WriteInt(ind, 32)
                        net.SendToServer()
                    end

                    net.Start("nadmin_req_adverts")
                    net.SendToServer()
                end},
                {"Ban Message", "icon16/page_white_text.png"},
                {"Command Echoes", "icon16/comment.png"},
                {"Logs", "icon16/database.png"},
                {"MOTD", "icon16/layout.png", function()
                    content.enabled = nadmin.vgui:DCheckBox(nil, {content:GetWide()-8, 28}, content)
                    content.enabled:Dock(TOP)
                    content.enabled:DockMargin(4, 4, 4, 0)
                    content.enabled:SetText("MOTD Enabled")
                    content.enabled:SetColor(nadmin.colors.gui.theme)

                    content.preview = nadmin.vgui:DButton(nil, {content:GetWide()-8, 28}, content)
                    content.preview:Dock(TOP)
                    content.preview:DockMargin(4, 4, 4, 0)
                    content.preview:SetIcon("icon16/application.png")
                    content.preview:SetText("Preview MOTD")
                    content.preview:SetColor(nadmin.colors.gui.theme)

                    content.save = nadmin.vgui:DButton(nil, {content:GetWide()-8, 28}, content)
                    content.save:Dock(TOP)
                    content.save:DockMargin(4, 4, 4, 0)
                    content.save:SetIcon("icon16/disk.png")
                    content.save:SetText("Save MOTD")

                    content.mode = nadmin.vgui:DComboBox(nil, {content:GetWide()-8, 28}, content)
                    content.mode:Dock(TOP)
                    content.mode:DockMargin(4, 4, 4, 0)
                    content.mode:SetColor(nadmin.colors.gui.theme)
                    content.mode:SetValue("MOTD Mode...")
                    content.mode:AddChoice("Generator", nil, false, "icon16/layout.png")
                    content.mode:AddChoice("Local File", nil, false, "icon16/tag.png")
                    content.mode:AddChoice("URL", nil, false, "icon16/link.png")

                    content.gen = nadmin.vgui:DScrollPanel(nil, nil, content)
                    content.gen:Dock(FILL)
                    content.gen:DockMargin(4, 4, 4, 4)
                    content.gen:SetVisible(false)

                    content.fileError = nadmin.vgui:DLabel(nil, "Problem loading local file:\n-> 404 - File doesn't exist: \"garrysmod/addons/nadmin/motd.txt\"\n-> 413 - File length exceeds 65523 characters, maximum string length that can be sent to a client.", content)
                    content.fileError:Dock(TOP)
                    content.fileError:DockMargin(4, 4, 4, 0)
                    content.fileError:SetTextColor(nadmin.colors.gui.red)
                    content.fileError:SizeToContentsY()
                    content.fileError:SetVisible(false)

                    content.url = nadmin.vgui:DTextEntry(nil, {content:GetWide()-8, 28}, content)
                    content.url:Dock(TOP)
                    content.url:DockMargin(4, 4, 4, 0)
                    content.url:SetColor(nadmin.colors.gui.theme)
                    content.url:SetPlaceholderText("URL to load...")
                    content.url:SetVisible(false)

                    content.lock = nadmin.vgui:DPanel(nil, {content:GetWide(), content:GetTall()}, content)
                    function content.lock:Paint(w, h)
                        local tc = nadmin:TextColor(self:GetColor())

                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))

                        draw.Circle(w/2, h/2, 16, 360, 360, 0, Color(0, 0, 0, 100))
                        draw.Circle(w/2, h/2, 16, 360, 270, (SysTime() % 360) * 180, tc)
                        draw.Circle(w/2, h/2, 14, 360, 360, 0, nadmin:DarkenColor(self:GetColor(), 25))
                        draw.Circle(w/2, h/2, 14, 360, 360, 0, Color(0, 0, 0, 150))
                    end

                    function content.mode:OnSelect(ind, val, data)
                        if val == "Generator" then
                            content.lock:SetVisible(true)

                            content.gen:SetVisible(false)
                            content.fileError:SetVisible(false)
                            content.url:SetVisible(false)

                            net.Start("nadmin_fetch_motd_cfg")
                                net.WriteString(val)
                            net.SendToServer()
                        elseif val == "Local File" then
                            content.lock:SetVisible(true)

                            content.gen:SetVisible(false)
                            content.fileError:SetVisible(false)
                            content.url:SetVisible(false)

                            net.Start("nadmin_fetch_motd_cfg")
                                net.WriteString(val)
                            net.SendToServer()
                        elseif val == "URL" then
                            content.lock:SetVisible(true)

                            content.gen:SetVisible(false)
                            content.fileError:SetVisible(false)
                            content.url:SetVisible(false)

                            net.Start("nadmin_fetch_motd_cfg")
                                net.WriteString(val)
                            net.SendToServer()
                        end
                    end

                    local gen = content.gen

                    gen.titleText = nadmin.vgui:DLabel(nil, "MOTD Title", gen, true)
                    gen.titleText:SetFont("nadmin_derma_large")
                    gen.titleText:SizeToContents()
                    gen.titleText:Dock(TOP)
                    gen.titleText:DockMargin(4, 4, 4, 0)

                    gen.titleDiv = nadmin.vgui:DPanel(nil, {gen:GetWide() - 8, 28}, gen)
                    gen.titleDiv:Dock(TOP)
                    gen.titleDiv:DockMargin(4, 4, 4, 0)

                    gen.title = nadmin.vgui:DTextEntry(nil, {content:GetWide() - 16, 28}, gen.titleDiv)
                    gen.title:SetPlaceholderText("MOTD Title...")

                    gen.titleSettings = nadmin.vgui:DButton({gen.title:GetWide() - 24, 4}, {20, 20}, gen.title)
                    gen.titleSettings:SetColor(nadmin.colors.gui.theme)
                    gen.titleSettings:SetText("")
                    gen.titleSettings:SetIcon("icon16/cog.png")

                    gen.div = nadmin.vgui:DPanel(nil, {content:GetWide() - 16, 4}, gen)
                    gen.div:Dock(TOP)
                    gen.div:DockMargin(4, 4, 4, 0)
                    gen.div:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, -25))

                    gen.bodyText = nadmin.vgui:DLabel(nil, "MOTD Body", gen, true)
                    gen.bodyText:SetFont("nadmin_derma_large")
                    gen.bodyText:SizeToContents()
                    gen.bodyText:Dock(TOP)
                    gen.bodyText:DockMargin(4, 4, 4, 0)

                    function content.preview:DoClick()
                        local data

                        if content.fileError:IsVisible() then
                            if isstring(content.fileError.data) then
                                data = content.fileError.data
                            end
                        elseif content.url:IsVisible() then
                            data = content.url:GetText()
                        end

                        nadmin.motd:Open(data)
                    end

                    function content.save:DoClick()
                        local mode = content.mode:GetValue()

                        if mode == "Generator" then mode = "" end

                        net.Start("nadmin_update_motd_cfg")
                            net.WriteBool(content.enabled:GetChecked())
                            net.WriteString(mode)
                            if mode == "URL" then
                                net.WriteString(content.url:GetText())
                            end
                        net.SendToServer()

                        content.lock:SetVisible(true)
                        net.Start("nadmin_fetch_motd_cfg")
                            net.WriteString("%GETMODE%")
                        net.SendToServer()
                    end

                    net.Start("nadmin_fetch_motd_cfg")
                        net.WriteString("%GETMODE%")
                    net.SendToServer()
                end},
                {"Voteban", "icon16/disconnect.png"},
                {"Votemap", "icon16/world.png"},
                {"Reserved Slots", "icon16/status_online.png"}
            }


            for i, cat in ipairs(categories) do
                local btn = nadmin.vgui:DButton(nil, {leftPanel:GetWide() - 8, 32}, leftPanel)
                btn:Dock(TOP)
                btn:DockMargin(0, 0, 0, 4)
                btn:SetText(cat[1])
                btn:SetIcon(cat[2])

                if i ~= 1 then
                    btn:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end

                function btn:DoClick()
                    local col = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                    for x, btn in ipairs(leftPanel.btns) do
                        btn:SetColor(col)
                    end
                    self:SetColor(nadmin.colors.gui.blue)

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

                table.insert(leftPanel.btns, btn)
            end
        end
    })

    net.Receive("nadmin_fetch_motd_cfg", function()
        if not IsValid(content) then return end -- No need to process since they closed the menu
        local enabled = net.ReadBool()
        local mode = net.ReadString()

        if enabled then
            content.enabled:SetChecked(true)
        end

        content.mode:SetValue(mode)

        if mode == "Generator" then
            local gen = net.ReadTable()

            content.gen.title:SetText(gen.title.text)

            content.gen:SetVisible(true)
        elseif mode == "Local File" then
            local errored = net.ReadBool()
            local val = net.ReadString()

            if errored then
                content.fileError:SetText("Problem loading local file:\n" .. val)
            else
                content.fileError:SetText("No errors occur using Local File.")
                content.fileError:SetTextColor(nadmin.colors.gui.blue)
                content.fileError.data = val
            end

            content.fileError:SizeToContentsY()

            content.fileError:SetVisible(true)
        elseif mode == "URL" then
            local url = net.ReadString()

            content.url:SetText(url)
            content.url:SetVisible(true)
        end

        content.lock:SetVisible(false)
    end)

    net.Receive("nadmin_req_adverts", function()
        local adverts = net.ReadTable()

        if not IsValid(content) then return end

        content.adverts.advs:Clear()

        local numAd = #adverts
        if numAd > 0 then
            local btns = {}

            function content.adverts.advs:Paint() end
            for i = 1, numAd do
                local adv = adverts[i]

                local row = nadmin.vgui:DPanel(nil, {content.adverts.advs:GetWide() - 8, 28}, content.adverts.advs)
                row:Dock(TOP)
                row:DockMargin(4, 4, 4, 0)
                function row:Paint() end

                local up = nadmin.vgui:DButton(nil, {30, 13}, row)
                up:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                up:SetText("")
                function up:Paint(w, h)
                    if self:IsMouseInputEnabled() then
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))
                    else
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(self:GetColor(), 15))
                    end

                    local c = self:GetTextColor()
                    draw.NoTexture()

                    surface.SetDrawColor(c.r, c.g, c.b)
                    surface.DrawPoly({
                        {x = w/2, y = 2},
                        {x = w/2 + h/2 - 2, y = h - 2},
                        {x = w/2 - h/2 + 2, y = h - 2}
                    })
                end
                if i == 1 then
                    up:SetMouseInputEnabled(false)
                end

                function up:DoClick()
                    if istable(adverts[i - 1]) then
                        local above = adverts[i - 1]
                        net.Start("nadmin_add_advert")
                            net.WriteString(above.text)
                            net.WriteInt(above.repeatAfter, 32)
                            net.WriteTable({above.color.r, above.color.g, above.color.b})
                            net.WriteInt(i, 32)
                        net.SendToServer()

                        net.Start("nadmin_add_advert")
                            net.WriteString(adv.text)
                            net.WriteInt(adv.repeatAfter, 32)
                            net.WriteTable({adv.color.r, adv.color.g, adv.color.b})
                            net.WriteInt(i - 1, 32)
                        net.SendToServer()
                    end
                end

                local down = nadmin.vgui:DButton({0, 15}, {30, 13}, row)
                down:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                down:SetText("")
                function down:Paint(w, h)
                    if self:IsMouseInputEnabled() then
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))
                    else
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(self:GetColor(), 15))
                    end

                    local c = self:GetTextColor()
                    draw.NoTexture()

                    surface.SetDrawColor(c.r, c.g, c.b)
                    surface.DrawPoly({
                        {x = w/2 - h/2 + 2, y = 2},
                        {x = w/2 + h/2 - 2, y = 2},
                        {x = w/2, y = h - 2}
                    })
                end
                if i == numAd then
                    down:SetMouseInputEnabled(false)
                end

                function down:DoClick()
                    if istable(adverts[i + 1]) then
                        local below = adverts[i + 1]
                        net.Start("nadmin_add_advert")
                            net.WriteString(below.text)
                            net.WriteInt(below.repeatAfter, 32)
                            net.WriteTable({below.color.r, below.color.g, below.color.b})
                            net.WriteInt(i, 32)
                        net.SendToServer()

                        net.Start("nadmin_add_advert")
                            net.WriteString(adv.text)
                            net.WriteInt(adv.repeatAfter, 32)
                            net.WriteTable({adv.color.r, adv.color.g, adv.color.b})
                            net.WriteInt(i + 1, 32)
                        net.SendToServer()
                    end
                end

                local resend = nadmin.vgui:DButton({32, 0}, {28, 28}, row)
                resend:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                resend:SetText("")
                resend:SetIcon("icon16/arrow_refresh.png")
                resend:SetToolTip("Resend advert")
                function resend:DoClick()
                    net.Start("nadmin_resend_advert")
                        net.WriteInt(i, 32)
                    net.SendToServer()
                end

                local btn = nadmin.vgui:DButton({62, 0}, {row:GetWide() - 62, 28}, row)
                btn:SetText(adv.text)
                btn:SetColor(adv.color)

                btn.normalPaint = btn.Paint
                function btn:Paint(w, h)
                    self:normalPaint(w, h)
                    if self.sel then
                        local tc = self:GetTextColor()
                        draw.RoundedBox(0, 0, 0, w, 1, tc)
                        draw.RoundedBox(0, w-1, 0, 1, h, tc)
                        draw.RoundedBox(0, 0, h-1, w, 1, tc)
                        draw.RoundedBox(0, 0, 0, 1, h, tc)
                    end
                end

                function btn:DoClick()
                    content.settings.message:SetText(adv.text)
                    content.settings.rep:SetValue(adv.repeatAfter)
                    content.settings.col:SetColor(adv.color)

                    content.settings.manage:SetTall(content.settings.new:GetTall())
                    content.settings.manage:DockMargin(4, 0, 4, 4)
                    content.settings.index = i

                    for i = 1, #btns do
                        btns[i].sel = false
                    end
                    self.sel = true
                end

                table.insert(btns, btn)
            end
        else
            function content.adverts.advs:Paint(w, h)
                draw.Text({
                    text = "No adverts currently exist.",
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    font = "nadmin_derma",
                    color = nadmin:TextColor(self:GetColor())
                })
            end
        end
    end)
else

end
