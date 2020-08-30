nadmin:RegisterPerm({
    title = "Manage Server Settings"
})
if CLIENT then
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
                {"MOTD", "icon16/layout.png"},
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

    net.Receive("nadmin_req_adverts", function()
        local adverts = net.ReadTable()

        if not IsValid(content) then return end

        content.adverts.advs:Clear()

        if #adverts > 0 then
            local btns = {}

            function content.adverts.advs:Paint() end
            for i = 1, #adverts do
                local adv = adverts[i]

                local btn = nadmin.vgui:DButton(nil, {content.adverts.advs:GetWide() - 8, 28}, content.adverts.advs)
                btn:Dock(TOP)
                btn:DockMargin(4, 4, 4, 0)
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
    nadmin.config.adverts = nadmin.config.adverts or {}
    local adverts = nadmin.config.adverts

    util.AddNetworkString("nadmin_add_advert")
    util.AddNetworkString("nadmin_req_adverts")

    net.Receive("nadmin_add_advert", function(len, ply)
        local msg = net.ReadString()
        local rep = net.ReadInt(32)
        local col = net.ReadTable()
        local ind = net.ReadInt(32)

        if not ply:HasPerm("manage_server_settings") then
            nadmin:Notify(ply, nadmin.colors.red, "You aren't allowed to manage server settings.")
            return
        end

        if msg == "" then
            if istable(adverts[ind]) then
                table.remove(adverts, ind)
            end
        else
            if istable(adverts[ind]) then
                adverts[ind] = {
                    text = msg,
                    repeatAfter = rep,
                    color = Color(col[1], col[2], col[3]),
                    lastRan = 0
                }
            else
                table.insert(adverts, {
                    text = msg,
                    repeatAfter = rep,
                    color = Color(col[1], col[2], col[3]),
                    lastRan = 0
                })
            end
        end

        net.Start("nadmin_req_adverts")
            net.WriteTable(adverts)
        net.Send(ply)

        file.Write("nadmin/config/adverts.txt", util.TableToJSON(adverts))
    end)

    local loaded = file.Read("nadmin/config/adverts.txt", "DATA")
    loaded = util.JSONToTable(loaded)
    table.Merge(adverts, loaded)
    for i = 1, #adverts do
        local adv = adverts[i]
        if not IsColor(adv.color) and istable(adv.color) then
            local col = adv.color
            adv.color = Color(col.r, col.g, col.b)
        end
    end

    net.Receive("nadmin_req_adverts", function(len, ply)
        net.Start("nadmin_req_adverts")
            net.WriteTable(adverts)
        net.Send(ply)
    end)

    hook.Add("Think", "nadmin_adverts", function()
        local now = os.time()

        for i = 1, #adverts do
            local adv = adverts[i]

            -- Validate the advert is setup correctly
            if not isstring(adv.text) then continue end
            if not isnumber(adv.repeatAfter) then continue end
            if not IsColor(adv.color) then continue end
            if not isnumber(adv.lastRan) then adv.lastRan = 0 end

            if now - adv.lastRan >= (adv.repeatAfter * nadmin.time.m) then
                nadmin:Notify(adv.color, adv.text)
                adv.lastRan = now
            end
        end
    end)
end
