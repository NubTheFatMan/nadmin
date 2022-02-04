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
                {"Sandbox", "icon16/box.png", function() 
                    local function togglecvar(opt, val)
                        if isbool(val) then val = nadmin:BoolToInt(val) end
                        net.Start("nadmin_upd_sandbox")
                            net.WriteString(opt)
                            net.WriteInt(val, 32)
                        net.SendToServer()
                    end

                    content.noclip = nadmin.vgui:DCheckBox({4, 4}, {content:GetWide()/5 - 8, 32}, content)
                    content.noclip:SetText("Allow noclip")
                    content.noclip:SetTooltip("sbox_noclip")
                    function content.noclip:OnChecked(val)
                        togglecvar("sbox_noclip", val)
                    end

                    content.god = nadmin.vgui:DCheckBox({4, 40}, {content:GetWide()/5 - 8, 32}, content)
                    content.god:SetText("All players have god")
                    content.god:SetTooltip("sbox_godmode")
                    function content.god:OnChecked(val)
                        togglecvar("sbox_godmode", val)
                    end

                    content.pvp = nadmin.vgui:DCheckBox({4, 76}, {content:GetWide()/5 - 8, 32}, content)
                    content.pvp:SetText("PVP damage")
                    content.pvp:SetTooltip("sbox_playershurtplayers")
                    function content.pvp:OnChecked(val)
                        togglecvar("sbox_playershurtplayers", val)
                    end

                    content.notice = nadmin.vgui:AdvancedDLabel({4, 112}, "Notice: These are just for convenience, and will not save if the server restarts or crashes.", content)
                    content.notice:SetWide(content:GetWide()/5 - 8)

                    content.limits = nadmin.vgui:DPanel({content:GetWide()/5, 4}, {content:GetWide() * (4/5), content:GetTall() - 4}, content)
                    function content.limits:Paint(w, h) end -- I want this to be transparent, this is just a parent for docking the children

                    -- sbox_maxprops		500
                    -- sbox_maxragdolls	50
                    -- sbox_maxnpcs		50
                    -- sbox_maxballoons	50
                    -- sbox_maxeffects		50
                    -- sbox_maxdynamite	50
                    -- sbox_maxlamps		50
                    -- sbox_maxthrusters	50
                    -- sbox_maxwheels		50
                    -- sbox_maxhoverballs	50
                    -- sbox_maxvehicles	50
                    -- sbox_maxbuttons		50
                    -- sbox_maxsents		50
                    -- sbox_maxemitters	50

                    content.props = nadmin.vgui:DSlider(nil, {content.limits:GetWide(), 24}, content.limits)
                    content.props:Dock(TOP)
                    content.props:DockMargin(0, 4, 12, 0)
                    content.props:SetText("sbox_maxprops")
                    content.props:SetColor(content:GetColor())
                    content.props:SetClampValue(0, 100)

                    content.lock = nadmin.vgui:DPanel(nil, {content:GetWide(), content:GetTall()}, content)
                    function content.lock:Paint(w, h)
                        local tc = nadmin:TextColor(self:GetColor())

                        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))

                        draw.Circle(w/2, h/2, 16, 360, 360, 0, Color(0, 0, 0, 100))
                        draw.Circle(w/2, h/2, 16, 360, 270, (SysTime() % 360) * 180, tc)
                        draw.Circle(w/2, h/2, 14, 360, 360, 0, nadmin:DarkenColor(self:GetColor(), 25))
                        draw.Circle(w/2, h/2, 14, 360, 360, 0, Color(0, 0, 0, 150))
                    end

                    net.Start("nadmin_request_sandbox")
                    net.SendToServer()
                end},
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
                {"Command Echoes", "icon16/comment.png", function()
                    local sendEcho = nadmin.vgui:DCheckBox(nil, {content:GetWide() - 8, 32}, content)
                    sendEcho:Dock(TOP)
                    sendEcho:DockMargin(4, 4, 4, 0)
                    sendEcho:SetText("Send Command Echos")
                    sendEcho:SetToolTip("When a player runs a command, should the command be echoed?")

                    local hideCommand = nadmin.vgui:DCheckBox(nil, {content:GetWide() - 8, 32}, content)
                    hideCommand:Dock(TOP)
                    hideCommand:DockMargin(4, 4, 4, 0)
                    hideCommand:SetText("Hide Command Calls")
                    hideCommand:SetToolTip("When a player runs a command, should their message be hidden?\nFor example, should !menu be hidden from the chat?")
                end},
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

                    gen.titleDiv = nadmin.vgui:DPanel(nil, {gen:GetWide() - 8, 190}, gen)
                    gen.titleDiv:Dock(TOP)
                    gen.titleDiv:DockMargin(4, 4, 4, 0)

                    gen.title = nadmin.vgui:DTextEntry(nil, {content:GetWide() - 16, 28}, gen.titleDiv)
                    gen.title:SetPlaceholderText("MOTD Title...")
                    function gen.title:OnTextChanged()
                        if not istable(content.gen.motd) then return end
                        content.gen.motd.title.text = self:GetText()
                    end

                    gen.subTitle = nadmin.vgui:DTextEntry({0, 32}, {content:GetWide() - 16, 28}, gen.titleDiv)
                    gen.subTitle:SetPlaceholderText("MOTD Subtitle...")
                    function gen.subTitle:OnTextChanged()
                        if not istable(content.gen.motd) then return end
                        content.gen.motd.title.subtext = self:GetText()
                    end

                    gen.bgcoltxt = nadmin.vgui:DLabel({0, 64}, "Title Background Color:", gen.titleDiv, true)
                    gen.bgcol = nadmin.vgui:DColorMixer({0, 88}, {content:GetWide() / 2 - 2, 74}, gen.titleDiv)
                    function gen.bgcol:ValueChanged(col)
                        if not istable(content.gen.motd) then return end
                        content.gen.motd.title.bgcol = Color(col.r, col.g, col.b)
                    end

                    gen.bgtxtcoltxt = nadmin.vgui:DLabel({content:GetWide()/2 + 2, 64}, "Text Color:", gen.titleDiv, true)
                    gen.bgtxtcol = nadmin.vgui:DColorMixer({content:GetWide()/2 + 2, 88}, {content:GetWide() / 2 - 2, 74}, gen.titleDiv)
                    function gen.bgtxtcol:ValueChanged(col)
                        if not istable(content.gen.motd) then return end
                        content.gen.motd.title.txcol = Color(col.r, col.g, col.b)
                    end

                    gen.underline = nadmin.vgui:DCheckBox({0, 166}, {content:GetWide(), 24}, gen.titleDiv)
                    gen.underline:SetText("Underline Title Box")
                    gen.underline:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    function gen.underline:OnChecked(checked)
                        if not istable(content.gen.motd) then return end
                        content.gen.motd.title.underline = checked
                    end

                    gen.div = nadmin.vgui:DPanel(nil, {content:GetWide() - 16, 12}, gen)
                    gen.div:Dock(TOP)
                    gen.div:DockMargin(4, 4, 4, 0)
                    gen.div:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, -25))

                    gen.bodyText = nadmin.vgui:DLabel(nil, "MOTD Body", gen, true)
                    gen.bodyText:SetFont("nadmin_derma_large")
                    gen.bodyText:SizeToContents()
                    gen.bodyText:Dock(TOP)
                    gen.bodyText:DockMargin(4, 4, 4, 0)

                    gen.add = nadmin.vgui:DButton(nil, {gen:GetWide() - 8, 28}, gen)
                    gen.add:Dock(TOP)
                    gen.add:DockMargin(4, 4, 4, 4)
                    gen.add:SetText("Add Content")
                    gen.add:SetIcon("icon16/add.png")
                    gen.add:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                    content.panels = {}
                    function gen.add:DoClick(inf, ind)
                        if not istable(content.gen.motd) then return end

                        if istable(inf) then data = table.Copy(inf) 
                        else 
                            data = {type = "text", title = "", value = "", ranks = {}}
                            table.insert(content.gen.motd.contents, data)
                        end

                        local pan = nadmin.vgui:DPanel(nil, {gen:GetWide()-8, 150}, gen)
                        pan:Dock(TOP)
                        pan:DockMargin(4, 0, 4, 4)
                        pan:DockPadding(4, 4, 4, 4)
                        pan:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                        table.insert(content.panels, pan)

                        local controls = nadmin.vgui:DPanel(nil, {32, pan:GetTall()}, pan)
                        controls:Dock(LEFT)
                        controls:DockPadding(0, 0, 4, 0)
                        controls:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                        local up = nadmin.vgui:DButton(nil, {28, 28}, controls)
                        up:Dock(TOP)
                        up:DockMargin(0, 0, 0, 4)
                        up:SetIcon("icon16/arrow_up.png")
                        up:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 50))
                        up.ind = ind or #content.gen.motd.contents

                        local down = nadmin.vgui:DButton(nil, {28, 28}, controls)
                        down:Dock(BOTTOM)
                        down:DockMargin(0, 4, 0, 0)
                        down:SetIcon("icon16/arrow_down.png")
                        down:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 50))
                        down.ind = up.ind
                        
                        local del = nadmin.vgui:DButton(nil, {28, 28}, controls)
                        del:Dock(FILL)
                        del:SetIcon("icon16/bin_closed.png")
                        del:SetColor(nadmin.colors.gui.red)
                        del.ind = up.ind

                        local info = nadmin.vgui:DScrollPanel(nil, {pan:GetWide()-32, pan:GetTall()}, pan)
                        info:Dock(FILL)
                        info:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                        info.title = nadmin.vgui:DTextEntry(nil, {info:GetWide(), 28}, info)
                        info.title:Dock(TOP)
                        info.title:DockMargin(0, 0, 0, 4)
                        info.title:SetColor(nadmin.colors.gui.theme)
                        info.title:SetPlaceholderText("Title...")
                        info.title:SetText(data.title)
                        function info.title:OnTextChanged()
                            data.title = self:GetText()
                        end

                        info.type = nadmin.vgui:DComboBox(nil, {info:GetWide(), 28}, info)
                        info.type:Dock(TOP)
                        info.type:DockMargin(0, 0, 0, 4)
                        info.type:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 50))
                        info.type:SetSortItems(false)
                        info.type:AddChoice("Number List",       "olist",    data.type == "olist"   )
                        info.type:AddChoice("Bullet List",       "ulist",    data.type == "ulist"   )
                        info.type:AddChoice("Text Area",         "text",     data.type == "text"    )
                        info.type:AddChoice("Workshop Addons",   "workshop", data.type == "workshop")
                        info.type:AddChoice("Members in a Rank", "members",  data.type == "members" )

                        info.notice = nadmin.vgui:AdvancedDLabel(nil, "If making a list, press enter to start a new line for each point.", info)
                        info.notice:Dock(TOP)
                        info.notice:DockMargin(0, 0, 0, 4)

                        info.valueEntry = nadmin.vgui:DTextEntry(nil, {info:GetWide(), 24}, info)
                        info.valueEntry:Dock(TOP)
                        info.valueEntry:SetPlaceholderText("Information...")
                        info.valueEntry:SetMultiline(true)
                        info.valueEntry:SetColor(nadmin.colors.gui.theme)
                        info.valueEntry:SetText(data.value)

                        function info.valueEntry:OnTextChanged()
                            local lines = #string.Explode("\n", self:GetText())
                            self:SetTall(4 + 20 * lines)
                            info:SizeToContentsY()
                            data.value = self:GetText()
                        end

                        info.ranks = nadmin.vgui:DPanel(nil, {info:GetWide(), 0}, info)
                        info.ranks:Dock(TOP)
                        info.ranks:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                        local ranks = {}
                        for i, rank in pairs(nadmin.ranks) do
                           table.insert(ranks, rank) 
                        end
                        table.sort(ranks, function(a, b) return a.immunity > b.immunity end)

                        for i, rank in ipairs(ranks) do
                            local box = nadmin.vgui:DCheckBox(nil, {info:GetWide(), 24}, info.ranks)
                            box:Dock(TOP)
                            box:DockMargin(0, 0, 0, 4)
                            box:SetCheckColor(rank.color) 
                            box:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 50))
                            box:SetText(rank.title)
                            box:SetChecked(table.HasValue(data.ranks, rank.id))
                            function box:OnChecked(checked)
                                if checked then 
                                    table.insert(data.ranks, rank.id)
                                else 
                                    table.RemoveByValue(data.ranks, rank.id)
                                end
                            end

                            info.ranks:SetTall(info.ranks:GetTall() + 28)

                        end

                        info.ranks:SetVisible(false)

                        info.nice = nadmin.vgui:DLabel(nil, "mm yes, you like this empty space of mine right? Why don't you touch it ( ͡° ͜ʖ ͡°)", info, true)
                        info.nice:Dock(TOP)
                        info.nice:SetVisible(false)

                        function del:DoClick()
                            table.RemoveByValue(content.panels, pan)
                            pan:Remove()
                            table.remove(content.gen.motd.contents, self.ind)
                        end

                        function up:DoClick()
                            local index = self.ind

                            local upcon = content.gen.motd.contents[index - 1]
                            local ticon = content.gen.motd.contents[index]
                            if istable(upcon) then 
                                local upContent = table.Copy(upcon)
                                local thisContent = table.Copy(ticon)
                                content.gen.motd.contents[index - 1] = thisContent
                                content.gen.motd.contents[index] = upContent

                                for x, panel in ipairs(content.panels) do
                                    panel:Remove()
                                end
                                content.panels = {}
                                for i, con in ipairs(content.gen.motd.contents) do
                                    content.gen.add:DoClick(con, i)
                                end
                            end
                        end
                        function down:DoClick()
                            local index = self.ind

                            local ticon = content.gen.motd.contents[index]
                            local docon = content.gen.motd.contents[index + 1]
                            if istable(docon) then 
                                local thisContent = table.Copy(ticon)
                                local doContent = table.Copy(docon)
                                content.gen.motd.contents[index] = doContent
                                content.gen.motd.contents[index + 1] = thisContent

                                for x, panel in ipairs(content.panels) do
                                    panel:Remove()
                                end
                                content.panels = {}
                                for i, con in ipairs(content.gen.motd.contents) do
                                    content.gen.add:DoClick(con, i)
                                end
                            end
                        end

                        function info.type:OnSelect(index, value, dat)
                            data.type = dat
                            if dat == "olist" or dat == "ulist" or dat == "text" then 
                                info.notice:SetVisible(true)
                                info.valueEntry:SetVisible(true)
                                info.ranks:SetVisible(false)
                                info.nice:SetVisible(false)
                            elseif dat == "workshop" then 
                                info.notice:SetVisible(false)
                                info.valueEntry:SetVisible(false)
                                info.ranks:SetVisible(false)
                                info.nice:SetVisible(true)
                            elseif dat == "members" then 
                                info.notice:SetVisible(false)
                                info.valueEntry:SetVisible(false)
                                info.ranks:SetVisible(true)
                                info.nice:SetVisible(false)
                            end
                        end

                        info.type:OnSelect(nil, nil, data.type)
                    end

                    function content.preview:DoClick()
                        local data

                        if content.fileError:IsVisible() then
                            if isstring(content.fileError.data) then
                                data = content.fileError.data
                            end
                        elseif content.url:IsVisible() then
                            data = content.url:GetText()
                        elseif content.gen:IsVisible() then 
                            data = content.gen.motd
                        end

                        nadmin.motd:Open(data)
                    end

                    function content.save:DoClick()
                        local mode = content.mode:GetValue()

                        content.lock:SetVisible(true)
                        net.Start("nadmin_update_motd_cfg")
                            net.WriteBool(content.enabled:GetChecked())
                            net.WriteString(mode)
                            if mode == "URL" then
                                net.WriteString(content.url:GetText())
                            elseif mode == "Generator" and istable(content.gen.motd) then 
                                net.WriteTable(content.gen.motd)
                            end
                        net.SendToServer()

                        net.Start("nadmin_fetch_motd_cfg")
                        net.WriteString("_get")
                        net.SendToServer()
                    end

                    net.Start("nadmin_fetch_motd_cfg")
                    net.WriteString("_get")
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

                -- if i ~= 1 then
                    btn:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                -- end

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
            content.gen.motd = gen

            content.gen.title:SetText(gen.title.text)
            content.gen.subTitle:SetText(gen.title.subtext)
            content.gen.bgcol:SetColor(gen.title.bgcol)
            content.gen.bgtxtcol:SetColor(gen.title.txcol)
            content.gen.underline:SetChecked(gen.title.underline)
            
            for x, pan in ipairs(content.panels) do
                pan:Remove()
            end
            content.panels = {}
            for i, con in ipairs(gen.contents) do
                content.gen.add:DoClick(con, i)
            end

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

    net.Receive("nadmin_request_sandbox", function()
        local cfg = net.ReadTable()

        if not IsValid(content) then return end

        content.lock:SetVisible(false)

        content.noclip:SetChecked(cfg.noclip)
        content.god:SetChecked(cfg.god)
        content.pvp:SetChecked(cfg.pvp)
    end)
else
    util.AddNetworkString("nadmin_request_sandbox")
    util.AddNetworkString("nadmin_upd_sandbox")

    net.Receive("nadmin_upd_sandbox", function(len, ply)
        local opt = net.ReadString()
        local val = net.ReadInt(32)

        if not ply:HasPerm("manage_sandbox") then 
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            return
        end

        local convar = GetConVar(opt)
        if convar then 
            convar:SetInt(val)
        else 
            nadmin:Notify(ply, nadmin.colors.red, "Invalid option specified: " .. opt)
        end
    end)

    net.Receive("nadmin_request_sandbox", function(len, ply)
        local noclip = nadmin:IntToBool(GetConVar("sbox_noclip"):GetInt())
        local god    = nadmin:IntToBool(GetConVar("sbox_godmode"):GetInt())
        local pvp    = nadmin:IntToBool(GetConVar("sbox_playershurtplayers"):GetInt())

        net.Start("nadmin_request_sandbox")
            net.WriteTable({
                noclip = noclip,
                god = god,
                pvp = pvp
            })
        net.Send(ply)
    end)
end

nadmin:RegisterPerm({
    title = "Manage Sandbox"
})