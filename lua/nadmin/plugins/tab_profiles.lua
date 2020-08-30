if CLIENT then
    nadmin.menu:RegisterTab({
        title = "Profiles",
        sort = 4,
        content = function(parent, data)
            local filter = {}
            if istable(data) then filter = data end
            if not isnumber(filter.page) then filter.page = 1 end

            local w = parent:GetWide()

            nadmin.menu.profiles = nadmin.vgui:DScrollPanel({0, 0}, {w, parent:GetTall() - 32}, parent)
            nadmin.menu.profiles:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            nadmin.menu.controls = {}
            local controls = nadmin.menu.controls

            controls.panel = nadmin.vgui:DPanel({0, parent:GetTall() - 32}, {w, 32}, parent)
            controls.panel:DockPadding(0, 4, 0, 0)

            controls.search = nadmin.vgui:DTextEntry(nil, {(w-8)/4, 28}, controls.panel)
            controls.search:Dock(LEFT)
            controls.search:SetPlaceholderText("Offline player filter")
            if isstring(filter.search) then controls.search:SetText(filter.search) end

            local ranks = {}
            for id, rank in pairs(nadmin.ranks) do
                table.insert(ranks, rank)
            end
            table.sort(ranks, function(a, b) return a.immunity > b.immunity end)

            controls.rank = nadmin.vgui:DComboBox(nil, {(w-8)/4, 28}, controls.panel)
            controls.rank:Dock(LEFT)
            controls.rank:DockMargin(4, 0, 0, 0)
            controls.rank:SetSortItems(false)
            controls.rank:AddChoice("Any Rank", nil, not isstring(filter.rank))
            for i, rank in pairs(ranks) do
                controls.rank:AddChoice(rank.title .. " (" .. rank.id .. ")", rank.id, rank.id == filter.rank, rank.icon)
            end

            local arrow = Material(nadmin.icons["back_arrow"])

            controls.right = nadmin.vgui:DButton({controls.panel:GetWide() - 28, 4}, {28, 28}, controls.panel)
            controls.right:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            controls.right.normalPaint = controls.right.Paint
            function controls.right:Paint(w, h)
                self:normalPaint(w, h)

                local tc = self:GetTextColor()
                surface.SetDrawColor(tc.r, tc.g, tc.b)
                surface.SetMaterial(arrow)
                surface.DrawTexturedRectRotated(w/2, h/2, h-8, h-8, 180)
            end

            controls.page = nadmin.vgui:DTextEntry({controls.panel:GetWide() - controls.right:GetWide() - 84, 4}, {84, 28}, controls.panel)
            controls.page:SetText("1")
            controls.page:SetNumeric(true)
            controls.page:SetPlaceholderText("Page #")

            controls.left = nadmin.vgui:DButton({controls.panel:GetWide() - controls.right:GetWide() - controls.page:GetWide() - 28, 4}, {28, 28}, controls.panel)
            controls.left:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            controls.left.normalPaint = controls.left.Paint
            function controls.left:Paint(w, h)
                self:normalPaint(w, h)

                local tc = self:GetTextColor()
                surface.SetDrawColor(tc.r, tc.g, tc.b)
                surface.SetMaterial(arrow)
                surface.DrawTexturedRect(4, 4, h-8, h-8)
            end

            nadmin.menu.results = nadmin.vgui:DLabel(nil, "0 results", controls.panel)
            nadmin.menu.results:Dock(RIGHT)
            nadmin.menu.results:DockMargin(0, 4, controls.right:GetWide() + controls.page:GetWide() + controls.left:GetWide() + 4, 0)

            local function drawOnline()
                local online = nadmin.vgui:DPanel(nil, {w, 24}, parent)
                online:Dock(TOP)
                online:DockMargin(4, 4, 4, 0)
                online.normalPaint = online.Paint
                online:SetColor(nadmin.colors.gui.blue)
                online.txt = nadmin:TextColor(online:GetColor())
                function online:Paint(w, h)
                    self:normalPaint(w, h)

                    draw.Text({
                        text = "Online",
                        font = "nadmin_derma",
                        pos = {w/2, h/2},
                        xalign = TEXT_ALIGN_CENTER,
                        yalign = TEXT_ALIGN_CENTER,
                        color = self.txt
                    })
                end

                nadmin.menu.online_players = {}
                local plys = nadmin.menu.online_players -- Make it easier to add to this table later

                local players = player.GetHumans()
                local ranks = {}
                for i, ply in ipairs(players) do
                    local rank = ply:GetRank()
                    if not table.HasValue(ranks, rank) then
                        table.insert(ranks, rank)
                    end
                end

                if #ranks > 1 then
                    table.sort(ranks, function(a, b) return a.immunity > b.immunity end)
                end
                if #players > 1 then
                    table.sort(players, function(a, b) return a:Nick() < b:Nick() end)
                end

                for i, rank in ipairs(ranks) do
                    local rBar = nadmin.vgui:DButton(nil, {w, 24}, parent)
                    rBar:Dock(TOP)
                    rBar:DockMargin(4, 4, 4, 0)
                    rBar:SetText(rank.title)
                    rBar:SetColor(nadmin:BrightenColor(rank.color, 25))
                    rBar:SetIcon(rank.icon)
                    rBar:SetMouseInputEnabled(false)

                    for x, ply in ipairs(players) do
                        if ply:GetRank().id ~= rank.id then continue end

                        local bar = nadmin.vgui:DButton(nil, {w, 40}, parent)
                        bar:Dock(TOP)
                        bar:DockMargin(4, 0, 4, 0)
                        bar:SetColor(nadmin.colors.gui.theme)
                        bar.normalPaint = bar.Paint
                        bar.ply = ply
                        function bar:Paint(w, h)
                            self:normalPaint(w, h)

                            local text = "[Player Left]"
                            if IsValid(self.ply) then
                                text = self.ply:Nick() .. " (" .. self.ply:SteamID() .. ")"
                            end

                            draw.Text({
                                text = text,
                                font = "nadmin_derma",
                                pos = {42, h/2},
                                yalign = TEXT_ALIGN_CENTER,
                                color = self:GetTextColor()
                            })
                        end

                        local av = vgui.Create("AvatarImage", bar)
                        av:Dock(LEFT)
                        av:DockMargin(2, 2, 2, 2)
                        av:SetSize(36, 36)
                        av:SetPlayer(ply, 64)
                    end
                end
            end

            if filter.page == 1 then
                drawOnline()
            end

            nadmin.menu.profile_offline = nadmin.vgui:DPanel(nil, {w, 64}, parent)
            nadmin.menu.profile_offline:Dock(TOP)
            nadmin.menu.profile_offline:DockMargin(4, 4, 4, 0)
            nadmin.menu.profile_offline:DockPadding(0, 24, 0, 0)
            nadmin.menu.profile_offline.showLoad = true
            function nadmin.menu.profile_offline:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, 24, self:GetColor())

                local tc = nadmin:TextColor(self:GetColor())
                draw.Text({
                    text = "Offline",
                    font = "nadmin_derma",
                    pos = {w/2, 12},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = tc
                })

                if self.showLoad then
                    draw.Circle(w/2, 44, 16, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                    draw.Circle(w/2, 44, 16, 360, 270, (SysTime() % 360) * 180, tc)
                    draw.Circle(w/2, 44, 14, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                end
            end

            -- net.Start("nadmin_retrieve_profiles")
            -- net.SendToServer()
        end
    })
else
    util.AddNetworkString("nadmin_retrieve_profiles")
end

nadmin:RegisterPerm({
    title = "View Offline Profiles"
})
