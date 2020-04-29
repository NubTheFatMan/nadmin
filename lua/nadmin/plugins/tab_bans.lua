if CLIENT then
    nadmin.menu:RegisterTab({
        title = "Bans",
        sort = 3,
        content = function(parent, data)
            nadmin.menu.filter = istable(data) and data or {}
            local filter = nadmin.menu.filter

            local function paintLoad(w, h)
                draw.Circle(w/2, h/2, 32, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                draw.Circle(w/2, h/2, 32, 360, 270, (SysTime() % 360) * 180, nadmin:TextColor(nadmin.colors.gui.theme))
                draw.Circle(w/2, h/2, 28, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end

            local controls = nadmin.vgui:DPanel(nil, {parent:GetWide() - 8, 36}, parent)
            controls:Dock(TOP)

            nadmin.menu.search = nadmin.vgui:DTextEntry(nil, {parent:GetWide() / 3, controls:GetTall() - 8}, controls)
            nadmin.menu.search:Dock(LEFT)
            nadmin.menu.search:DockMargin(0, 4, 0, 4)
            nadmin.menu.search:SetText(isstring(filter.search) and filter.search or "")
            nadmin.menu.search:SetPlaceholderText("Search...")

            nadmin.menu.sort = nadmin.vgui:DComboBox(nil, {parent:GetWide()/4, controls:GetTall() - 8}, controls)
            nadmin.menu.sort:Dock(LEFT)
            nadmin.menu.sort:DockMargin(4, 4, 0, 4)
            nadmin.menu.sort:AddChoice("Sort: Ban Length",     "banned_len", filter.sort == "banned_len")
            nadmin.menu.sort:AddChoice("Sort: Banned By",      "banned_by",  filter.sort == "banned_by")
            nadmin.menu.sort:AddChoice("Sort: Date (new-old)", "date_no",    filter.sort == "date_no" or not isstring(filter.sort))
            nadmin.menu.sort:AddChoice("Sort: Date (old-new)", "date_on",    filter.sort == "date_on")
            nadmin.menu.sort:AddChoice("Sort: Name",           "name",       filter.sort == "name")
            nadmin.menu.sort:AddChoice("Sort: Steam ID",       "steamid",    filter.sort == "steamid")
            nadmin.menu.sort:AddChoice("Sort: Unban Date",     "unban",      filter.sort == "unban")

            nadmin.menu.showPerm = nadmin.vgui:DCheckBox(nil, {parent:GetWide()/5, controls:GetTall() - 8}, controls)
            nadmin.menu.showPerm:Dock(RIGHT)
            nadmin.menu.showPerm:DockMargin(4, 4, 0, 4)
            nadmin.menu.showPerm:SetText("Show Permanent Bans")
            nadmin.menu.showPerm:SetColor(nadmin.colors.gui.theme)
            nadmin.menu.showPerm:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            nadmin.menu.showPerm:SetChecked(not isbool(filter.showPerma) or filter.showPerma)

            local div = nadmin.vgui:DPanel(nil, {parent:GetWide() - 8, 28}, parent)
            div:Dock(TOP)
            div:DockMargin(4, 0, 4, 0)
            div.text = nadmin:TextColor(nadmin.colors.gui.theme)
            div.font = "nadmin_derma"
            div.normalPaint = div.Paint
            function div:Paint(w, h)
                div:normalPaint(w, h)

                draw.Text({
                    text = "Name/SteamID",
                    font = self.font,
                    color = self.text,
                    pos = {w/8, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER
                })
                draw.Text({
                    text = "Banned By",
                    font = self.font,
                    color = self.text,
                    pos = {w/4 + w/8, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER
                })
                draw.Text({
                    text = "Unban Date",
                    font = self.font,
                    color = self.text,
                    pos = {w/2 + w/8, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER
                })
                draw.Text({
                    text = "Reason",
                    font = self.font,
                    color = self.text,
                    pos = {w*0.75 + w/8, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER
                })

                draw.RoundedBox(0, 0, 0, w, 2, self.text)
                draw.RoundedBox(0, w/4-1, 0, 2, h, self.text)
                draw.RoundedBox(0, w/2-1, 0, 2, h, self.text)
                draw.RoundedBox(0, w/4*3-1, 0, 2, h, self.text)
            end

            nadmin.menu.bans = nadmin.vgui:DScrollPanel(nil, {parent:GetWide(), parent:GetTall()-96}, parent)
            nadmin.menu.bans:Dock(TOP)
            function nadmin.menu.bans:Paint(w, h)
                paintLoad(w, h)
            end
            nadmin.menu.bans:GetCanvas():DockPadding(0, 0, 0, 4)

            local actions = nadmin.vgui:DPanel(nil, {parent:GetWide() - 8, 32}, parent)
            actions:Dock(BOTTOM)

            if LocalPlayer():HasPerm("ban") then
                local add = nadmin.vgui:DButton(nil, {parent:GetWide()/6, 28}, actions)
                add:Dock(LEFT)
                add:DockMargin(0, 4, 0, 0)
                add:SetText("Add a ban...")
                add:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                function add:DoClick()
                    nadmin.menu:Close()

                    local blur = nadmin.vgui:CreateBlur()

                    local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 0}, blur)
                    panel:SetTitle("Ban player")
                    panel:ShowCloseButton(false)
                    panel:MakePopup()

                    local nick = nadmin.vgui:DComboBox(nil, {panel:GetWide() - 8, 28}, panel)
                    nick:Dock(TOP)
                    nick:DockMargin(4, 0, 4, 0)
                    nick:SetValue("Nick...")

                    for i, ply in ipairs(player.GetHumans()) do
                        if ply:BetterThanOrEqual(LocalPlayer()) then continue end
                        nick:AddChoice(ply:Nick(), ply:SteamID())
                    end

                    local name = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 30, nick:GetTall()}, nick)
                    name:SetPlaceholderText("Name")
                    name.normalPaint = name.Paint
                    function name:Paint(w, h)
                        self:normalPaint(w, h)
                        draw.RoundedBox(0, w-2, 0, 2, h, nadmin:DarkenColor(self:GetColor(), 25))
                    end

                    local steamID = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, nick:GetTall()}, panel)
                    steamID:Dock(TOP)
                    steamID:DockMargin(4, 0, 4, 4)
                    steamID:SetPlaceholderText("Steam ID")
                    steamID.normalPaint = steamID.Paint
                    function steamID:ErrorCondition()
                        if #string.Trim(self:GetText()) == 0 then return true end

                        if not LocalPlayer():HasPerm("ip_ban") then
                            if not string.match(self:GetText(), nadmin.config.steamIDMatch) then return true end
                        end

                        return false
                    end
                    function steamID:Paint(w, h)
                        self:normalPaint(w, h)
                        draw.RoundedBox(0, 0, 0, w, 2, nadmin:DarkenColor(self:GetColor(), 25))
                    end

                    local reason = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, nick:GetTall()}, panel)
                    reason:Dock(TOP)
                    reason:DockMargin(4, 0, 4, 4)
                    reason:SetPlaceholderText("Reason")

                    local dur = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, nick:GetTall()}, panel)
                    dur:Dock(TOP)
                    dur:DockMargin(4, 0, 4, 4)
                    dur:SetPlaceholderText("Duration [indefinite]")
                    dur.normalPaint = dur.Paint
                    function dur:Paint(w, h)
                        self:normalPaint(w, h)

                        if self:GetText() ~= "" then
                            local duration = nadmin:ParseTime(self:GetText())
                            local text = "Indefinitely"
                            if isnumber(duration) and duration > 0 then
                                text = nadmin:TimeToString(duration, true)
                            end

                            surface.SetFont(self:GetFont())
                            local wid = surface.GetTextSize(self:GetText())
                            draw.Text({
                                text = text,
                                font = self:GetFont(),
                                color = nadmin:AlphaColor(self:GetColor(), 75),
                                pos = {wid + 10, h/2},
                                yalign = TEXT_ALIGN_CENTER
                            })
                        end
                    end

                    function nick:OnSelect(index, value, data)
                        name:SetText(value)
                        steamID:SetText(data)
                        reason:RequestFocus()
                    end

                    local controls = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, nick:GetTall()}, panel)
                    controls:Dock(TOP)
                    controls:DockMargin(4, 0, 4, 4)

                    local ban = nadmin.vgui:DButton(nil, {(panel:GetWide()-8)/2 - 2, nick:GetTall()}, controls)
                    ban:Dock(LEFT)
                    ban:SetText("Ban")
                    ban:SetColor(nadmin.colors.gui.red)
                    ban.normalPaint = ban.Paint
                    function ban:Paint(w, h)
                        ban:normalPaint(w, h)

                        if steamID:GetErrored() then
                            self:SetMouseInputEnabled(false)
                        else
                            self:SetMouseInputEnabled(true)
                        end
                    end
                    function ban:DoClick()
                        LocalPlayer():ConCommand("nadmin ban -id " .. steamID:GetText() .. " -duration " .. dur:GetText() .. " -nick " .. name:GetText() .. " -reason " .. reason:GetText())

                        blur:Remove()
                        nadmin.menu:Open("bans", filter)
                        timer.Simple(0.5, function()
                            nadmin.menu:SetTab("bans", filter)
                        end)
                    end

                    local cancel = nadmin.vgui:DButton(nil, {ban:GetWide(), nick:GetTall()}, controls)
                    cancel:Dock(RIGHT)
                    cancel:SetText("Cancel")
                    function cancel:DoClick()
                        blur:Remove()
                        nadmin.menu:Open("bans", filter)
                    end

                    panel:InvalidateLayout(true)
                    panel:SizeToChildren(false, true)
                    panel:SetTall(panel:GetTall() + 4)
                    panel:Center()
                end
            end

            if LocalPlayer():HasPerm("freeze") and LocalPlayer():HasPerm("ban") then
                local freeze = nadmin.vgui:DButton(nil, {parent:GetWide()/6, 28}, actions)
                freeze:Dock(LEFT)
                freeze:DockMargin(4, 4, 0, 0)
                freeze:SetText("Freeze Ban...")
                freeze:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                function freeze:DoClick()
                    if not LocalPlayer():HasPerm("freeze") then
                        if timer.Exists("nadmin_freeze_ban_reset_self_text") then timer.Remove("nadmin_freeze_ban_reset_self_text") end

                        self:SetText("Missing Permission!")

                        timer.Create("nadmin_freeze_ban_reset_self_text", 1, 1, function() if IsValid(self) then self:SetText("Freeze ban...") end end)
                        return
                    end

                    local players = {}
                    for i, ply in ipairs(player.GetHumans()) do
                        if ply:BetterThanOrEqual(LocalPlayer()) then continue end

                        table.insert(players, ply)
                    end

                    if #players > 0 then
                        local menu = DermaMenu()

                        for i, ply in ipairs(players) do
                            menu:AddOption(ply:Nick(), function()
                                if not IsValid(ply) then nadmin:Notify(nadmin.colors.red, "Player already left.") return end
                                if ply:GetNWBool("FrozenBanned") and IsValid(ply:GetNWEntity("FrozenBanner")) and ply:GetNWEntity("FrozenBanner") ~= LocalPlayer() then nadmin:Notify(nadmin.colors.red, "This player is already frozen by " .. ply:GetNWEntity("FrozenBanner"):Nick()) return end

                                net.Start("nadmin_freeze_ban")
                                    net.WriteEntity(ply)
                                net.SendToServer()

                                nadmin.menu:Close()

                                local blur = nadmin.vgui:CreateBlur()

                                local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 28}, blur)
                                panel:SetTitle("Freeze ban " .. ply:Nick() .. " (" .. ply:SteamID() .. ")")
                                panel.close_button.normalClick = panel.close_button.DoClick
                                function panel.close_button:DoClick()
                                    self:normalClick()

                                    net.Start("nadmin_freeze_ban")
                                        net.WriteEntity(ply)
                                    net.SendToServer()

                                    nadmin.menu:Open("bans", filter)
                                end
                                panel:MakePopup()

                                local name = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 30, 28}, panel)
                                name:Dock(TOP)
                                name:DockMargin(4, 0, 4, 4)
                                name:SetText(ply:Nick())
                                name:SetPlaceholderText("Name")

                                local reason = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, name:GetTall()}, panel)
                                reason:Dock(TOP)
                                reason:DockMargin(4, 0, 4, 4)
                                reason:SetPlaceholderText("Reason")

                                local dur = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, name:GetTall()}, panel)
                                dur:Dock(TOP)
                                dur:DockMargin(4, 0, 4, 4)
                                dur:SetPlaceholderText("Duration [indefinite]")
                                dur.normalPaint = dur.Paint
                                function dur:Paint(w, h)
                                    self:normalPaint(w, h)

                                    if self:GetText() ~= "" then
                                        local duration = nadmin:ParseTime(self:GetText())
                                        local text = "Indefinitely"
                                        if isnumber(duration) and duration > 0 then
                                            text = nadmin:TimeToString(duration, true)
                                        end

                                        surface.SetFont(self:GetFont())
                                        local wid = surface.GetTextSize(self:GetText())
                                        draw.Text({
                                            text = text,
                                            font = self:GetFont(),
                                            color = nadmin:AlphaColor(self:GetColor(), 75),
                                            pos = {wid + 10, h/2},
                                            yalign = TEXT_ALIGN_CENTER
                                        })
                                    end
                                end

                                local ban = nadmin.vgui:DButton(nil, {(panel:GetWide()-8)/2 - 2, name:GetTall()}, panel)
                                ban:Dock(TOP)
                                ban:DockMargin(4, 0, 4, 4)
                                ban:SetText("Ban")
                                ban:SetColor(nadmin.colors.gui.red)
                                ban:SetIcon("icon16/disk.png")
                                local sid = ply:SteamID()
                                function ban:DoClick()
                                    LocalPlayer():ConCommand("nadmin ban -id " .. sid .. " -duration " .. dur:GetText() .. " -nick " .. name:GetText() .. " -reason " .. reason:GetText())

                                    blur:Remove()
                                    nadmin.menu:Open("bans", filter)
                                    timer.Simple(0.5, function()
                                        nadmin.menu:SetTab("bans", filter)
                                    end)
                                end

                                panel:InvalidateLayout(true)
                                panel:SizeToChildren(false, true)
                                panel:SetTall(panel:GetTall() + 4)
                                panel:Center()
                            end)
                        end
                        menu:Open()

                        local x, y = self:LocalToScreen(0, 0)
                        menu:SetPos(x, y - menu:GetTall())
                    else
                        if timer.Exists("nadmin_freeze_ban_reset_self_text") then timer.Remove("nadmin_freeze_ban_reset_self_text") end

                        self:SetText("No players!")

                        timer.Create("nadmin_freeze_ban_reset_self_text", 1, 1, function() if IsValid(self) then self:SetText("Freeze ban...") end end)
                    end
                end
            end

            local arrow = Material(nadmin.icons["back_arrow"])

            nadmin.menu.right = nadmin.vgui:DButton({actions:GetWide() - 20, 4}, {28, 28}, actions)
            nadmin.menu.right:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            nadmin.menu.right.normalPaint = nadmin.menu.right.Paint
            function nadmin.menu.right:Paint(w, h)
                self:normalPaint(w, h)

                local tc = self:GetTextColor()
                surface.SetDrawColor(tc.r, tc.g, tc.b)
                surface.SetMaterial(arrow)
                surface.DrawTexturedRectRotated(w/2, h/2, h-8, h-8, 180)
            end

            nadmin.menu.page = nadmin.vgui:DTextEntry({actions:GetWide() - nadmin.menu.right:GetWide() - 76, 4}, {84, 28}, actions)
            nadmin.menu.page:SetText("1")
            nadmin.menu.page:SetNumeric(true)
            nadmin.menu.page:SetPlaceholderText("Page #")

            nadmin.menu.left = nadmin.vgui:DButton({actions:GetWide() - nadmin.menu.right:GetWide() - nadmin.menu.page:GetWide() - 20, 4}, {28, 28}, actions)
            nadmin.menu.left:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            nadmin.menu.left.normalPaint = nadmin.menu.left.Paint
            function nadmin.menu.left:Paint(w, h)
                self:normalPaint(w, h)

                local tc = self:GetTextColor()
                surface.SetDrawColor(tc.r, tc.g, tc.b)
                surface.SetMaterial(arrow)
                surface.DrawTexturedRect(4, 4, h-8, h-8)
            end

            nadmin.menu.results = nadmin.vgui:DLabel(nil, "0 results", actions)
            nadmin.menu.results:Dock(RIGHT)
            nadmin.menu.results:DockMargin(0, 4, nadmin.menu.right:GetWide() + nadmin.menu.page:GetWide() + nadmin.menu.left:GetWide() + 4, 0)

            local function applyFilter()
                nadmin.menu.bans:Clear()

                if timer.Exists("nadmin_request_bans") then timer.Remove("nadmin_request_bans") end

                net.Start("nadmin_request_bans") -- Request bans
                    net.WriteTable(filter)
                net.SendToServer()

                function nadmin.menu.bans:Paint(w, h)
                    paintLoad(w, h)
                end
            end

            function nadmin.menu.search:OnChange()
                filter.search = self:GetText()

                -- Using a timer that way it doesn't network each time they type,
                -- but only when they stop
                if timer.Exists("nadmin_request_bans") then timer.Remove("nadmin_request_bans") end
                timer.Create("nadmin_request_bans", 0.25, 1, function()
                    applyFilter()
                end)
            end
            function nadmin.menu.sort:OnSelect(index, value, data)
                filter.sort = data

                applyFilter()
            end
            function nadmin.menu.showPerm:OnChecked(checked)
                filter.showPerma = checked

                applyFilter()
            end
            function nadmin.menu.left:DoClick()
                if not isnumber(filter.page) then filter.page = 1 end
                filter.page = filter.page - 1

                applyFilter()
            end
            function nadmin.menu.right:DoClick()
                if not isnumber(filter.page) then filter.page = 1 end
                filter.page = filter.page + 1

                applyFilter()
            end

            net.Start("nadmin_request_bans") -- Request bans
                net.WriteTable(filter)
            net.SendToServer()
        end
    })

    net.Receive("nadmin_request_bans", function()
        local canView = net.ReadBool()
        local results = net.ReadTable()
        local pages   = net.ReadInt(32)

        if not IsValid(nadmin.menu.bans) then return end -- They client left the tab before they loaded the bans
        nadmin.menu.bans:Clear() -- Clear all the bans
        local filter = nadmin.menu.filter

        -- The only time this would happen is if the player is running lua from
        -- their client without using this tab.
        if not canView then
            function nadmin.menu.bans:Paint(w, h)
                draw.Text({
                    text = "You weren't authed by the server to view bans.",
                    font = "nadmin_derma",
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            nadmin.menu.results:SetText("0 results (based on your filters)")
            nadmin.menu.results:SizeToContents()
            nadmin.menu.page:SetText("1")
        else
            if #results == 0 then
                function nadmin.menu.bans:Paint(w, h)
                    draw.Text({
                        text = "No Results.",
                        font = "nadmin_derma",
                        pos = {w/2, h/2},
                        xalign = TEXT_ALIGN_CENTER,
                        yalign = TEXT_ALIGN_CENTER,
                        color = nadmin:TextColor(nadmin.colors.gui.theme)
                    })
                end
                nadmin.menu.results:SetText("0 results")
                nadmin.menu.results:SizeToContents()
                nadmin.menu.page:SetText("1")
            else
                function nadmin.menu.bans:Paint(w, h) end
                nadmin.menu.results:SetText(#results .. " result" .. ((#results ~= 1) and "s" or ""))
                nadmin.menu.results:SizeToContents()
                nadmin.menu.page:SetText(tostring(math.Clamp(tonumber(nadmin.menu.page:GetText()) or 1, 1, pages)))

                local textCol = nadmin:TextColor(nadmin.colors.gui.theme)
                for i, r in ipairs(results) do
                    local ban = nadmin.vgui:DButton(nil, {nadmin.menu.bans:GetWide(), 28}, nadmin.menu.bans)
                    ban:Dock(TOP)
                    ban:DockMargin(4, 4, 4, 0)
                    ban:SetColor(nadmin.colors.gui.theme)
                    function ban:Paint(w, h)
                        local col = nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0))

                        draw.RoundedBox(0, 0, 0, w/4, h, col)
                        draw.Text({
                            text = isstring(r.targ_nick) and r.targ_nick or (isstring(r.targ_id) and r.targ_id or "[Unknown]"),
                            font = self:GetFont(),
                            color = self:GetTextColor(),
                            pos = {4, h/2},
                            yalign = TEXT_ALIGN_CENTER
                        })

                        draw.RoundedBox(0, w/4, 0, w/4, h, col)
                        draw.Text({
                            text = isstring(r.by) and r.by or (isstring(r.by_steamid) and r.by_steamid or "[Unknown]"),
                            font = self:GetFont(),
                            color = self:GetTextColor(),
                            pos = {w/4 + 5, h/2},
                            yalign = TEXT_ALIGN_CENTER
                        })

                        draw.RoundedBox(0, w/2, 0, w/4, h, col)
                        draw.Text({
                            text = (isnumber(r.start) and isnumber(r.dur) and r.dur > 0) and os.date("%m/%d/%y %H:%M:%S", r.start + r.dur) or "[Indefinite ban]",
                            font = self:GetFont(),
                            color = self:GetTextColor(),
                            pos = {w/2 + 5, h/2},
                            yalign = TEXT_ALIGN_CENTER
                        })

                        draw.RoundedBox(0, w*0.75, 0, w/4, h, col)
                        draw.Text({
                            text = (isstring(r.reason) and r.reason ~= "") and r.reason or "No reason given.",
                            font = self:GetFont(),
                            color = self:GetTextColor(),
                            pos = {w*0.75 + 5, h/2},
                            yalign = TEXT_ALIGN_CENTER
                        })

                        draw.RoundedBox(0, w/4-1, 0, 2, h, self:GetTextColor())
                        draw.RoundedBox(0, w/2-1, 0, 2, h, self:GetTextColor())
                        draw.RoundedBox(0, w*0.75-1, 0, 2, h, self:GetTextColor())
                    end
                    function ban:DoClick()
                        nadmin.menu:Close()

                        local blur = nadmin.vgui:CreateBlur()

                        local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 0}, blur)
                        panel:SetTitle("Ban details for " .. (isstring(r.targ_nick) and r.targ_nick or (isstring(r.targ_id) and r.targ_id or "[Unknown]")))
                        panel:MakePopup()

                        local nameB = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        nameB:Dock(TOP)
                        nameB:DockMargin(4, 0, 4, 4)

                        local nameL = nadmin.vgui:DLabel(nil, "Name:", nameB)

                        local nameT = nadmin.vgui:DTextEntry({nameL:GetWide() + 4, 0}, {nameB:GetWide() - nameL:GetWide() - 4, nameB:GetTall()}, nameB)
                        nameT:SetText(isstring(r.targ_nick) and r.targ_nick or "")
                        nameT:SetPlaceholderText("Name")
                        if not LocalPlayer():HasPerm("ban") then
                            nameT:SetMouseInputEnabled(false)
                            nameT:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        end


                        local idB = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        idB:Dock(TOP)
                        idB:DockMargin(4, 0, 4, 4)

                        local idL = nadmin.vgui:DLabel(nil, "SteamID / IP:", idB)

                        local idT = nadmin.vgui:DTextEntry({idL:GetWide() + 4, 0}, {idB:GetWide() - idL:GetWide() - 4, idB:GetTall()}, idB)
                        idT:SetText(r.targ_id)
                        idT:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        idT:SetMouseInputEnabled(false)


                        local banStart = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        banStart:Dock(TOP)
                        banStart:DockMargin(4, 0, 4, 4)

                        local bannedOnL = nadmin.vgui:DLabel(nil, "Banned on:", banStart)

                        local bannedOn = nadmin.vgui:DTextEntry({bannedOnL:GetWide() + 4, 0}, {banStart:GetWide() - bannedOnL:GetWide() - 4, banStart:GetTall()}, banStart)
                        bannedOn:SetText(isnumber(r.start) and os.date("%m/%d/%y %H:%M:%S", r.start) or "[Unknown]")
                        bannedOn:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        bannedOn:SetMouseInputEnabled(false)


                        local banDur = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        banDur:Dock(TOP)
                        banDur:DockMargin(4, 0, 4, 4)

                        local banDurL = nadmin.vgui:DLabel(nil, "Ban duration:", banDur)

                        local banDuration = nadmin.vgui:DTextEntry({banDurL:GetWide() + 4, 0}, {banDur:GetWide() - banDurL:GetWide() - 4, banDur:GetTall()}, banDur)
                        banDuration:SetText((isnumber(r.dur) and r.dur > 0) and nadmin:TimeToString(r.dur) or "0")
                        if not LocalPlayer():HasPerm("ban") then
                            banDuration:SetMouseInputEnabled(false)
                            banDuration:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        end
                        banDuration:SetPlaceholderText("Ban duration")
                        banDuration.normalPaint = banDuration.Paint
                        function banDuration:Paint(w, h)
                            self:normalPaint(w, h)

                            if self:GetText() ~= "" then
                                local time = nadmin:ParseTime(self:GetText())
                                local text
                                if isnumber(time) and time > 0 then
                                    text = nadmin:TimeToString(time, true)
                                else
                                    text = "[Indefinite]"
                                end

                                surface.SetFont(self:GetFont())
                                local wid = surface.GetTextSize(self:GetText())

                                draw.Text({
                                    text = text,
                                    font = self:GetFont(),
                                    pos = {wid + 10, h/2},
                                    yalign = TEXT_ALIGN_CENTER,
                                    color = nadmin:AlphaColor(self:GetTextColor(), 75)
                                })
                            end
                        end


                        local unban = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        unban:Dock(TOP)
                        unban:DockMargin(4, 0, 4, 4)

                        local unbanL = nadmin.vgui:DLabel(nil, "Unban date:", unban)

                        local unbanDate = nadmin.vgui:DTextEntry({unbanL:GetWide() + 4, 0}, {unban:GetWide() - unbanL:GetWide() - 4, unban:GetTall()}, unban)
                        unbanDate:SetText((isnumber(r.start) and isnumber(r.dur) and r.dur > 0) and os.date("%m/%d/%y %H:%M:%S", r.start + r.dur) or "[Never]")
                        unbanDate:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        unbanDate:SetMouseInputEnabled(false)


                        local bannedBy = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        bannedBy:Dock(TOP)
                        bannedBy:DockMargin(4, 0, 4, 4)

                        local banByL = nadmin.vgui:DLabel(nil, "Banned by:", bannedBy)

                        local banBy = nadmin.vgui:DTextEntry({banByL:GetWide() + 4, 0}, {bannedBy:GetWide() - banByL:GetWide() - 4, bannedBy:GetTall()}, bannedBy)
                        banBy:SetText((isstring(r.by) and isstring(r.by_steamid)) and (r.by .. " (" .. r.by_steamid .. ")") or ((isstring(r.by) or isstring(r.by_steamid)) and (r.by or r.by_steamid) or "[Unknown]"))
                        banBy:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        banBy:SetMouseInputEnabled(false)


                        local reasonB = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        reasonB:Dock(TOP)
                        reasonB:DockMargin(4, 0, 4, 4)

                        local reasonL = nadmin.vgui:DLabel(nil, "Reason:", reasonB)

                        local reasonT = nadmin.vgui:DTextEntry({reasonL:GetWide() + 4, 0}, {reasonB:GetWide() - reasonL:GetWide() - 4, reasonB:GetTall()}, reasonB)
                        reasonT:SetText(isstring(r.reason) and r.reason or "")
                        reasonT:SetPlaceholderText("No reason given.")
                        if not LocalPlayer():HasPerm("ban") then
                            reasonT:SetMouseInputEnabled(false)
                            reasonT:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                        end

                        local copy = nadmin.vgui:DButton(nil, {panel:GetWide() - 8, 28}, panel)
                        copy:Dock(TOP)
                        copy:DockMargin(4, 0, 4, 4)
                        copy:SetText("Copy ban information")
                        copy:SetIcon("icon16/page_white_copy.png")
                        function copy:DoClick()
                            local str = "Ban: " .. (isstring(r.targ_nick) and r.targ_nick .. " (" .. r.targ_id .. ")" or r.targ_id)
                            str = str .. "\n" .. "Banned on: " .. (isnumber(r.start) and os.date("%m/%d/%y %H:%M:%S", r.start) or "[Unknown]")
                            str = str .. "\n" .. "Ban duration: " .. ((isnumber(r.dur) and r.dur > 0) and nadmin:TimeToString(r.dur, true) or "[Indefinite]")
                            str = str .. "\n" .. "Unban date: " .. ((isnumber(r.start) and isnumber(r.dur) and r.dur > 0) and os.date("%m/%d/%y %H:%M:%S", r.start + r.dur) or "[Never]")
                            str = str .. "\n" .. "Banned by: " .. ((isstring(r.by) and isstring(r.by_steamid)) and r.by .. " (" .. r.by_steamid .. ")" or ((isstring(r.by) or isstring(r.by_steamid)) and (r.by or r.by_steamid) or "[Unknown]"))
                            str = str .. "\n" .. "Reason: " .. ((isstring(r.reason) and r.reason ~= "") and r.reason or "No reason given.")

                            SetClipboardText(str)
                            notification.AddLegacy("Ban information copied to clipboard!", NOTIFY_HINT, 3)
                            surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
                        end

                        local controls = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 28}, panel)
                        controls:Dock(TOP)
                        controls:DockMargin(4, 0, 4, 4)

                        local uban = nadmin.vgui:DButton(nil, {(panel:GetWide()-8)/2 - 2, controls:GetTall()}, controls)
                        uban:Dock(LEFT)
                        uban:SetText("Unban")
                        uban:SetColor(nadmin.colors.gui.red)
                        uban:SetIcon("icon16/bin_closed.png")
                        if not LocalPlayer():HasPerm("unban") then uban:SetMouseInputEnabled(false) end
                        function uban:DoClick()
                            LocalPlayer():ConCommand("nadmin unban " .. r.targ_id)

                            blur:Remove()
                            nadmin.menu:Open("bans", filter)
                            timer.Simple(0.5, function()
                                nadmin.menu:SetTab("bans", filter)
                            end)
                        end

                        local save = nadmin.vgui:DButton(nil, {uban:GetWide(), controls:GetTall()}, controls)
                        save:Dock(RIGHT)
                        save:SetText("Save")
                        save:SetIcon("icon16/disk.png")
                        if not LocalPlayer():HasPerm("ban") then
                            save:SetMouseInputEnabled(false)
                        end
                        function save:DoClick()
                            net.Start("nadmin_edit_ban")
                                net.WriteString(r.targ_id or "")
                                net.WriteString(nameT:GetText())
                                net.WriteString(banDuration:GetText())
                                net.WriteString(reasonT:GetText())
                            net.SendToServer()

                            blur:Remove()
                            nadmin.menu:Open("bans", filter)
                            timer.Simple(0.5, function()
                                nadmin.menu:SetTab("bans", filter)
                            end)
                        end

                        panel:InvalidateLayout(true)
                        panel:SizeToChildren(false, true)
                        panel:SetTall(panel:GetTall() + 4)
                        panel:Center()
                    end
                end
            end
        end
    end)

    net.Receive("nadmin_freeze_ban", function()
        local frozen = net.ReadBool()
        local ply    = net.ReadEntity()

        if IsValid(nadmin.freeze_screen) then nadmin.freeze_screen:Remove() end

        if frozen then
            nadmin.freeze_screen = vgui.Create("DPanel")
            nadmin.freeze_screen:SetSize(ScrW(), ScrH())
            nadmin.freeze_screen.text = "You are currently in the process of being banned by " .. ply:Nick()
            nadmin.freeze_screen.subText = "Leaving during this time will result in an immediate permanent ban."
            nadmin.freeze_screen.font = "nadmin_derma_xl"
            nadmin.freeze_screen.subFont = "nadmin_derma_large"
            nadmin.freeze_screen.textColor = Color(255, 255, 255)
            nadmin.freeze_screen.start = SysTime()
            nadmin.freeze_screen.startFade = SysTime()
            nadmin.freeze_screen.fadeVal = 200
            nadmin.freeze_screen.blurVal = 5
            nadmin.freeze_screen.dur = 1
            function nadmin.freeze_screen:Paint(w, h)
                local col
                local blur
                if SysTime() < self.startFade + self.dur then
                    col = Color(0, 0, 0, nadmin:Lerp(0, self.fadeVal, (SysTime() - self.startFade) / self.dur))
                    blur = nadmin:Lerp(0, self.blurVal, (SysTime() - self.startFade) / self.dur)
                else
                    col = Color(0, 0, 0, self.fadeVal)
                    blur = self.blurVal
                end
                draw.RoundedBox(0, 0, 0, w, h, col)
                draw.Blur(0, 0, w, h, blur)

                draw.Text({
                    text = self.text,
                    font = self.font,
                    color = self.textColor,
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM
                })
                draw.Text({
                    text = self.subText,
                    font = self.subFont,
                    color = self.textColor,
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP
                })
            end
            nadmin.freeze_screen:MakePopup()
        end
    end)
else
    local function find(haystack, needle)
        return string.find(haystack, needle, 1, true)
    end

    net.Receive("nadmin_edit_ban", function(len, ply)
        local id = net.ReadString()
        local name = net.ReadString()
        local dura = net.ReadString()
        local reason = net.ReadString()

        local canBan = ply:HasPerm("ban")
        local ipBan  = ply:HasPerm("ip_ban")

        if not canBan and not ipBan then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            return
        end

        if not ipBan and not string.match(id, nadmin.config.steamIDMatch) then
            nadmin:Notify(ply, nadmin.colors.red, "Invalid Steam ID format.")
            return
        end

        if not istable(nadmin.bans[id]) then
            nadmin:Notify(ply, nadmin.colors.red, "No bans indexed with ", nadmin.colors.white, id, nadmin.colors.red, ".")
            return
        end

        local dur = nadmin:ParseTime(dura)
        if not isnumber(dur) then dur = 0 end

        local ban = nadmin.bans[id]
        ban.targ_nick = name
        ban.dur = dur
        ban.reason = reason
        nadmin:SaveBans()

        local myCol = nadmin:GetNameColor(ply)

        local tCol = nadmin.colors.red
        if istable(nadmin.userdata[id]) then
            local rank = nadmin:FindRank(nadmin.userdata[id].rank)
            if istable(rank) then
                tCol = rank.color
            end
        end

        nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has updated ban details for ", tCol, ban.targ_nick, nadmin.colors.white, ".")
        nadmin:Log("administration", ply:PlayerToString("nick (steamid)<ipaddress>") .. " has edited ban " .. ban.targ_id)
    end)

    net.Receive("nadmin_request_bans", function(len, ply)
        local filter = net.ReadTable()

        local viewBans = ply:HasPerm("bans")
        local viewIPs  = ply:HasPerm("ip_ban")

        if not viewBans then
            net.Start("nadmin_request_bans")
                net.WriteBool(false)
                net.WriteTable({})
                net.WriteInt(0, 32)
            net.Send(ply)
        else
            local keys = table.GetKeys(nadmin.bans)
            local bans = {}
            for i = 1, #keys do
                if not viewIPs and not string.match(keys[i], nadmin.config.steamIDMatch) then continue end
                local b = nadmin.bans[keys[i]]

                if isstring(filter.search) then
                    local search = string.lower(filter.search)
                    local found = find(string.lower(keys[i]), search)
                    if not found and isstring(b.by) then found = find(string.lower(b.by), search) end
                    if not found and isstring(b.by_steamid) then found = find(string.lower(b.by_steamid), search) end
                    if not found and isstring(b.reason) then found = find(string.lower(b.reason), search) end
                    if not found and isstring(b.targ_nick) then found = find(string.lower(b.targ_nick), search) end

                    if not found then continue end
                end

                if isbool(filter.showPerma) and not filter.showPerma then
                    if not (isnumber(b.dur) or isnumber(b.start)) or (isnumber(b.dur) and b.dur <= 0) then continue end
                end

                table.insert(bans, table.Copy(b))
            end

            local pages = math.ceil(#bans/nadmin.config.banPerPage)
            local page = 1
            if isnumber(filter.page) then
                page = math.Clamp(math.Round(filter.page), 1, pages)
            end

            local banCount = #bans
            local ind = nadmin.config.banPerPage * (page - 1)
            local toSend = {}
            for i = ind + 1, ind + nadmin.config.banPerPage do
                if ind > banCount then break end -- We have reached the end of the line
                table.insert(toSend, bans[i])
            end

            if isstring(filter.sort) then
                if filter.sort == "banned_len" then
                    table.sort(toSend, function(a, b)
                        return (isnumber(a.dur) and a.dur or 0) > (isnumber(b.dur) and b.dur or 0)
                    end)
                elseif filter.sort == "banned_by" then
                    table.sort(toSend, function(a, b)
                        return (isstring(a.by) and a.by or (isstring(a.by_steamid) and a.by_steamid or "")) < (isstring(b.by) and b.by or (isstring(b.by_steamid) and b.by_steamid or ""))
                    end)
                elseif filter.sort == "date_on" then
                    table.sort(toSend, function(a, b) return a.start < b.start end)
                elseif filter.sort == "name" then
                    table.sort(toSend, function(a, b)
                        return (isstring(a.targ_nick) and a.targ_nick or "") < (isnumber(b.targ_nick) and b.targ_nick or "")
                    end)
                elseif filter.sort == "steamid" then
                    table.sort(toSend, function(a, b)
                        return (isstring(a.targ_id) and a.targ_id or "") < (isnumber(b.targ_id) and b.targ_id or "")
                    end)
                elseif filter.sort == "unban" then
                    table.sort(toSend, function(a, b)
                        return (isnumber(a.start) and a.start or 0) + (isnumber(a.dur) and a.dur or 0) > (isnumber(b.start) and b.start or 0) + (isnumber(b.dur) and b.dur or 0)
                    end)
                else
                    table.sort(toSend, function(a, b) return a.start > b.start end)
                end
            else
                table.sort(toSend, function(a, b) return a.start > b.start end)
            end

            net.Start("nadmin_request_bans")
                net.WriteBool(true)
                net.WriteTable(toSend)
                net.WriteInt(pages, 32)
            net.Send(ply)
        end
    end)

    net.Receive("nadmin_freeze_ban", function(len, ply)
        local targ = net.ReadEntity()

        if not ply:HasPerm("freeze") then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            return
        end

        if targ:BetterThanOrEqual(ply) then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.noTargLess)
            return
        end

        if not IsValid(targ:GetNWEntity("FrozenBanner")) then targ:SetNWBool("FrozenBanned", false) end

        if targ:GetNWEntity("FrozenBanner") ~= ply and targ:GetNWBool("FrozenBanned") then
            nadmin:Notify(ply, "This player is already frozen by " .. targ:GetNWEntity("FrozenBanner"))
            return
        end

        if targ:IsPlayer() then
            if targ:GetNWBool("FrozenBanned") then
                targ:UnLock()
                targ:SetNWBool("FrozenBanned", false)
                targ:SetNWEntity("FrozenBanner", NULL)
            else
                targ:Lock()
                targ:SetNWBool("FrozenBanned", true)
                targ:SetNWEntity("FrozenBanner", ply)

                targ:RemoveProps()
            end

            net.Start("nadmin_freeze_ban")
                net.WriteBool(targ:GetNWBool("FrozenBanned"))
                net.WriteEntity(targ:GetNWEntity("FrozenBanner"))
            net.Send(targ)
        end
    end)

    hook.Add("Think", "nadmin_unfreeze_disconnected_banner", function()
        for i, ply in ipairs(player.GetAll()) do
            if not IsValid(ply:GetNWEntity("FrozenBanner")) and ply:GetNWBool("FrozenBanned") then
                ply:SetNWBool("FrozenBanned", false)
                ply:UnLock()
                net.Start("nadmin_freeze_ban")
                    net.WriteBool(false)
                    net.WriteEntity(NULL)
                net.Send(targ)
            end
        end
    end)
end
