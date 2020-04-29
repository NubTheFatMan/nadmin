if CLIENT then
    local function createRank(ranks, oid)
        local blur = nadmin.vgui:CreateBlur()

        local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 162}, blur)
        panel:SetTitle("Create a new rank")
        panel:Center()
        panel:MakePopup()

        local w = panel:GetWide()

        local idText = nadmin.vgui:DLabel({4, 34}, "ID:", panel)
        idText:SetTall(28)

        local id = nadmin.vgui:DTextEntry({idText:GetWide() + 8, 34}, {w - idText:GetWide() - 12, 28}, panel)
        id:SetPlaceholderText("Rank ID")
        function id:ErrorCondition()
            if string.Trim(self:GetText()) == "" then return true end

            local rankIDs = {}
            for i, rank in pairs(nadmin.ranks) do
                if rank.id == oid then continue end
                table.insert(rankIDs, rank.id)
            end
            return table.HasValue(rankIDs, string.Trim(self:GetText()))
        end

        local titleText = nadmin.vgui:DLabel({4, 66}, "Title:", panel)
        titleText:SetTall(28)

        local title = nadmin.vgui:DTextEntry({titleText:GetWide() + 8, 66}, {w - titleText:GetWide() - 12, 28}, panel)
        title:SetPlaceholderText("Rank Title")
        function title:ErrorCondition()
            return string.Trim(self:GetText()) == ""
        end

        local inherit = NULL
        local rankSelect = nadmin.vgui:DComboBox({4, 98}, {w - 8, 28}, panel)
        rankSelect:SetSortItems(false)
        rankSelect:SetValue("Select a rank to inherit from...")
        for i, rank in ipairs(ranks) do
            rankSelect:AddChoice(rank.title .. " (" .. rank.id .. ")", rank)
        end
        function rankSelect:OnSelect(index, text, data)
            inherit = table.Copy(data)
        end

        w = panel:GetWide()/2 - 6
        local yes = nadmin.vgui:DButton({4, 130}, {w, 28}, panel)
        yes:SetText("Create")
        yes.normalPaint = yes.Paint
        function yes:Paint(w, h)
            self:normalPaint(w, h)

            if title:GetErrored() then
                self:SetText("Create")
            else
                self:SetText("Create " .. string.Trim(title:GetText()))
            end

            if id:GetErrored() or title:GetErrored() or inherit == NULL then
                self:SetMouseInputEnabled(false)
            else
                self:SetMouseInputEnabled(true)
            end
        end
        function yes:DoClick()
            local r = string.Trim(id:GetText())
            inherit.id = r
            inherit.title = string.Trim(title:GetText())

            net.Start("nadmin_updateRank")
                net.WriteString("Create")
                net.WriteTable(inherit)
                net.WriteString("")
            net.SendToServer()

            blur:Remove()
            nadmin.menu:Open("ranks")
            timer.Simple(1, function()
                nadmin.menu:SetTab("ranks", {id = r})
            end)
        end

        local no = nadmin.vgui:DButton({panel:GetWide()/2 + 2, 130}, {w, 28}, panel)
        no:SetText("Cancel")
        function no:DoClick()
            blur:Remove()
            nadmin.menu:Open("ranks", {id = oid})
        end
    end

    local function addMember(editRank, oid)
        local blur = nadmin.vgui:CreateBlur()

        local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 0}, blur)
        panel:SetTitle("Add user to " .. editRank.title)
        panel:MakePopup()

        local plys = {}
        local ply
        for i, ply in ipairs(player.GetHumans()) do
            if ply:GetRank().id == oid then continue end
            if ply == LocalPlayer() then continue end
            if ply:BetterThanOrEqual(LocalPlayer()) then continue end
            table.insert(plys, {nick = ply:Nick(), id = ply:SteamID()})
        end
        table.sort(plys, function(a, b) return a.nick < b.nick end)
        table.insert(plys, 1, {nick = "Please select a person..."})

        local list = nadmin.vgui:DComboBox(nil, {panel:GetWide() - 8, 28}, panel)
        list:Dock(TOP)
        list:DockMargin(4, 0, 4, 4)
        list:SetSortItems(false)
        list:SetValue(plys[1].nick)
        for i, ply in ipairs(plys) do
            if isstring(ply.steamid) then
                list:AddChoice(ply.nick .. " (" .. ply.steamid .. ")", ply.id)
            else
                list:AddChoice(ply.nick, ply.id)
            end
        end

        local div = nadmin.vgui:DPanel(nil, {panel:GetWide() - 8, 20}, panel)
        div:Dock(TOP)
        div:DockMargin(4, 0, 4, 4)
        function div:Paint(w, h)
            surface.SetFont("nadmin_derma")
            local wid = surface.GetTextSize("or")

            draw.Text({
                text = "or",
                font = "nadmin_derma_b",
                pos = {w/2, h/2},
                xalign = TEXT_ALIGN_CENTER,
                yalign = TEXT_ALIGN_CENTER,
                color = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
            })

            draw.RoundedBox(0, 0, 8, w/2 - wid/2 - 4, 4, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            draw.RoundedBox(0, w/2 + wid/2 + 7, 8, w/2 - wid/2 - 7, 4, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
        end

        local steamID = nadmin.vgui:DTextEntry(nil, {panel:GetWide() - 8, 28}, panel)
        steamID:Dock(TOP)
        steamID:DockMargin(4, 0, 4, 4)
        steamID:SetPlaceholderText("By Steam ID")
        function steamID:ErrorCondition()
            if self:IsMouseInputEnabled() then
                return not string.match(self:GetText(), nadmin.config.steamIDMatch)
            end
        end
        function list:OnSelect(index, value, data)
            if isstring(data) then
                steamID:SetMouseInputEnabled(false)
            else
                steamID:SetMouseInputEnabled(true)
            end
            ply = data
        end

        function steamID:OnChange()
            if not self:IsMouseInputEnabled() then
                self:SetText("")
                return
            end

            if string.Trim(self:GetText()) ~= "" then
                list:SetEnabled(false)
                ply = string.match(self:GetText(), nadmin.config.steamIDMatch)
            else
                list:SetEnabled(true)
                ply = nil
            end
        end

        local add = nadmin.vgui:DButton(nil, {panel:GetWide() - 8, 28}, panel)
        add:Dock(TOP)
        add:DockMargin(4, 0, 4, 4)
        add:SetText("Add")
        add:SetIcon("icon16/disk.png")
        add.normalPaint = add.Paint
        function add:Paint(w, h)
            self:normalPaint(w, h)

            if isstring(ply) then
                self:SetMouseInputEnabled(true)
                self:SetColor(nadmin.colors.gui.blue)
            else
                self:SetMouseInputEnabled(false)
                self:SetColor(nadmin.colors.gui.red)
            end
        end
        function add:DoClick()
            if not isstring(ply) then return end

            net.Start("nadmin_manage_member")
                net.WriteString("Add")
                net.WriteString(ply)
                net.WriteString(oid)
            net.SendToServer()

            blur:Remove()

            nadmin.menu:Open("ranks", {id = oid})
            timer.Simple(1, function()
                nadmin.menu:Open("ranks", {id = oid})
            end)
        end

        panel:InvalidateLayout(true)
        panel:SizeToChildren(false, true)
        panel:SetTall(panel:GetTall() + 4)
        panel:Center()
    end

    local function delRank(editRank, oid)
        local blur = nadmin.vgui:CreateBlur()

        local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 66}, blur)
        panel:ShowCloseButton(false)
        panel:Center()
        panel.normalPaint = panel.Paint
        function panel:Paint(w, h)
            self:normalPaint(w, h)

            draw.Text({
                text = "Are you sure? This action cannot be undone.",
                pos = {w/2, 4},
                xalign = TEXT_ALIGN_CENTER,
                font = "nadmin_derma",
                color = nadmin:TextColor(nadmin.colors.gui.theme)
            })
        end
        panel:MakePopup()

        local w = panel:GetWide()/2 - 6
        local yes = nadmin.vgui:DButton({4, 34}, {w, 28}, panel)
        yes:SetText("Yes, delete " .. editRank.title)
        yes:SetColor(nadmin.colors.gui.red)
        yes:SetIcon("icon16/bin_closed.png")
        function yes:DoClick()
            net.Start("nadmin_updateRank")
                net.WriteString("Delete")
                net.WriteTable(editRank)
                net.WriteString(oid)
            net.SendToServer()

            blur:Remove()
            nadmin.menu:Open("ranks", {id = oid})
            timer.Simple(1, function()
                nadmin.menu:Open("ranks", {id = oid})
            end)
        end

        local no = nadmin.vgui:DButton({w + 8, 34}, {w, 28}, panel)
        no:SetText("No, keep " .. editRank.title)
        function no:DoClick()
            blur:Remove()
            nadmin.menu:Open("ranks", {id = oid})
        end
    end

    nadmin.menu:RegisterTab({
        title = "Ranks",
        sort = 1,
        content = function(parent, data)
            if not LocalPlayer():HasPerm("ranks") then
                local text = nadmin.vgui:DLabel(nil, "You don't have permission to view the ranks tab.", parent)
                text:Center()
                return
            end

            local w = parent:GetWide()
            local h = parent:GetTall()

            local rankSelect = nadmin.vgui:DScrollPanel({0, 0}, {w/5, h}, parent)
            rankSelect:GetCanvas():DockPadding(0, 0, 0, 4)

            local edit = nadmin.vgui:DPanel({rankSelect:GetWide() + 4, 4}, {w - rankSelect:GetWide() - 8, h - 8}, parent)
            function edit:Paint(w, h) end -- This shouldn't be visible

            local function drawInfo(selectedRank)
                rankSelect:Clear()
                edit:Clear()

                if not LocalPlayer():HasPerm("ranks") then
                    local text = nadmin.vgui:DLabel(nil, "You don't have permission to view the ranks tab.", edit)
                    text:Center()
                    return
                end

                local w = edit:GetWide() - 8
                local h = 32

                local myRank = LocalPlayer():GetRank()

                local editRank = nil
                local oid = nil
                local errors = {}

                local ranks = {}
                for i, rank in pairs(nadmin.ranks) do
                    if myRank.immunity > rank.immunity or (myRank.ownerRank or myRank.immunity >= nadmin.immunity.owner) then
                        table.insert(ranks, rank)
                    end
                end
                table.sort(ranks, function(a, b) return a.immunity > b.immunity end)

                if isstring(selectedRank) and istable(nadmin.ranks[selectedRank]) then
                    editRank = table.Copy(nadmin.ranks[selectedRank])
                    oid = editRank.id
                end

                local newRank = nadmin.vgui:DButton(nil, {w, h}, rankSelect)
                newRank:Dock(TOP)
                newRank:DockMargin(0, 4, 4, 0)
                newRank:SetText("New Rank")
                function newRank:DoClick()
                    nadmin.menu:Close()

                    createRank(ranks, oid)
                end

                local div = nadmin.vgui:DPanel(nil, {w, 4}, rankSelect)
                div:Dock(TOP)
                div:DockMargin(0, 4, 4, 0)
                div:SetColor(nadmin:BrightenColor(div:GetColor(), 25))

                for i, rank in ipairs(ranks) do
                    local sel = nadmin.vgui:DButton(nil, {w, h}, rankSelect)
                    sel:Dock(TOP)
                    sel:DockMargin(0, 4, 4, 0)
                    sel:SetText(rank.title)
                    sel.id = rank.id
                    local icon = Material(rank.icon)
                    function sel:Paint(w, h)
                        local boxcol = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                        local textcol = rank.color

                        if oid == rank.id then
                            boxcol = nadmin:BrightenColor(rank.color, nadmin:Ternary(self:IsHovered(), 25, 0))
                            textcol = nadmin:TextColor(boxcol)
                        elseif self:IsHovered() then
                            boxcol = textcol
                            textcol = nadmin:TextColor(boxcol)
                        end

                        draw.RoundedBox(0, 0, 0, w, h, boxcol)

                        surface.SetFont(self:GetFont())
                        local wid = surface.GetTextSize(rank.title)
                        local size = h - 8 + wid

                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(icon)
                        surface.DrawTexturedRect(w/2 - size/2, h/2-(h-12)/2, h-12, h-12)

                        draw.Text({
                            text = rank.title,
                            font = self:GetFont(),
                            pos = {w/2 - size/2 + h-8, h/2},
                            yalign = TEXT_ALIGN_CENTER,
                            color = textcol
                        })
                    end
                    function sel:DoClick()
                        drawInfo(self.id)
                        if IsValid(nadmin.menu.members) then
                            nadmin.menu.members.text = nil
                        end
                    end
                end

                local entry = Material("icon16/cog.png")
                local basicTitle = nadmin.vgui:DPanel({0, 0}, {edit:GetWide()/2 - 2, 30}, edit)
                basicTitle:SetColor(nadmin.colors.gui.theme)
                basicTitle.normalPaint = basicTitle.Paint
                function basicTitle:Paint(w, h)
                    self:normalPaint(w, h)

                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(entry)
                    surface.DrawTexturedRect(6, 6, 16, 16)

                    draw.Text({
                        text = "Configuration",
                        font = "nadmin_derma",
                        pos = {24, 14},
                        yalign = TEXT_ALIGN_CENTER,
                        color = nadmin:TextColor(nadmin.colors.gui.theme)
                    })

                    draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                end

                local basic = nadmin.vgui:DScrollPanel({0, 30}, {basicTitle:GetWide(), edit:GetTall() * (2/3) - basicTitle:GetTall()}, edit)
                basic:GetCanvas():DockPadding(0, 0, 0, 4)

                local user = Material("icon16/user.png")
                local membersTitle = nadmin.vgui:DPanel({0, basicTitle:GetTall() + basic:GetTall() + 4}, {basic:GetWide(), 30}, edit)
                membersTitle.normalPaint = membersTitle.Paint
                function membersTitle:Paint(w, h)
                    self:normalPaint(w, h)

                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(user)
                    surface.DrawTexturedRect(6, 6, 16, 16)

                    draw.Text({
                        text = "Members",
                        font = "nadmin_derma",
                        pos = {24, 14},
                        yalign = TEXT_ALIGN_CENTER,
                        color = nadmin:TextColor(nadmin.colors.gui.theme)
                    })

                    draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                end

                local size = {membersTitle:GetTall() - 10, membersTitle:GetTall() - 10}
                local memberAdd = nadmin.vgui:DButton({membersTitle:GetWide() - size[1] - 4, 4}, size, membersTitle)
                memberAdd:SetIcon("icon16/user_add.png")
                memberAdd:SetToolTip("Add Player")
                memberAdd:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                function memberAdd:DoClick()
                    if not istable(editRank) then return end
                    nadmin.menu:Close()

                    addMember(editRank, oid)
                end

                nadmin.menu.members = nadmin.vgui:DScrollPanel({0, basicTitle:GetTall() + basic:GetTall() + membersTitle:GetTall() + 4}, {edit:GetWide()/2 - 2, edit:GetTall() - basic:GetTall() - basicTitle:GetTall() - membersTitle:GetTall() - 4}, edit)
                nadmin.menu.members.text = "Please select a rank to see the members section."
                nadmin.menu.members.normalPaint = nadmin.menu.members.Paint
                function nadmin.menu.members:Paint(w, h)
                    self:normalPaint(w, h)

                    if isstring(self.text) then
                        draw.Text({
                            text = self.text,
                            font = "nadmin_derma",
                            pos = {w/2, h/2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end
                end

                local key = Material("icon16/key.png")
                local permsTitle = nadmin.vgui:DPanel({basicTitle:GetWide() + 4, 0}, {edit:GetWide() - basicTitle:GetWide() - 4, 30}, edit)
                permsTitle.normalPaint = permsTitle.Paint
                function permsTitle:Paint(w, h)
                    self:normalPaint(w, h)

                    surface.SetDrawColor(255, 255, 255)
                    surface.SetMaterial(key)
                    surface.DrawTexturedRect(6, 6, 16, 16)

                    draw.Text({
                        text = "Permissions",
                        font = "nadmin_derma",
                        pos = {24, 14},
                        yalign = TEXT_ALIGN_CENTER,
                        color = nadmin:TextColor(nadmin.colors.gui.theme)
                    })

                    draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                end

                local perms = nadmin.vgui:DScrollPanel({basicTitle:GetWide() + 4, permsTitle:GetTall()}, {permsTitle:GetWide(), edit:GetTall() - permsTitle:GetTall()}, edit)

                -- Don't do anything else if the rank isn't selected
                -- if not istable(editRank) then return end
                local owner = false
                if istable(editRank) then
                    owner = editRank.ownerRank or editRank.immunity >= nadmin.immunity.owner
                end

                -- Basic rank info
                w = basic:GetWide() - basic:GetVBar():GetWide()
                h = basic:GetTall()

                -- Delete button
                local deleteRank = nadmin.vgui:DButton(nil, {w - 8, 28}, basic)
                deleteRank:Dock(TOP)
                deleteRank:DockMargin(4, 4, 4, 0)
                deleteRank:SetIcon("icon16/bin_closed.png")
                deleteRank:SetColor(nadmin.colors.gui.red)
                if istable(editRank) then
                    deleteRank:SetText("Delete " .. editRank.title)
                else
                    deleteRank:SetText("Delete")
                    deleteRank:SetMouseInputEnabled(false)
                end
                function deleteRank:DoClick()
                    if not istable(editRank) then return end
                    nadmin.menu:Close()

                    delRank(editRank, oid)
                end

                -- Save button
                local saveRank = nadmin.vgui:DButton(nil, {w - 8, 28}, basic)
                saveRank:Dock(TOP)
                saveRank:DockMargin(4, 4, 4, 0)
                saveRank:SetIcon("icon16/disk.png")
                if istable(editRank) then
                    saveRank:SetText("Save " .. editRank.title)
                else
                    saveRank:SetText("Save")
                    saveRank:SetMouseInputEnabled(false)
                end
                function saveRank:DoClick()
                    if not istable(editRank) then return end
                    net.Start("nadmin_updateRank")
                        net.WriteString("Update")
                        net.WriteTable(editRank)
                        net.WriteString(oid)
                    net.SendToServer()
                    timer.Simple(1, function()
                        drawInfo(editRank.id)
                    end)
                end

                -- Information beyond this point
                local id_edit = nadmin.vgui:DPanel(nil, {w - 8, 28}, basic)
                id_edit:Dock(TOP)
                id_edit:DockMargin(4, 4, 4, 0)

                local idText = nadmin.vgui:DLabel(nil, "ID:", id_edit)

                local id = nadmin.vgui:DTextEntry({idText:GetWide() + 4, 0}, {w - idText:GetWide() - 12, idText:GetTall()}, id_edit)
                id:SetUpdateOnType(true)
                id:SetPlaceholderText("ID")
                function id:ErrorCondition()
                    local txt = string.Trim(self:GetText())
                    if txt == "" then return true end

                    local rankIDs = {}
                    for i, rank in pairs(nadmin.ranks) do
                        if rank.id == oid then continue end
                        table.insert(rankIDs, rank.id)
                    end

                    return table.HasValue(rankIDs, txt)
                end

                if istable(editRank) then id:SetText(editRank.id)
                else id:SetMouseInputEnabled(false) id:SetText("Please select a rank.") end

                function id:OnValueChange(val)
                    if not self:GetErrored() then editRank.id = val end
                end

                local title_edit = nadmin.vgui:DPanel(nil, {w - 8, 28}, basic)
                title_edit:Dock(TOP)
                title_edit:DockMargin(4, 4, 4, 0)

                local titleText = nadmin.vgui:DLabel(nil, "Title:", title_edit)

                local title = nadmin.vgui:DTextEntry({titleText:GetWide() + 4, 0}, {w - titleText:GetWide() - 12, titleText:GetTall()}, title_edit)
                title:SetUpdateOnType(true)
                title:SetPlaceholderText("Title")
                function title:ErrorCondition()
                    return string.Trim(self:GetText()) == ""
                end

                if istable(editRank) then title:SetText(editRank.title)
                else title:SetMouseInputEnabled(false) title:SetText("Please select a rank.") end

                function title:OnValueChange(val)
                    if not self:GetErrored() then editRank.title = val end
                end

                if not owner then
                    local im_edit = nadmin.vgui:DPanel(nil, {w - 8, 28}, basic)
                    im_edit:Dock(TOP)
                    im_edit:DockMargin(4, 4, 4, 0)

                    local immunityText = nadmin.vgui:DLabel(nil, "Immunity:", im_edit)

                    local immunity = nadmin.vgui:DTextEntry({immunityText:GetWide() + 4, 0}, {w - immunityText:GetWide() - 12, immunityText:GetTall()}, im_edit)
                    immunity:SetUpdateOnType(true)
                    immunity:SetPlaceholderText("Immunity")
                    immunity:SetNumeric(true)

                    function immunity:ErrorCondition()
                        local val = tonumber(string.Trim(self:GetText()))
                        if type(val) ~= "number" then return true end
                        return (val >= myRank.immunity) or (val < 0)
                    end

                    if istable(editRank) then immunity:SetText(editRank.immunity)
                    else immunity:SetMouseInputEnabled(false) immunity:SetText("Please select a rank.") end

                    function immunity:OnValueChange(val)
                        if not self:GetErrored() then editRank.immunity = tonumber(string.Trim(val)) end
                    end
                end

                local icon_edit = nadmin.vgui:DPanel(nil, {w - 8, 28}, basic)
                icon_edit:Dock(TOP)
                icon_edit:DockMargin(4, 4, 4, 0)

                local iconText = nadmin.vgui:DLabel(nil, "Icon:", icon_edit)

                local icon = vgui.Create("DImage", icon_edit)
                icon:SetPos(iconText:GetWide() + 4, 4)
                icon:SetSize(iconText:GetTall() - 8, iconText:GetTall() - 8)
                if istable(editRank) then
                    icon:SetImage(editRank.icon)
                else
                    icon:SetImage("icon16/user.png")
                end

                local iconSearch = nadmin.vgui:DTextEntry({iconText:GetWide() + icon:GetWide() + 12, 0}, {w - iconText:GetWide() - icon:GetWide() - 16, iconText:GetTall()}, icon_edit)
                iconSearch:SetPlaceholderText("Search...")
                if not istable(editRank) then
                    iconSearch:SetMouseInputEnabled(false)
                    iconSearch:SetText("Please select a rank.")
                end

                local iconBrowser = nadmin.vgui:DScrollPanel(nil, {w - 8, h/3}, basic)
                iconBrowser:Dock(TOP)
                iconBrowser:DockMargin(4, 4, 4, 0)
                iconBrowser:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                local vbar = iconBrowser:GetVBar()

                -- Optimization function: creates 20 icons a frame
                local function drawIcons(search)
                    iconBrowser:Clear()
                    if IsValid(nadmin.temp_panel) then nadmin.temp_panel:Remove() end
                    if isstring(search) then search = string.lower(search) end

                    local ix = 4
                    local iy = 4
                    local index = 0
                    local keys = table.GetKeys(nadmin.icons)
                    table.sort(keys, function(a, b) return a < b end)
                    nadmin.temp_panel = vgui.Create("DPanel")
                    function nadmin.temp_panel:Paint()
                        local i = 0
                        local maxi = 50
                        while index < #keys and i < maxi do
                            if not IsValid(iconBrowser) then return end

                            i = i + 1
                            index = index + 1

                            if isstring(search) and not string.find(string.lower(keys[index]), search) then continue end

                            local iconPath = nadmin.icons[keys[index]]

                            local btn = nadmin.vgui:DButton({ix, iy}, {24, 24}, iconBrowser)
                            btn.n_position = {ix, iy}
                            btn:SetToolTip(keys[index])
                            btn:SetIcon(iconPath)
                            btn:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                            if not istable(editRank) then
                                btn:SetMouseInputEnabled(false)
                            end

                            function btn:RenderCondition()
                                return (self.n_position[2] >= vbar:GetScroll() - self:GetTall() and self.n_position[2] <= vbar:GetScroll() + iconBrowser:GetTall())
                            end

                            btn.normalPaint = btn.Paint
                            function btn:Paint(w, h)
                                self:normalPaint(w, h)

                                if istable(editRank) and editRank.icon == iconPath then
                                    self:SetColor(nadmin.colors.gui.blue)
                                else
                                    if self:IsMouseInputEnabled() then
                                        self:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                                    else
                                        self:SetColor(nadmin.colors.gui.theme)
                                    end
                                end
                            end
                            function btn:DoClick()
                                editRank.icon = iconPath
                                icon:SetImage(iconPath)
                            end

                            if ix + btn:GetWide() >= w - btn:GetWide() - vbar:GetWide() - 16 then
                                ix = 4
                                iy = iy + btn:GetTall() + 4
                            else
                                ix = ix + btn:GetWide() + 4
                            end

                            if index == #keys then
                                self:Remove()
                                break
                            end
                        end
                    end
                end

                function iconSearch:OnChange()
                    drawIcons(string.Trim(self:GetText()))
                end

                drawIcons()

                local display = nadmin.vgui:DPanel(nil, {w - 8, 24}, basic)
                display:Dock(TOP)
                display:DockMargin(4, 4, 4, 0)

                local colorText = nadmin.vgui:DLabel(nil, "Color:", display)

                local colorDisplay = nadmin.vgui:DLabel({colorText:GetWide() + 8, 0}, "", display)
                colorDisplay:SetSize(w - colorText:GetWide() - 4, display:GetTall())
                function colorDisplay:Paint()
                    if istable(editRank) then
                        self:SetTextColor(editRank.color)
                    else
                        self:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                    end
                    self:SetText(LocalPlayer():Nick())
                end

                local color = nadmin.vgui:DColorMixer(nil, {w - 8, h/4}, basic)
                color:Dock(TOP)
                color:DockMargin(4, 0, 4, 0)

                if istable(editRank) then
                    color:SetColor(editRank.color)
                else
                    color:SetColor(nadmin:TextColor(nadmin.colors.gui.theme))
                end

                function color:ValueChanged(col)
                    if istable(editRank) then
                        editRank.color = Color(col.r, col.g, col.b)
                    end
                end

                if not owner then
                    local ap = nadmin.vgui:DPanel(nil, {w - 8, 0}, basic)
                    ap:Dock(TOP)
                    ap:DockMargin(4, 4, 4, 0)

                    local enabled = istable(editRank) and isbool(editRank.autoPromote.enabled) and editRank.autoPromote.enabled
                    if enabled then
                        ap:SetTall(96)
                    else
                        ap:SetTall(28)
                    end

                    function ap:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                        draw.RoundedBox(0, 0, 0, w, 28, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                        draw.Text({
                            text = "Auto Promote",
                            font = "nadmin_derma",
                            pos = {w/2, 14},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end

                    local enableAP = nadmin.vgui:DCheckBox({4, 4}, {ap:GetWide()/4, 20}, ap)
                    enableAP:SetText("Enabled")
                    enableAP:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))

                    if istable(editRank) and isbool(editRank.autoPromote.enabled) then
                        enableAP:SetChecked(editRank.autoPromote.enabled)
                    else
                        enableAP:SetMouseInputEnabled(false)
                    end

                    function enableAP:OnChecked(checked)
                        if istable(editRank) then
                            editRank.autoPromote.enabled = checked
                            if checked then
                                ap:SetTall(96)
                            else
                                ap:SetTall(28)
                            end
                            basic:ScrollToChild(self)
                        end
                    end

                    local apToText = nadmin.vgui:DLabel({4, 32}, "To:", ap)
                    apToText:SetTall(28)

                    local apTo = nadmin.vgui:DComboBox({apToText:GetWide() + 8, 32}, {w - apToText:GetWide() - basic:GetVBar():GetWide() - 12, apToText:GetTall()}, ap)
                    apTo:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                    apTo:SetSortItems(false)
                    if istable(editRank) then
                        apTo:SetValue("Select a rank...")
                        for i, rank in ipairs(ranks) do
                            if rank.id == editRank.id then continue end
                            apTo:AddChoice(rank.title .. " (" .. rank.id .. ")", rank.id, rank.id == editRank.autoPromote.rank)
                        end
                        function apTo:OnSelect(index, text, data)
                            editRank.autoPromote.rank = data
                        end
                    else
                        apTo:SetValue("Please select a rank.")
                    end

                    local afterText = nadmin.vgui:DLabel({4, 64}, "After:", ap)
                    afterText:SetTall(28)

                    local after = nadmin.vgui:DTextEntry({afterText:GetWide() + 8, 64}, {w - afterText:GetWide() - basic:GetVBar():GetWide() - 12, afterText:GetTall()}, ap)
                    after:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                    after:SetPlaceholderText("Playtime needed")

                    if istable(editRank) and editRank.autoPromote.when > 0 then
                        after:SetText(nadmin:TimeToString(editRank.autoPromote.when))
                    end

                    function after:ErrorCondition()
                        return not isnumber(nadmin:ParseTime(self:GetText()))
                    end

                    after.normalPaint = after.Paint
                    function after:Paint(w, h)
                        self:normalPaint(w, h)

                        if isnumber(nadmin:ParseTime(string.Trim(self:GetText()))) then
                            surface.SetFont(self:GetFont())
                            local wid = surface.GetTextSize(self:GetText())

                            draw.Text({
                                text = "(" .. nadmin:TimeToString(nadmin:ParseTime(string.Trim(self:GetText())), true) .. ")",
                                font = self:GetFont(),
                                pos = {wid + 8, h/2},
                                yalign = TEXT_ALIGN_CENTER,
                                color = nadmin:BrightenColor(nadmin.colors.gui.theme, 50)
                            })
                        end

                    end
                    function after:OnChange()
                        if not istable(editRank) then return end
                        local time = nadmin:ParseTime(self:GetText())
                        if isnumber(time) then
                            editRank.autoPromote.when = time
                        end
                    end
                end

                -- Members module
                if istable(editRank) then
                    nadmin.menu.loading = vgui.Create("DPanel", nadmin.menu.members)
                    nadmin.menu.loading:SetSize(nadmin.menu.members:GetWide(), nadmin.menu.members:GetTall())
                    nadmin.menu.loading.rank = editRank.id
                    function nadmin.menu.loading:Paint(w, h)
                        draw.Circle(w/2, h/2, 32, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                        draw.Circle(w/2, h/2, 32, 360, 270, (SysTime() % 360) * 180, nadmin:TextColor(nadmin.colors.gui.theme))
                        draw.Circle(w/2, h/2, 28, 360, 360, 0, nadmin.colors.gui.theme)
                    end

                    net.Start("nadmin_request_members")
                        net.WriteString(editRank.id)
                    net.SendToServer()
                end

                -- Perms module
                w = perms:GetWide() - perms:GetVBar():GetWide()
                h = perms:GetTall()

                local can = Material("icon16/accept.png")
                local force = Material("icon16/shield.png")
                local function drawPerms(categ)
                    perms:Clear()
                    local categories = {"Commands", "Entities", "NPCs", "Permissions", "Tabs", "Tools", "Vehicles", "Weapons"}
                    for i, cat in ipairs(categories) do
                        local category = nadmin.vgui:DPanel(nil, {w - 8, 32}, perms)
                        category:Dock(TOP)
                        category:DockMargin(4, 4, 4, 0)
                        category:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                        local sel = nadmin.vgui:DButton(nil, {w - 8, 32}, category)
                        sel:Dock(TOP)
                        sel:DockMargin(0, 0, 0, 0)
                        sel:SetText(cat)
                        sel.normalPaint = sel.Paint
                        function sel:Paint(w, h)
                            if category:GetTall() > 32 then
                                self:SetColor(nadmin.colors.gui.blue)
                            else
                                self:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                            end

                            self:normalPaint(w, h)
                        end
                        function sel:DoClick()
                            if category:GetTall() == 32 then
                                category:SizeTo(-1, category.expanded, 0.1)
                            else
                                category:SizeTo(-1, 32, 0.1)
                            end
                        end

                        local tbl = {}
                        if cat == "Commands" then
                            tbl = table.Copy(nadmin.commands)
                        elseif cat == "Entities" then
                            tbl = table.Copy(nadmin.entities)
                        elseif cat == "NPCs" then
                            tbl = table.Copy(nadmin.npcs)
                        elseif cat == "Permissions" then
                            tbl = table.Copy(nadmin.perms)
                        elseif cat == "Tabs" then
                            tbl = table.Copy(nadmin.menu.tabs)
                        elseif cat == "Tools" then
                            tbl = table.Copy(nadmin.tools)
                        elseif cat == "Vehicles" then
                            tbl = table.Copy(nadmin.vehicles)
                        elseif cat == "Weapons" then
                            tbl = table.Copy(nadmin.weapons)
                        end

                        -- These are for non-sequential tables (should only be props (if added), entities, npcs, tools, vehicles, and weapons)
                        local isForced = istable(editRank) and (editRank.ownerRank or editRank.immunity >= nadmin.immunity.owner)
                        if table.IsSequential(tbl) and type(tbl[1]) ~= "table" then
                            for x, obj in ipairs(tbl) do
                                local btn = nadmin.vgui:DButton(nil, {w - 16, 28}, category)
                                btn:Dock(TOP)
                                btn:DockMargin(4, 4, 4, 0)
                                btn:SetText(obj)
                                btn:SetTextAlign(TEXT_ALIGN_LEFT)
                                btn:SetColor(nadmin.colors.gui.theme)

                                if istable(editRank) then
                                    if isForced then
                                        btn:SetToolTip("Can spawn (enforced by server)")
                                    else
                                        btn:SetToolTip(table.HasValue(editRank.restrictions, obj) and "Can't spawn" or "Can spawn")
                                    end
                                else
                                    btn:SetToolTip("Please select a rank.")
                                end

                                if isForced then
                                    btn:SetIcon("icon16/shield.png")
                                else
                                    btn:ShowIcon(true)
                                    if istable(editRank) then
                                        if not table.HasValue(editRank.restrictions, obj) then
                                            btn:SetIcon("icon16/accept.png")
                                        end
                                    end
                                end

                                function btn:RenderCondition() return not (category:GetTall() ~= category.expanded and x > 20) end

                                function btn:DoClick()
                                    if not istable(editRank) then return end

                                    if isForced then return end

                                    if table.HasValue(editRank.restrictions, obj) then
                                        for y, r in ipairs(editRank.restrictions) do
                                            if r == obj then
                                                table.remove(editRank.restrictions, y)
                                                self:SetToolTip("Can spawn")
                                                self:SetIcon("icon16/accept.png")
                                                break
                                            end
                                        end
                                    else
                                        table.insert(editRank.restrictions, obj)
                                        self:SetToolTip("Can't spawn")
                                        self:RemoveIcon(true)
                                    end
                                end
                            end
                        else
                            if table.IsSequential(tbl) then -- This should be the tabs section (will be ported to table below at some point)
                                for x, obj in ipairs(tbl) do
                                    local btn = nadmin.vgui:DButton(nil, {w - 16, 28}, category)
                                    btn:Dock(TOP)
                                    btn:DockMargin(4, 4, 4, 0)
                                    btn:SetText(obj.title)
                                    btn:SetColor(nadmin.colors.gui.theme)
                                    btn:SetTextAlign(TEXT_ALIGN_LEFT)

                                    local enforced = isForced
                                    if not isForced then
                                        enforced = isbool(nadmin.forcedPrivs[obj.id]) and nadmin.forcedPrivs[obj.id]
                                    end

                                    if istable(editRank) then
                                        if enforced then
                                            btn:SetToolTip("Can use (enforced by server)")
                                        else
                                            btn:SetToolTip(table.HasValue(editRank.privileges, obj.id) and "Can use" or "Can't use")
                                        end
                                    else
                                        btn:SetToolTip("Please select a rank.")
                                    end

                                    if enforced then
                                        btn:SetIcon("icon16/shield.png")
                                    else
                                        btn:ShowIcon(true)
                                        if istable(editRank) then
                                            if table.HasValue(editRank.privileges, obj.id) then
                                                btn:SetIcon("icon16/accept.png")
                                            end
                                        end
                                    end

                                    function btn:RenderCondition() return not (category:GetTall() ~= category.expanded and x > 20) end

                                    function btn:DoClick()
                                        if not istable(editRank) then return end

                                        if enforced then return end

                                        if table.HasValue(editRank.privileges, obj.id) then
                                            for y, r in ipairs(editRank.privileges) do
                                                if r == obj.id then
                                                    table.remove(editRank.privileges, y)
                                                    self:SetToolTip("Can't use")
                                                    self:RemoveIcon(true)
                                                    break
                                                end
                                            end
                                        else
                                            table.insert(editRank.privileges, obj.id)
                                            self:SetToolTip("Can use")
                                            self:SetIcon("icon16/accept.png")
                                        end
                                    end
                                end
                            else -- This is typically commands here
                                local help = Material("icon16/help.png")

                                local x = 0
                                local hasCat = false
                                for _, obj in pairs(tbl) do
                                    if isstring(obj.category) then
                                        hasCat = true
                                        break
                                    end
                                    x = x + 1

                                    local btn = nadmin.vgui:DButton(nil, {w - 16, 28}, category)
                                    btn:Dock(TOP)
                                    btn:DockMargin(4, 4, 4, 0)
                                    btn:SetText(obj.title)
                                    btn:SetColor(nadmin.colors.gui.theme)
                                    btn:SetTextAlign(TEXT_ALIGN_LEFT)

                                    local enforced = isForced
                                    if not isForced then
                                        enforced = isbool(nadmin.forcedPrivs[obj.id]) and nadmin.forcedPrivs[obj.id]
                                    end

                                    if istable(editRank) then
                                        if enforced then
                                            btn:SetToolTip("Can use (enforced by server)")
                                        else
                                            btn:SetToolTip(table.HasValue(editRank.privileges, obj.title) and "Can use" or "Can't use")
                                        end
                                    else
                                        btn:SetToolTip("Please select a rank.")
                                    end

                                    if enforced then
                                        btn:SetIcon("icon16/shield.png")
                                    else
                                        btn:ShowIcon(true)
                                        if istable(editRank) then
                                            if table.HasValue(editRank.privileges, obj.id) then
                                                btn:SetIcon("icon16/accept.png")
                                            end
                                        end
                                    end

                                    function btn:DoClick()
                                        if not istable(editRank) then return end

                                        if enforced then return end

                                        if table.HasValue(editRank.privileges, obj.id) then
                                            for y, r in ipairs(editRank.privileges) do
                                                if r == obj.id then
                                                    table.remove(editRank.privileges, y)
                                                    self:SetToolTip("Can't use")
                                                    self:RemoveIcon(true)
                                                    break
                                                end
                                            end
                                        else
                                            table.insert(editRank.privileges, obj.id)
                                            self:SetToolTip("Can use")
                                            self:SetIcon("icon16/accept.png")
                                        end
                                    end
                                end

                                if hasCat then
                                    local categories = {}
                                    local cmds = {}

                                    for id, obj in pairs(tbl) do
                                        if not table.HasValue(categories, obj.category) then
                                            table.insert(categories, obj.category)
                                        end
                                        if not table.HasValue(cmds, {title = obj.title, id = obj.id}) then
                                            table.insert(cmds, {title = obj.title, id = obj.id, category = obj.category, description = obj.description})
                                        end
                                    end

                                    table.sort(categories, function(a, b) return a < b end)
                                    table.sort(cmds, function(a, b) return a.title < b.title end)

                                    for x, c in ipairs(categories) do
                                        local back = nadmin.vgui:DPanel(nil, {w - 16, 28}, category)
                                        back:Dock(TOP)
                                        back:DockMargin(4, 4, 4, 0)
                                        back:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                                        function back:RenderCondition() return not (category:GetTall() ~= category.expanded and x > 20) end

                                        local sel = nadmin.vgui:DButton(nil, {w - 16, 28}, back)
                                        sel:Dock(TOP)
                                        sel:SetText(c)

                                        sel.normalPaint = sel.Paint
                                        function sel:Paint(w, h)
                                            if back:GetTall() > 32 then
                                                self:SetColor(nadmin:DarkenColor(nadmin.colors.gui.blue, 25))
                                            else
                                                self:SetColor(nadmin.colors.gui.theme)
                                            end

                                            self:normalPaint(w, h)
                                        end

                                        function sel:DoClick()
                                            if back:GetTall() == 28 then
                                                back:SizeTo(-1, back.expanded, 0.1, 0, -1, function()
                                                    category:InvalidateLayout(true)
                                                    category:SizeToChildren(false, true)
                                                    category:SetTall(category:GetTall() + 4)

                                                    category.expanded = category:GetTall()
                                                end)
                                            else
                                                back:SizeTo(-1, 28, 0.1, 0, -1, function()
                                                    category:InvalidateLayout(true)
                                                    category:SizeToChildren(false, true)
                                                    category:SetTall(category:GetTall() + 4)

                                                    category.expanded = category:GetTall()
                                                end)
                                            end
                                        end

                                        for y, cmd in ipairs(cmds) do
                                            if cmd.category ~= c then continue end

                                            local btn = nadmin.vgui:DButton(nil, {w - 24, 24}, back)
                                            btn:Dock(TOP)
                                            btn:DockMargin(4, 4, 4, 0)
                                            btn:SetText(cmd.title)
                                            btn:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                                            btn:SetTextAlign(TEXT_ALIGN_LEFT)

                                            local enforced = isForced
                                            if not isForced then
                                                enforced = isbool(nadmin.forcedPrivs[cmd.id]) and nadmin.forcedPrivs[cmd.id]
                                            end

                                            if istable(editRank) then
                                                if enforced then
                                                    btn:SetToolTip("Can use (enforced by server)")
                                                else
                                                    btn:SetToolTip(table.HasValue(editRank.privileges, cmd.id) and "Can use" or "Can't use")
                                                end
                                            else
                                                btn:SetToolTip("Please select a rank.")
                                            end

                                            if enforced then
                                                btn:SetIcon("icon16/shield.png")
                                            else
                                                btn:ShowIcon(true)
                                                if istable(editRank) then
                                                    if table.HasValue(editRank.privileges, cmd.id) then
                                                        btn:SetIcon("icon16/accept.png")
                                                    end
                                                end
                                            end

                                            function btn:RenderCondition() return not (back:GetTall() ~= back.expanded and y > 20) end

                                            function btn:DoClick()
                                                if not istable(editRank) then return end

                                                if enforced then return end

                                                if table.HasValue(editRank.privileges, cmd.id) then
                                                    for y, r in ipairs(editRank.privileges) do
                                                        if r == cmd.id then
                                                            table.remove(editRank.privileges, y)
                                                            self:SetToolTip("Can't use")
                                                            self:RemoveIcon(true)
                                                            break
                                                        end
                                                    end
                                                else
                                                    table.insert(editRank.privileges, cmd.id)
                                                    self:SetToolTip("Can use")
                                                    self:SetIcon("icon16/accept.png")
                                                end
                                            end

                                            if isstring(cmd.description) and cmd.description ~= "" then
                                                local desc = nadmin.vgui:DButton(nil, {btn:GetTall() - 8, btn:GetTall() - 8}, btn)
                                                desc:Dock(RIGHT)
                                                desc:DockMargin(4, 4, 4, 4)
                                                desc:SetToolTip(cmd.description)
                                                function desc:Paint(w, h)
                                                    if back:GetTall() ~= back.expanded and y > 20 then return end

                                                    surface.SetDrawColor(255, 255, 255)
                                                    surface.SetMaterial(help)
                                                    surface.DrawTexturedRect(0, 0, 16, 16)
                                                end
                                            end
                                        end

                                        back:InvalidateLayout(true)
                                        back:SizeToChildren(false, true)

                                        back.expanded = back:GetTall() + 4
                                        back:SetTall(28)
                                    end
                                end
                            end
                        end

                        category:InvalidateLayout(true)
                        category:SizeToChildren(false, true)

                        category.expanded = category:GetTall() + 4
                        if categ == cat then
                            category:SizeTo(-1, category.expanded, 0.1)
                        else
                            category:SetTall(32)
                        end
                    end
                end

                drawPerms()
            end

            if istable(data) then
                drawInfo(data.id)
            else
                drawInfo()
            end
        end
    })

    local function delUser(user, tRank)
        local name
        if user.nick == "" then
            name = user.steamID
        else
            name = user.nick
        end

        local blur = nadmin.vgui:CreateBlur()

        local panel = nadmin.vgui:DFrame(nil, {ScrW()/3, 66}, blur)
        panel:SetTitle("Delete data on " .. name)
        panel:Center()
        panel:MakePopup()

        local w = panel:GetWide()/2 - 6

        local yes = nadmin.vgui:DButton({4, 34}, {w, 28}, panel)
        yes:SetText("Yes, delete " .. name)
        yes:SetIcon("icon16/bin_closed.png")
        yes:SetColor(nadmin.colors.gui.red)

        function yes:DoClick()
            net.Start("nadmin_manage_member")
                net.WriteString("Erase")
                net.WriteString(user.steamID)
                net.WriteString(tRank.id)
            net.SendToServer()

            blur:Remove()
            nadmin.menu:Open("ranks", {id = tRank.id})
            timer.Simple(0.5, function()
                nadmin.menu:SetTab("ranks", {id = tRank.id})
            end)
        end

        local no = nadmin.vgui:DButton({w + 8, 34}, {w, 28}, panel)
        no:SetText("No, keep " .. user.nick)
        function no:DoClick()
            blur:Remove()
            nadmin.menu:Open("ranks", {id = tRank.id})
        end
    end

    local function moveUser(user)
        local name
        if user.nick == "" then
            name = user.steamID
        else
            name = user.nick
        end

        local blur = nadmin.vgui:CreateBlur()

        local panel = nadmin.vgui:DFrame(nil, {ScrW()/4, 0}, blur)
        panel:SetTitle("Move " .. name)
        panel:MakePopup()

        local myRank = LocalPlayer():GetRank()
        local tRank = nadmin:FindRank(nadmin.menu.loading.rank)

        local ranks = {}
        for i, rank in pairs(nadmin.ranks) do
            if rank.id == tRank.id then continue end
            if myRank.immunity > rank.immunity or LocalPlayer():IsOwner() then
                table.insert(ranks, rank)
            end
        end
        table.sort(ranks, function(a, b) return a.immunity > b.immunity end)

        for i, rank in ipairs(ranks) do
            local sel = nadmin.vgui:DButton(nil, {panel:GetWide() - 8, 28}, panel)
            sel:Dock(TOP)
            sel:DockMargin(4, 0, 4, 4)
            sel:SetText(rank.title)
            sel:SetIcon(rank.icon)

            sel.normalPaint = sel.Paint
            function sel:Paint(w, h)
                if self:IsHovered() then
                    self:SetColor(rank.color)
                else
                    self:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25), true)
                    self:SetTextColor(rank.color)
                end

                self:normalPaint(w, h)
            end
            function sel:DoClick()
                net.Start("nadmin_manage_member")
                    net.WriteString("Add")
                    net.WriteString(user.steamID)
                    net.WriteString(rank.id)
                net.SendToServer()

                blur:Remove()
                nadmin.menu:Open("ranks", {id = tRank.id})
            end
        end

        local cancel = nadmin.vgui:DButton(nil, {panel:GetWide() - 8, 28}, panel)
        cancel:Dock(TOP)
        cancel:DockMargin(4, 0, 4, 0)
        cancel:SetText("Cancel")
        function cancel:DoClick()
            blur:Remove()
            nadmin.menu:Open("ranks", {id = tRank.id})
        end

        panel:InvalidateLayout(true)
        panel:SizeToChildren(false, true)
        panel:SetTall(panel:GetTall() + 4)
        panel:Center()
    end

    net.Receive("nadmin_request_members", function()
        local can = net.ReadBool()
        local data = net.ReadTable()
        local rid = net.ReadString()

        if rid ~= nadmin.menu.loading.rank then return end --The rank changed

        table.sort(data, function(a, b) return a.nick < b.nick end)

        function nadmin.menu.loading:Paint() end

        if not can then
            nadmin.menu.members.text = "You weren't authed by the server."
        else
            nadmin.menu.members.text = nil
            if #data > 0 then
                local wid = nadmin.menu.members:GetWide() - 8

                local defRank = nadmin:DefaultRank()

                for i, user in ipairs(data) do
                    local line = nadmin.vgui:DPanel(nil, {wid, 32}, nadmin.menu.members)
                    line:Dock(TOP)
                    line:DockMargin(4, 4, 4, 0)
                    line.text = ""
                    if user.nick == "" then
                        line.text = user.steamID .. " (never joined)"
                    else
                        if #user.nick > 15 then
                            line.text = string.sub(user.nick, 1, 15) .. " ... (" .. user.steamID .. ")"
                        else
                            line.text = user.nick .. " (" .. user.steamID .. ")"
                        end
                    end

                    function line:Paint(w, h)
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                        draw.Text({
                            text = self.text,
                            font = "nadmin_derma",
                            pos = {4, h/2},
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:TextColor(nadmin.colors.gui.theme)
                        })
                    end

                    local tRank = nadmin:FindRank(nadmin.menu.loading.rank)
                    local bypass = tRank.ownerRank or tRank.immunity >= nadmin.immunity.owner
                    if not bypass then
                        if LocalPlayer():SteamID() == user.steamID then continue end
                    end

                    local btnSize = {line:GetTall() - 8, line:GetTall() - 8}
                    if LocalPlayer():HasPerm("erase_player_data") then
                        local deleteUser = nadmin.vgui:DButton(nil, btnSize, line)
                        deleteUser:Dock(RIGHT)
                        deleteUser:DockMargin(0, 4, 4, 4)
                        deleteUser:SetToolTip("Erase user data")
                        deleteUser:SetIcon("icon16/bin_closed.png")

                        deleteUser.normalPaint = deleteUser.Paint
                        function deleteUser:Paint(w, h)
                            if self:IsHovered() then
                                self:SetColor(nadmin.colors.gui.red)
                            else
                                self:SetColor(nadmin.colors.gui.theme)
                            end

                            self:normalPaint(w, h)
                        end

                        function deleteUser:DoClick()
                            nadmin.menu:Close()

                            delUser(user, tRank)
                        end
                    end

                    if nadmin.menu.loading.rank ~= defRank.id then
                        local remove = nadmin.vgui:DButton(nil, btnSize, line)
                        remove:Dock(RIGHT)
                        remove:DockMargin(0, 4, 4, 4)
                        remove:SetToolTip("Demote")
                        remove:SetIcon("icon16/user_delete.png")

                        remove.normalPaint = remove.Paint
                        function remove:Paint(w, h)
                            if self:IsHovered() then
                                self:SetColor(nadmin.colors.gui.red)
                            else
                                self:SetColor(nadmin.colors.gui.theme)
                            end

                            self:normalPaint(w, h)
                        end

                        function remove:DoClick()
                            net.Start("nadmin_manage_member")
                                net.WriteString("Remove")
                                net.WriteString(user.steamID)
                                net.WriteString(nadmin.menu.loading.rank)
                            net.SendToServer()

                            timer.Simple(0.5, function()
                                nadmin.menu:SetTab("ranks", {id = nadmin.menu.loading.rank})
                            end)
                        end
                    end

                    local move = nadmin.vgui:DButton(nil, btnSize, line)
                    move:Dock(RIGHT)
                    move:DockMargin(0, 4, 4, 4)
                    move:SetToolTip("Move Rank")
                    move:SetIcon("icon16/user_go.png")
                    move:SetColor(nadmin.colors.gui.theme)
                    function move:DoClick()
                        nadmin.menu:Close()

                        moveUser(user, tRank)
                    end

                    local copy = nadmin.vgui:DButton(nil, btnSize, line)
                    copy:Dock(RIGHT)
                    copy:DockMargin(0, 4, 4, 4)
                    copy:SetToolTip("Copy")
                    copy:SetIcon("icon16/page_white_copy.png")
                    copy:SetColor(nadmin.colors.gui.theme)

                    function copy:DoClick()
                        local txt
                        if user.nick == "" then
                            txt = user.steamID .. " (never joined)"
                        else
                            txt = user.nick .. " (" .. user.steamID .. ")"
                        end
                        SetClipboardText(txt)
                        notification.AddLegacy("Copied to clipboard: " .. txt, NOTIFY_HINT, 3)
                        surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
                    end
                end

                local pad = vgui.Create("DPanel", nadmin.menu.members)
                pad:Dock(TOP)
                pad:DockMargin(4, 4, 4, 0)
                pad:SetTall(0)
                function pad:Paint() end
            else
                nadmin.menu.members.text = "There are no members in this rank."
            end
        end
    end)

    hook.Add("Initialize", "nadmin_add_right_click_perms", function()
        -- This way of adding right click spawn menu functionality could be considered hacky
        local oldDermaMenu = DermaMenu
        function DermaMenu(parentmenu, parent)
        	nadmin.spawnMenuRightClick = oldDermaMenu(parentmenu, parent)
            return nadmin.spawnMenuRightClick
        end

        local icon = vgui.GetControlTable("ContentIcon")
        icon.nadmin_oldInit = icon.Init
        function icon:Init()
            self:nadmin_oldInit()
            function self:DoRightClick()
                if isfunction(self.OpenMenu) then
                    self:OpenMenu(self)
                end
                if IsValid(nadmin.spawnMenuRightClick) and isstring(self:GetSpawnName()) then
                    if not LocalPlayer():HasPerm("manage_ranks") then return end

                    local name = self:GetSpawnName()
                    if not (table.HasValue(nadmin.entities, name) or table.HasValue(nadmin.npcs, name) or table.HasValue(nadmin.vehicles, name) or table.HasValue(nadmin.weapons, name)) then return end

                    local ranks = {}
                    local call_rank = LocalPlayer():GetRank()
                    for id, rank in pairs(nadmin.ranks) do
                        if rank.ownerRank or rank.immunity >= nadmin.immunity.owner then continue end
                        if rank.immunity >= call_rank.immunity then continue end
                        table.insert(ranks, {title = rank.title, id = rank.id, immunity = rank.immunity, restrictions = rank.restrictions, loadout = rank.loadout})
                    end
                    table.sort(ranks, function(a, b) return a.immunity < b.immunity end)

                    local orig = nadmin.spawnMenuRightClick

                    local sub = nadmin.spawnMenuRightClick:AddSubMenu("Restrict from rank")
                    for i, rank in ipairs(ranks) do
                        local line = sub:AddOption(rank.title, function()
                            net.Start("nadmin_restrict_perm")
                                net.WriteString("Restrict")
                                net.WriteString(rank.id)
                                net.WriteString(name)
                            net.SendToServer()
                        end)
                        if table.HasValue(rank.restrictions, name) then
                            line:SetIcon("icon16/lock.png")
                        else
                            line:SetIcon("icon16/lock_open.png")
                        end
                    end

                    if table.HasValue(nadmin.weapons, name) then
                        local ranks = {}
                        local call_rank = LocalPlayer():GetRank()
                        for id, rank in pairs(nadmin.ranks) do
                            if not call_rank.ownerRank or call_rank.immunity < nadmin.immunity.owner then
                                if rank.immunity >= call_rank.immunity then continue end
                            end
                            table.insert(ranks, {title = rank.title, id = rank.id, immunity = rank.immunity, restrictions = rank.restrictions, loadout = rank.loadout})
                        end
                        table.sort(ranks, function(a, b) return a.immunity < b.immunity end)

                        local sub = orig:AddSubMenu("Add to loadout")
                        for i, rank in ipairs(ranks) do
                            local line = sub:AddOption(rank.title, function()
                                net.Start("nadmin_restrict_perm")
                                    net.WriteString("Loadout")
                                    net.WriteString(rank.id)
                                    net.WriteString(name)
                                net.SendToServer()
                            end)
                            if table.HasValue(rank.loadout, name) then
                                line:SetIcon("icon16/accept.png")
                            end
                        end
                    end
                end
            end
        end
    end)
else
    net.Receive("nadmin_manage_member", function(len, ply)
        local action = net.ReadString()
        local member = net.ReadString()
        local dRank = net.ReadString()

        local can_manage = ply:HasPerm("manage_ranks")
        local can_erase  = ply:HasPerm("erase_player_data")

        member = string.match(member, nadmin.config.steamIDMatch)

        if not isstring(member) then
            nadmin:Notify(ply, nadmin.colors.red, "Unable to validate SteamID format.")
            return
        end

        local callRank = ply:GetRank()
        local bypass = callRank.ownerRank or callRank.immunity >= nadmin.immunity.owner

        if not bypass then
            if member == ply:SteamID() then
                nadmin:Notify(ply, nadmin.colors.red, "You can't rank yourself.")
                return
            end
        end

        local rank = nadmin:FindRank(dRank)
        if not istable(rank) then
            nadmin:Notify(ply, nadmin.colors.red, "Unable to get rank.")
            return
        end

        if not istable(nadmin.userdata[member]) then nadmin.userdata[member] = table.Copy(nadmin.defaults.userdata) end
        local data = nadmin.userdata[member]

        local targ = nadmin:FindPlayer(member)
        local target = targ[1]
        local targRank
        if type(targ[1]) == "Player" then
            targRank = targ[1]:GetRank()
            targ = targ[1]:Nick()
        elseif data.lastJoined.name ~= "" then
            targ = data.lastJoined.name
            targRank = nadmin:FindRank(data.rank)
        else
            targ = member
            targRank = nadmin:FindRank(data.rank)
        end

        if not bypass then
            if rank.immunity >= callRank.immunity then
                nadmin:Notify(ply, nadmin.colors.red, "You can't rank a person higher than or equal to yourself.")
                return
            end

            if targRank.immunity >= callRank.immunity then
                nadmin:Notify(ply, nadmin.colors.red, "You can't rank a player who's higher or equal to you in power.")
                return
            end
        end

        local myCol = nadmin:GetNameColor(ply)

        if action == "Add" and can_manage then
            data.rank = rank.id
            nadmin:SaveUserData(member)
            if type(target) == "Player" then target:SetRank(data.rank) end

            local tCol = nadmin.colors.red
            local r = nadmin:FindRank(data.rank)
            if istable(r) then tCol = r.color end

            nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has granted ", tCol, targ, nadmin.colors.white, " the rank ", rank.color, rank.title, nadmin.colors.white, ".")
        elseif action == "Remove" and can_manage then
            data.rank = nadmin:DefaultRank().id
            nadmin:SaveUserData(member)
            if type(target) == "Player" then target:SetRank(data.rank) end

            local tCol = nadmin.colors.red
            local r = nadmin:FindRank(data.rank)
            if istable(r) then tCol = r.color end

            nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has removed ", tCol, targ, nadmin.colors.white, " from ", rank.color, rank.title, nadmin.colors.white, ".")
        elseif action == "Erase" and can_erase then
            local tCol = nadmin.colors.red
            local r = nadmin:FindRank(data.rank)
            if istable(r) then tCol = r.color end
            
            nadmin:RemoveUserData(member)
            if type(target) == "Player" then
                target:CheckData()
                target:SetRank(nadmin:DefaultRank().id)
                target:SetPlayTime(0)
                target:SetLevel(1)
                nadmin.userdata[target:SteamID()].lastJoined.name = target:Nick()
                nadmin.userdata[target:SteamID()].lastJoined.when = os.time()
            end

            if targ ~= member then
                nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has erased all data on ", tCol, targ, nadmin.colors.white, " (", tCol, member, nadmin.colors.white, ").")
            else
                nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has erased all data on ", tCol, targ, nadmin.colors.white, ".")
            end
        else
            if not can_manage then
                nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            end
            if not can_erase then
                nadmin:Notify(ply, nadmin.colors.red, "You are not allowed to remove player data.")
            end
        end
    end)

    net.Receive("nadmin_restrict_perm", function(len, ply)
        local action = net.ReadString()
        local rID = net.ReadString()
        local item = net.ReadString()

        if not ply:HasPerm("manage_ranks") then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            return
        end

        local rank = nadmin:FindRank(rID)
        if not istable(rank) then
            nadmin:Notify(ply, nadmin.colors.red, "Invalid rank specified.")
            return
        end

        if action == "Restrict" then
            if rank.ownerRank or rank.immunity >= nadmin.immunity.owner then
                nadmin:Notify(ply, nadmin.colors.red, "You can't restrict from an owner rank.")
                return
            end
        end

        local call_rank = ply:GetRank()
        if action == "Restrict" and rank.immunity >= call_rank.immunity then
            nadmin:Notify(ply, nadmin.colors.red, "You can't restrict from a higher or equal rank.")
            return
        end

        if not (table.HasValue(nadmin.entities, item) or table.HasValue(nadmin.npcs, item) or table.HasValue(nadmin.vehicles, item) or table.HasValue(nadmin.weapons, item)) then
            nadmin:Notify(ply, nadmin.colors.red, "You can't restrict/loadout an invalid item.")
            return
        end

        local tbl
        if action == "Restrict" then
            tbl = rank.restrictions
        elseif action == "Loadout" then
            tbl = rank.loadout
        else
            nadmin:Notify(ply, nadmin.colors.red, "Invalid action given to the server.")
            return
        end

        -- Everything has been validated, lets remove it
        local inserted = false
        if table.HasValue(tbl, item) then
            for i, obj in ipairs(tbl) do
                if obj == item then
                    table.remove(tbl, i)
                    break
                end
            end
        else
            inserted = true
            table.insert(tbl, item)
        end

        -- Now save and update the ranks
        nadmin:SaveRanks()
        nadmin:SendRanksToClients()

        local myCol = nadmin:GetNameColor(ply)
        if action == "Restrict" then
            nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has ", (inserted and "restricted" or "unrestricted"), " ", nadmin.colors.red, item, nadmin.colors.white, " from ", rank.color, rank.title, nadmin.colors.white, ".")

            -- Since it was restricted, we want to strip them of the weapon
            if table.HasValue(tbl, item) then
                for i, ply in ipairs(player.GetHumans()) do
                    if ply:GetRank().id == rank.id then
                        if ply:HasWeapon(item) then ply:StripWeapon(item) end
                    end
                end
            end
        elseif action == "Loadout" then
            nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has ", (inserted and "added" or "removed"), " ", nadmin.colors.red, item, nadmin.colors.white, " ", (inserted and "to" or "from"), " ", rank.color, rank.title, nadmin.colors.white, " loadout.")
        end
    end)
    net.Receive("nadmin_request_members", function(len, ply)
        local id = net.ReadString()

        if not isstring(id) then return end -- Invalid message

        local data = {}
        local canView = false
        if ply:HasPerm("manage_ranks") then
            canView = true

            for steamid, user in pairs(nadmin.userdata) do
                if user.rank == id then
                    table.insert(data, {steamID = steamid, nick = user.lastJoined.name})
                end
            end
        end

        net.Start("nadmin_request_members")
            net.WriteBool(canView)
            net.WriteTable(data)
            net.WriteString(id)
        net.Send(ply)
    end)
    net.Receive("nadmin_updateRank", function(len, ply)
        local typ = net.ReadString()
        local tbl = net.ReadTable()
        local oid = net.ReadString()

        if not (isstring(typ) or istable(tbl) or isstring(oid)) then return end --The client didn't send a valid message

        if ply:HasPerm("manage_ranks") then
            local rank, err = nadmin:ValidateRank(tbl, oid, ply)
            if not istable(rank) then
                nadmin:Notify(ply, nadmin.colors.red, err)
                return
            end

            local applyRank = table.Copy(rank)

            local myCol = nadmin:GetNameColor(ply)

            if typ == "Update" then
                nadmin.ranks[oid] = nil -- Remove the original
                rank = nadmin:RegisterRank(rank)
                nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has updated rank ", rank.color, rank.title, nadmin.colors.white, ".")
            elseif typ == "Delete" then
                if istable(nadmin.ranks[oid]) then
                    local keys = table.GetKeys(nadmin.ranks)
                    if #keys > 1 then
                        local cr = ply:GetRank()
                        if cr.id ~= oid then
                            local r = table.Copy(nadmin.ranks[oid])
                            if r.immunity < cr.immunity then
                                nadmin.ranks[oid] = nil
                                nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has deleted rank ", r.color, r.title, nadmin.colors.white, ".")
                                applyRank = table.Copy(nadmin:DefaultRank())
                            else
                                nadmin:Notify(ply, nadmin.colors.red, "You cannot delete a rank better than or equal to yours.")
                                return
                            end
                        else
                            nadmin:Notify(ply, nadmin.colors.red, "You cannot delete your own rank.")
                            return
                        end
                    else
                        nadmin:Notify(ply, nadmin.colors.red, "There must be at least one rank on the server.")
                        return
                    end
                else
                    nadmin:Notify(ply, nadmin.colors.red, "You can't delete a rank that doesn't exist.")
                    return
                end
            elseif typ == "Create" then
                rank = nadmin:RegisterRank(rank)
                nadmin:Notify(myCol, ply:Nick(), nadmin.colors.white, " has created rank ", rank.color, rank.title, nadmin.colors.white, ".")
            end

            -- Send the updated ranks to the clients
            nadmin:SendRanksToClients()
            nadmin:SaveRanks()

            if typ == "Create" then return end -- No need to check players since no one will have this rank.

            for i, d in pairs(nadmin.userdata) do
                if d.rank == oid then
                    nadmin.userdata[i].rank = applyRank.id
                    local ply = nadmin:FindPlayer(i)
                    if type(ply[1]) == "Player" then ply[1]:SetRank(applyRank.id) end
                    nadmin:SaveUserData(i)
                end
            end
        else
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
        end
    end)
end

nadmin:RegisterPerm({
    title = "Manage Ranks"
})
nadmin:RegisterPerm({
    title = "Erase Player Data"
})
