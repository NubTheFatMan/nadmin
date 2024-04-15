if CLIENT then
    nadmin.rankTab = nadmin.rankTab or {}
    nadmin.rankTab.editor = nadmin.rankTab.editor or {}
    nadmin.rankTab.selectedRankId = nil

    nadmin.menu:RegisterTab({
        title = "Ranks 2.0",
        sort = 1,
        content = function(parent, data)
            local localRank = LocalPlayer():GetRank()

            local ranksTabManager = vgui.Create("NadminTabMenu", parent)
            ranksTabManager:SetPos(4, 4)
            ranksTabManager:SetSize(parent:GetWide() * 1/5, parent:GetTall() - 4)
            ranksTabManager:UseVerticalTabs(true)
            ranksTabManager:SetColor(nadmin.colors.gui.theme)
            ranksTabManager:GetContentPanel():SetVisible(false)

            local rankEditor = vgui.Create("DPanel", parent)
            rankEditor:SetPos(ranksTabManager:GetWide() + 4, 4)
            rankEditor:SetSize(parent:GetWide() - ranksTabManager:GetWide() - 4, parent:GetTall() - 4)
            function rankEditor:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, 4, 4, w - 4, h - 4, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end

            local rankPropertiesTabManager = vgui.Create("NadminTabMenu", rankEditor)
            rankPropertiesTabManager:SetPos(8, 8)
            rankPropertiesTabManager:SetSize(rankEditor:GetWide() - 12, rankEditor:GetTall() - 12)
            rankPropertiesTabManager:SetColor(nadmin.colors.gui.theme)
            rankPropertiesTabManager:SetTabColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 45))
            rankPropertiesTabManager:GetContentPanel():GetVBar():SetWide(0)
            rankPropertiesTabManager.NormalPaint = rankPropertiesTabManager.Paint
            function rankPropertiesTabManager:Paint(w, h)
                self:NormalPaint(w, h)
                draw.RoundedBox(0, 0, self.tabSizeH, w, 2, nadmin:BrightenColor(self.backgroundColor, -25))
            end

            local rankInformationTab = rankPropertiesTabManager:AddTab("Information", function(editor)
                local sidePadding = 196

                function editor:Paint(w, h)
                    draw.RoundedBox(0, sidePadding - 10, 0, 2, h, nadmin:BrightenColor(nadmin.colors.gui.theme, -25))
                    draw.RoundedBox(0, w - sidePadding + 8, 0, 2, h, nadmin:BrightenColor(nadmin.colors.gui.theme, -25))
                end

                local manageContainer = vgui.Create("DPanel", editor)
                function manageContainer:Paint() end
                manageContainer:Dock(TOP)
                manageContainer:DockMargin(sidePadding, 10, sidePadding, 0)
                manageContainer:SetTall(28)

                local saveRank = vgui.Create("NadminButton", manageContainer)
                saveRank:SetText("Create Rank")
                saveRank:SetIcon("icon16/disk.png")
                saveRank.baseWidth = 298
                saveRank.fullWidth = editor:GetWide() - (sidePadding * 2)
                saveRank:SetSize(saveRank.fullWidth, 28)
                nadmin.rankTab.editor.saveRankButton = saveRank

                function saveRank:BackgroundDraw(w, h)
                    -- Validate for errors and enable/disable button if details are valid
                    -- We could just offload validation on the server but I want to minimize
                    -- network traffic. So I validate here, if it's good, pass to the server
                    -- and double check it there.
                    local editor = nadmin.rankTab.editor
                    
                    local errored = false
                    if editor.titleEntry:ErrorCondition() then errored = true 
                    elseif editor.idEntry:ErrorCondition() then errored = true 
                    elseif editor.immunityEntry:ErrorCondition() then errored = true
                    else
                        local _, inheritedRank = editor.inheritFrom:GetSelected()
                        if not isstring(inheritedRank) and isstring(editor.inheritFrom.customDataValue) then 
                            inheritedRank = editor.inheritFrom.customDataValue
                        end
                        if isstring(inheritedRank) and not istable(nadmin.ranks[inheritedRank]) then 
                            errored = true
                            editor.inheritFrom:SetText(editor.inheritFrom:GetText() .. " [Invalid]")
                        end

                        if editor.selectedAccess >= localRank.access and editor.selectedAccess ~= editor.startedAccess then 
                            errored = true
                            editor.accessButtons[editor.selectedAccess + 1]:SetColor(nadmin.colors.gui.red)
                        end

                        if editor.autoPromotionToggle:GetChecked() then 
                            local _, promotionRank = editor.autoPromoteTo:GetSelected()
                            if not isstring(promotionRank) and isstring(editor.autoPromoteTo.customDataValue) then 
                                promotionRank = editor.autoPromoteTo.customDataValue
                            end
                            if isstring(promotionRank) and not istable(nadmin.ranks[promotionRank]) then 
                                errored = true
                                editor.autoPromoteTo:SetText(editor.autoPromoteTo:GetText() .. " [Invalid]")
                            end

                            if editor.autoPromoteAfter:ErrorCondition() then errored = true end
                        end
                    end

                    if errored and self:IsEnabled() then 
                        self:SetEnabled(false)
                    elseif not errored and not self:IsEnabled() then 
                        self:SetEnabled(true) 
                    end
                end
                function saveRank:DoClick() 
                    local editor = nadmin.rankTab.editor
                    local isEditingRank = isstring(editor.selectedRankId)

                    local newRank = {}
                    newRank.id = editor.idEntry:GetText()
                    newRank.title = editor.titleEntry:GetText()
                    newRank.access = editor.selectedAccess
                    newRank.immunity = tonumber(editor.immunityEntry:GetText())
                    newRank.color = editor.colorPicker:GetColor()
                    newRank.icon = editor.iconPreview:GetImage()

                    local _, inheritedRank = editor.inheritFrom:GetSelected()
                    if not isstring(inheritedRank) and isstring(editor.inheritFrom.customDataValue) then 
                        inheritedRank = editor.inheritFrom.customDataValue
                    end
                    if isstring(inheritedRank) and istable(nadmin.ranks[inheritedRank]) then 
                        newRank.inheritFrom = inheritedRank
                    end

                    if editor.autoPromotionToggle:GetChecked() then 
                        newRank.autoPromote = {enabled = true}
                        newRank.autoPromote.when = nadmin:ParseTime(editor.autoPromoteAfter:GetText())

                        local _, promotionRank = editor.autoPromoteTo:GetSelected()
                        if not isstring(promotionRank) and isstring(editor.autoPromoteTo.customDataValue) then 
                            promotionRank = editor.autoPromoteTo.customDataValue
                        end
                        if isstring(promotionRank) and istable(nadmin.ranks[promotionRank]) then 
                            newRank.autoPromote.rank = promotionRank
                        end
                    end

                    net.Start("nadmin_manage_rank")
                        net.WriteUInt(0, 2)
                        net.WriteBool(isEditingRank)
                        if isEditingRank then net.WriteString(editor.selectedRankId) end
                        net.WriteTable(newRank)
                    net.SendToServer()
                end

                local deleteRank = vgui.Create("NadminButton", manageContainer)
                deleteRank:SetText("Delete Rank")
                deleteRank:SetIcon("icon16/bin_closed.png")
                deleteRank:SetColor(nadmin.colors.gui.red)
                deleteRank:SetSize(298, 28)
                deleteRank:SetX(302)
                deleteRank:SetVisible(false)
                nadmin.rankTab.editor.deleteRankButton = deleteRank


                local dividerManageFromName = vgui.Create("NadminPanel", editor)
                dividerManageFromName:Dock(TOP)
                dividerManageFromName:DockMargin(sidePadding - 8, 8, sidePadding - 8, 4)
                dividerManageFromName:SetTall(2)
                dividerManageFromName:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, -25))


                local titleContainer = vgui.Create("NadminPanel", editor)
                titleContainer:Dock(TOP)
                titleContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                titleContainer:SetTall(28)
                
                local titleLabel = vgui.Create("DLabel", titleContainer)
                titleLabel:SetFont("nadmin_derma")
                titleLabel:SetText("Title:")
                titleLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                titleLabel:SizeToContentsX()
                titleLabel:SetTall(titleContainer:GetTall())
                titleLabel:Dock(LEFT)

                local titleEntry = vgui.Create("NadminTextEntry", titleContainer)
                titleEntry:Dock(FILL)
                titleEntry:DockMargin(4, 0, 0, 0)
                titleEntry:SetPlaceholderText("What players will see in chat and scoreboard")
                function titleEntry:ErrorCondition()
                    local trim = string.Trim(self:GetText())
                    if trim == "" then
                        return "Cannot be blank"
                    elseif #trim > 16 then 
                        return "Cannot be longer than 16 characters"
                    end 
                end
                function titleEntry:WarningCondition()
                    if self:HasFocus() then 
                        local characters = #string.Trim(self:GetText()) 
                        if characters >= 12 then return "Using " .. characters .. " of 16 characters" end
                    end
                end
                nadmin.rankTab.editor.titleEntry = titleEntry

                local idContainer = vgui.Create("NadminPanel", editor)
                idContainer:Dock(TOP)
                idContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                idContainer:SetTall(28)
                
                local idLabel = vgui.Create("DLabel", idContainer)
                idLabel:SetFont("nadmin_derma")
                idLabel:SetText("Identifier:")
                idLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                idLabel:SizeToContentsX()
                idLabel:SetTall(idContainer:GetTall())
                idLabel:Dock(LEFT)

                local idEntry = vgui.Create("NadminTextEntry", idContainer)
                idEntry:Dock(FILL)
                idEntry:DockMargin(4, 0, 0, 0)
                idEntry:SetPlaceholderText("True identifier of the rank")
                idEntry.hadFocus = false
                function idEntry:ErrorCondition()
                    local trim = string.Trim(self:GetText())
                    if trim == "" then 
                        return "Cannot be blank" 
                    end

                    -- This shouldn't be possible since capital letters are made lowercase and null_rank.id is "DEFAULT"
                    if trim == nadmin.null_rank.id then
                        return trim .. " is reserved" 
                    end 

                    for id, rank in pairs(nadmin.ranks) do 
                        if trim == id and nadmin.rankTab.selectedRankId ~= id then
                            return trim .. " already exists"
                        end
                    end
                end
                function idEntry:WarningCondition() 
                    self.hadFocus = self.hadFocus or self:HasFocus()

                    if self:HasFocus() and (input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT)) then return "No capitals allowed" end
                end

                -- We don't want spaces or capitals in the ID. Nobody except for people who can manage ranks will see the ID anyway, this is just an identifier for the mod internally
                function idEntry:OnChange()
                    local caret = self:GetCaretPos()
                    self:SetText(string.Replace(string.lower(self:GetText()), " ", "_"))
                    self:SetCaretPos(caret)
                end
                nadmin.rankTab.editor.idEntry = idEntry

                function titleEntry:OnChange()
                    local trim = string.Trim(self:GetText())
                    
                    if trim ~= "" then 
                        local saveText = ""
                        if not nadmin.rankTab.selectedRankId then 
                            saveText = saveText .. "Create "
                        else 
                            saveText = saveText .. "Save "
                        end
                        saveText = saveText .. trim

                        saveRank:SetText(saveText)
                        deleteRank:SetText("Delete " .. trim)
                    else 
                        saveRank:SetText("Create Rank")
                        deleteRank:SetText("Delete Rank")
                    end

                    if not idEntry.hadFocus then 
                        idEntry:SetValue(trim)
                        idEntry:OnChange()
                    end
                end


                local dividerInheritFromName = vgui.Create("NadminPanel", editor)
                dividerInheritFromName:Dock(TOP)
                dividerInheritFromName:DockMargin(sidePadding - 8, 8, sidePadding - 8, 4)
                dividerInheritFromName:SetTall(2)
                dividerInheritFromName:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, -25))


                local inheritFromContainer = vgui.Create("DPanel", editor)
                function inheritFromContainer:Paint() end
                inheritFromContainer:Dock(TOP)
                inheritFromContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                inheritFromContainer:SetTall(28)

                local inheritFromLabel = vgui.Create("DLabel", inheritFromContainer)
                inheritFromLabel:SetFont("nadmin_derma")
                inheritFromLabel:SetText("Inherit from:")
                inheritFromLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                inheritFromLabel:SizeToContentsX()
                inheritFromLabel:SetTall(inheritFromContainer:GetTall())
                inheritFromLabel:Dock(LEFT)

                local inheritFrom = vgui.Create("NadminComboBox", inheritFromContainer)
                inheritFrom:Dock(FILL)
                inheritFrom:DockMargin(4, 0, 0, 0)
                inheritFrom:SetSortItems(false)
                inheritFrom:SetText("Do not inherit")
                inheritFrom:AddChoice("Do not inherit", nil)
                nadmin.rankTab.editor.inheritFrom = inheritFrom

                -- tRanks - The ranks that the local player can target
                local tRanks = {}
                for id, rank in pairs(nadmin.ranks) do 
                    if localRank.access < nadmin.access.owner then -- The owner rank shouldn't have any restrictions on creating ranks
                        if rank.access > localRank.access then continue end 
                        if rank.access == localRank.access and rank.immunity >= localRank.immunity then continue end
                    end 

                    table.insert(tRanks, rank)
                end
                table.sort(tRanks, function(a, b) return a.access == b.access and a.immunity < b.immunity or a.access < b.access end)
                for i, rank in ipairs(tRanks) do 
                    inheritFrom:AddChoice(rank.title .. " (" .. rank.id .. ")", rank.id)
                end

                local accessContainer = vgui.Create("DPanel", editor)
                function accessContainer:Paint() end
                accessContainer:Dock(TOP)
                accessContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                accessContainer:SetTall(28)


                local accessLabel = vgui.Create("DLabel", accessContainer)
                accessLabel:SetFont("nadmin_derma")
                accessLabel:SetText("Access level:")
                accessLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                accessLabel:SizeToContentsX()
                accessLabel:SetTall(28)
                accessLabel:Dock(LEFT)

                local accessRestricted = vgui.Create("NadminButton", accessContainer)
                local accessDefault = vgui.Create("NadminButton", accessContainer)
                local accessUser = vgui.Create("NadminButton", accessContainer)
                local accessAdmin = vgui.Create("NadminButton", accessContainer)
                local accessSuperadmin = vgui.Create("NadminButton", accessContainer)
                local accessOwner = vgui.Create("NadminButton", accessContainer)
                nadmin.rankTab.editor.accessButtons = {accessRestricted, accessDefault, accessUser, accessAdmin, accessSuperadmin, accessOwner}
                nadmin.rankTab.editor.selectedAccess = nadmin.access.user

                accessRestricted:Dock(LEFT)
                accessRestricted:DockMargin(4, 0, 0, 0)
                accessRestricted:SetText("")
                accessRestricted:SetSize(28, 28)
                accessRestricted:SetIcon("icon16/cancel.png")
                accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                accessRestricted.baseToolTip = "Limited access - Spawnmenu permissions acts as a whitelist instead of blacklist"
                accessRestricted:SetToolTip(accessRestricted.baseToolTip)
                function accessRestricted:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.restricted
                    accessRestricted:SetColor(nadmin.colors.gui.blue)
                    accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessUser:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end
                if localRank.access <= nadmin.access.restricted then accessRestricted:SetEnabled(false) end

                accessDefault:Dock(LEFT)
                accessDefault:DockMargin(4, 0, 0, 0)
                accessDefault:SetText("")
                accessDefault:SetSize(28, 28)
                accessDefault:SetIcon("icon16/new.png")
                accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                accessDefault.baseToolTip = "Rank for first time players"
                accessDefault:SetToolTip(accessDefault.baseToolTip)
                function accessDefault:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.default
                    accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessDefault:SetColor(nadmin.colors.gui.blue)
                    accessUser:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end
                if localRank.access <= nadmin.access.default then accessDefault:SetEnabled(false) end

                accessUser:Dock(LEFT)
                accessUser:DockMargin(4, 0, 0, 0)
                accessUser:SetText("")
                accessUser:SetSize(28, 28)
                accessUser:SetIcon("icon16/user.png")
                accessUser:SetColor(nadmin.colors.gui.blue)
                accessUser.baseToolTip = "User"
                accessUser:SetToolTip(accessUser.baseToolTip)
                function accessUser:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.user
                    accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessUser:SetColor(nadmin.colors.gui.blue)
                    accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end
                if localRank.access <= nadmin.access.user then accessUser:SetEnabled(false) end

                accessAdmin:Dock(LEFT)
                accessAdmin:DockMargin(4, 0, 0, 0)
                accessAdmin:SetText("")
                accessAdmin:SetSize(28, 28)
                accessAdmin:SetIcon("icon16/shield.png")
                accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                accessAdmin.baseToolTip = "Admin"
                accessAdmin:SetToolTip(accessAdmin.baseToolTip)
                function accessAdmin:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.admin
                    accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessUser:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessAdmin:SetColor(nadmin.colors.gui.blue)
                    accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end
                if localRank.access <= nadmin.access.admin then accessAdmin:SetEnabled(false) end
                
                accessSuperadmin:Dock(LEFT)
                accessSuperadmin:DockMargin(4, 0, 0, 0)
                accessSuperadmin:SetText("")
                accessSuperadmin:SetSize(28, 28)
                accessSuperadmin:SetIcon("icon16/shield_add.png")
                accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                accessSuperadmin.baseToolTip = "Superadmin"
                accessSuperadmin:SetToolTip(accessSuperadmin.baseToolTip)
                function accessSuperadmin:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.superadmin
                    accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessUser:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessSuperadmin:SetColor(nadmin.colors.gui.blue)
                    accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                end
                if localRank.access <= nadmin.access.superadmin then accessSuperadmin:SetEnabled(false) end

                accessOwner:Dock(LEFT)
                accessOwner:DockMargin(4, 0, 0, 0)
                accessOwner:SetText("")
                accessOwner:SetSize(28, 28)
                accessOwner:SetIcon("icon16/key.png")
                accessOwner:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                accessOwner.baseToolTip = "Owner - cannot be restricted from any permissions"
                accessOwner:SetToolTip(accessOwner.baseToolTip)
                function accessOwner:DoClick()
                    nadmin.rankTab.editor.selectedAccess = nadmin.access.owner
                    accessRestricted:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessDefault:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessUser:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessAdmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessSuperadmin:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessOwner:SetColor(nadmin.colors.gui.blue)
                end
                if localRank.access < nadmin.access.owner then 
                    accessOwner:SetEnabled(false) 
                    accessOwner:SetToolTip("You cannot set the access higher than your access")
                end

                local immunityContainer = vgui.Create("NadminPanel", editor)
                immunityContainer:Dock(TOP)
                immunityContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                immunityContainer:SetTall(28)
                
                local immunityLabel = vgui.Create("DLabel", immunityContainer)
                immunityLabel:SetFont("nadmin_derma")
                immunityLabel:SetText("Immunity:")
                immunityLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                immunityLabel:SizeToContentsX()
                immunityLabel:SetTall(immunityContainer:GetTall())
                immunityLabel:Dock(LEFT)

                local immunityEntry = vgui.Create("NadminTextEntry", immunityContainer)
                immunityEntry:Dock(FILL)
                immunityEntry:DockMargin(4, 0, 0, 0)
                immunityEntry:SetPlaceholderText("# immunity")
                immunityEntry:SetNumeric(true)
                immunityEntry.setImmunity = 0
                function immunityEntry:ErrorCondition()
                    if string.Trim(self:GetText()) == "" then
                        return "Cannot be blank"
                    end 

                    if localRank.access >= nadmin.access.owner then return end
                    local currentValue = tonumber(self:GetValue())
                    if not isnumber(currentValue) then return "Invalid characters" end

                    if nadmin.rankTab.editor.selectedAccess >= localRank.access and currentValue >= localRank.immunity and currentValue ~= self.setImmunity then 
                        return "Cannot set this rank higher than yours"
                    end
                end
                nadmin.rankTab.editor.immunityEntry = immunityEntry


                local dividerAccess = vgui.Create("NadminPanel", editor)
                dividerAccess:Dock(TOP)
                dividerAccess:DockMargin(sidePadding - 8, 8, sidePadding - 8, 4)
                dividerAccess:SetTall(2)
                dividerAccess:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, -25))


                local colorPreview = vgui.Create("DPanel", editor)
                local colorPicker = vgui.Create("DColorMixer", editor)
                colorPreview:Dock(TOP)
                colorPreview:DockMargin(sidePadding, 4, sidePadding, 0)
                colorPreview:SetTall(28)
                function colorPreview:Paint(w, h)
                    local trim = string.Trim(titleEntry:GetText())

                    local tc = nadmin:TextColor(nadmin.colors.gui.theme)

                    local x = 4
                    x = x + draw.Text({
                        text = "Color: ",
                        font = "nadmin_derma",
                        pos = {x, h/2},
                        yalign = TEXT_ALIGN_CENTER,
                        color = tc
                    })
                    x = x + draw.Text({
                        text = "(" .. (trim == "" and "Title" or trim) .. ") ",
                        font = "ChatFont",
                        pos = {x, h/2},
                        yalign = TEXT_ALIGN_CENTER,
                        color = tc
                    })
                    x = x + draw.Text({
                        text = LocalPlayer():Nick(),
                        font = "ChatFont",
                        pos = {x, h/2},
                        yalign = TEXT_ALIGN_CENTER,
                        color = colorPicker:GetColor()
                    })
                    x = x + draw.Text({
                        text = ": Example message!",
                        font = "ChatFont",
                        pos = {x, h/2},
                        yalign = TEXT_ALIGN_CENTER,
                        color = tc
                    })
                end

                local colorToggle = vgui.Create("NadminButton", colorPreview)
                colorToggle:Dock(RIGHT)
                colorToggle:SetText("")
                colorToggle:SetToolTip("Show color picker")
                colorToggle:SetWide(colorPreview:GetTall())
                colorToggle:SetIcon("icon16/color_wheel.png")
                function colorToggle:DoClick() 
                    if colorPicker:IsVisible() then 
                        colorPicker:SetVisible(false)
                        self:SetToolTip("Show color picker")
                    else 
                        colorPicker:SetVisible(true)
                        self:SetToolTip("Hide color picker")
                    end

                    editor:InvalidateChildren()
                end

                local randomColor = vgui.Create("NadminButton", colorPreview)
                randomColor:Dock(RIGHT)
                randomColor:DockMargin(0, 0, 4, 0)
                randomColor:SetToolTip("Random Color")
                randomColor:SetText("")
                randomColor:SetIcon("icon16/palette.png")
                randomColor:SetWide(colorToggle:GetWide())
                function randomColor:DoClick()
                    colorPicker:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                end

                colorPicker:Dock(TOP)
                colorPicker:DockMargin(sidePadding, 4, sidePadding, 0)
                colorPicker:SetAlphaBar(false)
                colorPicker:SetPalette(false)
                colorPicker:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                colorPicker:SetTall(68)
                colorPicker:SetVisible(false)
                nadmin.rankTab.editor.colorPicker = colorPicker

                
                local dividerColor = vgui.Create("NadminPanel", editor)
                dividerColor:Dock(TOP)
                dividerColor:DockMargin(sidePadding - 8, 8, sidePadding - 8, 4)
                dividerColor:SetTall(2)
                dividerColor:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, -25))


                local iconContainer = vgui.Create("NadminPanel", editor)
                iconContainer:Dock(TOP)
                iconContainer:DockMargin(sidePadding, 4, sidePadding, 0)
                iconContainer:SetTall(28)
                
                local iconLabel = vgui.Create("DLabel", iconContainer)
                iconLabel:SetFont("nadmin_derma")
                iconLabel:SetText("Icon:")
                iconLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                iconLabel:SizeToContentsX()
                iconLabel:SetTall(iconContainer:GetTall())
                iconLabel:Dock(LEFT)

                local iconPreview = vgui.Create("DImage", iconContainer)
                iconPreview:Dock(LEFT)
                iconPreview:SetImage("icon16/user.png")
                iconPreview:DockMargin(4, 4, 0, 4)
                iconPreview:SetSize(20, 20)
                nadmin.rankTab.editor.iconPreview = iconPreview

                local iconEntry = vgui.Create("NadminTextEntry", iconContainer)
                iconEntry:Dock(FILL)
                iconEntry:DockMargin(4, 0, 0, 0)
                iconEntry:SetTall(28)
                iconEntry:SetPlaceholderText("Icon Search (Type to open browser, or click ->)")

                local iconBrowser = vgui.Create("NadminScrollPanel", editor)
                iconBrowser:Dock(TOP)
                iconBrowser:DockMargin(sidePadding, 4, sidePadding, 0)
                iconBrowser:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                iconBrowser:SetTall(86)
                iconBrowser:SetVisible(false)
                local vbar = iconBrowser:GetVBar()

                local iconBrowserToggle = vgui.Create("NadminButton", iconContainer)
                iconBrowserToggle:Dock(RIGHT)
                iconBrowserToggle:DockMargin(4, 0, 0, 0)
                iconBrowserToggle:SetText("")
                iconBrowserToggle:SetToolTip("Show icon browser (or start searching)")
                iconBrowserToggle:SetSize(28, 28)
                iconBrowserToggle:SetIcon("icon16/application_side_expand.png")
                function iconBrowserToggle:DoClick() 
                    if iconBrowser:IsVisible() then 
                        iconBrowser:SetVisible(false)
                        iconBrowserToggle:SetToolTip("Show icon browser (or start searching)")
                        iconBrowserToggle:SetIcon("icon16/application_side_expand.png")
                    else 
                        iconBrowser:SetVisible(true)
                        iconBrowserToggle:SetToolTip("Hide icon browser")
                        iconBrowserToggle:SetIcon("icon16/application_side_contract.png")
                    end

                    editor:InvalidateChildren()
                end
                
                -- Function to populate the browser 
                local function drawIcons(search) 
                    iconBrowser:Clear()
                    if IsValid(iconBrowser.tempPanel) then iconBrowser.tempPanel:Remove() end 
                    if isstring(search) then search = string.lower(search) end

                    local ix, iy = 4, 4
                    local index = 0
                    local keys = table.GetKeys(nadmin.icons)
                    table.sort(keys, function (a, b) return a < b end)
                    
                    -- Spawning all icons at once causes a noticable freeze, so for optimization, I will only spawn so many per frame
                    iconBrowser.tempPanel = vgui.Create("DPanel")
                    iconBrowser.tempPanel:SetWide(editor:GetWide() - 8)
                    function iconBrowser.tempPanel:Paint(w, h)
                        local i = 0
                        local maxI = 50

                        while index < #keys and i < maxI do 
                            i = i + 1
                            index = index + 1 

                            local shouldDraw = not isstring(search)
                            if not shouldDraw then shouldDraw = string.find(string.lower(keys[index]), string.Replace(search, " ", "_")) end

                            if shouldDraw then 
                                local iconPath = nadmin.icons[keys[index]]

                                local btn = vgui.Create("NadminButton", iconBrowser)
                                btn:SetPos(ix, iy)
                                btn:SetToolTip(keys[index])
                                btn:SetIcon(iconPath)
                                btn:SetColor(nadmin.colors.gui.theme)
                                btn:SetSize(28, 28)
                                btn:SetText("")

                                -- Since there can be over 1000 buttons if the search is empty, it can make the framerate drop significantly.
                                -- Using my custom render condition method, I can tell it to not render if off the scroll panel, saving render time
                                function btn:RenderCondition()
                                    local x, y = self:GetPos() 
                                    return (y >= vbar:GetScroll() - self:GetTall() and y <= vbar:GetScroll() + iconBrowser:GetTall())
                                end

                                -- Updating the paint function to let me just set the color based on selection instead of trying to change up to 1000 colors at once
                                btn.normalPaint = btn.Paint 
                                function btn:Paint(w, h)
                                    self:normalPaint(w, h)

                                    if self:GetIcon() == iconPreview:GetImage() and self:GetColor() ~= nadmin.colors.gui.blue then 
                                        self:SetColor(nadmin.colors.gui.blue)
                                    elseif self:GetIcon() ~= iconPreview:GetImage() and self:GetColor() ~= nadmin.colors.gui.theme then 
                                        self:SetColor(nadmin.colors.gui.theme)
                                    end
                                end

                                function btn:DoClick()
                                    iconPreview:SetImage(self:GetIcon())
                                end

                                -- Update position for next button 
                                if ix + btn:GetWide() >= w - btn:GetWide() - vbar:GetWide() - 8 then 
                                    ix = 4 
                                    iy = iy + btn:GetTall() + 12
                                else 
                                    ix = ix + btn:GetWide() + 12
                                end
                            end

                            -- If we have gotten through all the icons, remove this temp panel
                            if index >= #keys then 
                                iconBrowser.tempPanel:Remove() 
                                break
                            end
                        end 
                    end
                end
                drawIcons()
                function iconEntry:OnChange() 
                    if not iconBrowser:IsVisible() then 
                        iconBrowser:SetVisible(true)
                        iconBrowserToggle:SetToolTip("Hide icon browser")
                        iconBrowserToggle:SetIcon("icon16/application_side_contract.png")
                        editor:InvalidateChildren()
                    end
                    drawIcons(string.Trim(string.lower(self:GetText())))
                end

                -- A little loading circle in the icon search bar that shows when populating the browser
                iconEntry.normalPaint = iconEntry.Paint 
                function iconEntry:Paint(w, h)
                    self:normalPaint(w, h)
                    
                    if IsValid(iconBrowser.tempPanel) then 
                        draw.Circle(w - h/2, h/2, h/2 - 4, 360, 360, 0, nadmin:DarkenColor(self:GetColor(), 50))
                        draw.Circle(w - h/2, h/2, h/2 - 4, 360, 270, (SysTime() % 360) * 180, nadmin:TextColor(self:GetColor()))
                        draw.Circle(w - h/2, h/2, h/2 - 6, 360, 360, 0, self:GetColor())
                    end
                end


                local dividerIcon = vgui.Create("NadminPanel", editor)
                dividerIcon:Dock(TOP)
                dividerIcon:DockMargin(sidePadding - 8, 8, sidePadding - 8, 4)
                dividerIcon:SetTall(2)
                dividerIcon:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, -25))


                local apToggle = vgui.Create("NadminCheckBox", editor)
                apToggle:SetText("Auto Promotion")
                apToggle:SetTall(28)
                apToggle:Dock(TOP)
                apToggle:DockMargin(sidePadding, 4, sidePadding, 0)
                apToggle:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                apToggle:SetStyle(nadmin.STYLE_SWITCH)
                nadmin.rankTab.editor.autoPromotionToggle = apToggle

                local apContainer = vgui.Create("NadminPanel", editor)
                apContainer:Dock(TOP)
                apContainer:DockMargin(sidePadding, 0, sidePadding, 0)
                apContainer:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                apContainer:SetTall(apToggle:GetTall() * 2 + 16)
                function apContainer:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h - 4, self.color)
                    draw.RoundedBox(0, 0, h - 4, w, 4, nadmin.colors.gui.theme)
                end
                nadmin.rankTab.editor.autoPromotionContainer = apContainer

                local apToContainer = vgui.Create("NadminPanel", apContainer)
                apToContainer:Dock(TOP)
                apToContainer:DockPadding(4, 0, 4, 0)
                apToContainer:DockMargin(0, 4, 0, 0)
                apToContainer:SetColor(apContainer:GetColor())
                apToContainer:SetTall(apToggle:GetTall())
                
                local apToLabel = vgui.Create("DLabel", apToContainer)
                apToLabel:SetFont("nadmin_derma")
                apToLabel:SetText("Auto Promote To:")
                apToLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                apToLabel:SizeToContentsX()
                apToLabel:SetTall(apToContainer:GetTall())
                apToLabel:Dock(LEFT)

                local apToSelect = vgui.Create("NadminComboBox", apToContainer)
                apToSelect:Dock(FILL)
                apToSelect:DockMargin(4, 0, 0, 0)
                apToSelect:SetColor(nadmin.colors.gui.theme)
                apToSelect:SetSortItems(false)
                apToSelect:SetText("Select a rank (required)...")
                for i, rank in ipairs(tRanks) do 
                    apToSelect:AddChoice(rank.title .. " (" .. rank.id .. ")", rank.id)
                end
                nadmin.rankTab.editor.autoPromoteTo = apToSelect

                local apAfterContainer = vgui.Create("NadminPanel", apContainer)
                apAfterContainer:Dock(TOP)
                apAfterContainer:DockPadding(4, 0, 4, 0)
                apAfterContainer:DockMargin(0, 4, 0, 0)
                apAfterContainer:SetColor(apContainer:GetColor())
                apAfterContainer:SetTall(apToggle:GetTall())
                
                local apAfterLabel = vgui.Create("DLabel", apAfterContainer)
                apAfterLabel:SetFont("nadmin_derma")
                apAfterLabel:SetText("Auto Promote After:")
                apAfterLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                apAfterLabel:SizeToContentsX()
                apAfterLabel:SetTall(apAfterContainer:GetTall())
                apAfterLabel:Dock(LEFT)

                local apAfterEntry = vgui.Create("NadminTextEntry", apAfterContainer)
                apAfterEntry:Dock(FILL)
                apAfterEntry:DockMargin(4, 0, 0, 0)
                apAfterEntry:SetColor(nadmin.colors.gui.theme)
                apAfterEntry:SetPlaceholderText("When should this rank be promoted?")
                nadmin.rankTab.editor.autoPromoteAfter = apAfterEntry

                function apAfterEntry:ErrorCondition() 
                    -- Should only error if auto promotion is enabled
                    if apToggle:GetChecked() then 
                        if string.Trim(self:GetText()) == "" then 
                            return "Cannot be blank" 
                        end 

                        local time = nadmin:ParseTime(self:GetText())
                        if not isnumber(time) then 
                            return "Invalid time" 
                        end
                        if time <= 0 then 
                            return "Must be at least 1 second" 
                        end
                    end 
                end

                -- A text overlay to help the user know the time they input
                apAfterEntry.normalPaint = apAfterEntry.Paint 
                function apAfterEntry:Paint(w, h)
                    self:normalPaint(w, h)

                    local time = nadmin:ParseTime(string.Trim(self:GetText()))
                    if isnumber(time) and time > 0 then 
                        draw.Text({
                            text = "(" .. nadmin:TimeToString(time, true) .. ")",
                            font = self:GetFont(),
                            pos = {w - 4, h/2},
                            xalign = TEXT_ALIGN_RIGHT,
                            yalign = TEXT_ALIGN_CENTER,
                            color = nadmin:AlphaColor(self:GetTextColor(), 75)
                        })
                    end
                end

                apContainer:SetVisible(false)
                function apToggle:OnChange(checked)
                    apContainer:SetVisible(checked)
                    editor:InvalidateChildren()
                end
            end, true)
            local rankPermissionsTab = rankPropertiesTabManager:AddTab("Permissions", function(editor)
                local searchBarSize = editor:GetWide() * 0.5

                local dividerColor = nadmin:BrightenColor(nadmin.colors.gui.theme, -25)
                function editor:Paint(w, h) 
                    draw.RoundedBox(0, w * 0.3 - 1, 46, 2, h, dividerColor)
                    draw.RoundedBox(0, w * 0.6 - 1, 46, 2, h, dividerColor)
                    draw.RoundedBox(0, 0, 46, w, 2, dividerColor)
                    draw.RoundedBox(0, w/2 - searchBarSize/2 - 10, 0, 2, 46, dividerColor)
                    draw.RoundedBox(0, w/2 + searchBarSize/2 + 8, 0, 2, 46, dividerColor)
                end

                local searchBar = vgui.Create("NadminTextEntry", editor)
                searchBar:SetSize(searchBarSize, 28)
                searchBar:SetPos(editor:GetWide()/2 - searchBarSize/2, 10)
                searchBar:SetPlaceholderText("Search for permission...")
                searchBar:SetUpdateOnType(true)

                local categoryWidth = editor:GetWide() * 0.3 - 17
                local labelColor = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                local labelTextColor = nadmin:TextColor(labelColor)
                
                local categoryLabel = vgui.Create("DPanel", editor)
                categoryLabel:SetPos(8, 60)
                categoryLabel:SetSize(categoryWidth, 28)
                categoryLabel.text = "Category"
                categoryLabel.icon = Material("icon16/folder.png")
                function categoryLabel:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, labelColor)
                    draw.Text({
                        text = self.text,
                        font = "nadmin_derma",
                        color = labelTextColor,
                        yalign = TEXT_ALIGN_CENTER,
                        pos = {h, h/2}
                    })

                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(self.icon)
                    surface.DrawTexturedRect(4, 4, h - 8, h - 8)
                end

                local permissionLabel = vgui.Create("DPanel", editor)
                permissionLabel:SetPos(editor:GetWide() * 0.3 + 9, 60)
                permissionLabel:SetSize(categoryWidth, categoryLabel:GetTall())
                permissionLabel.text = "Permission"
                permissionLabel.icon = Material("icon16/table.png")
                function permissionLabel:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, labelColor)
                    draw.Text({
                        text = self.text,
                        font = "nadmin_derma",
                        color = labelTextColor,
                        yalign = TEXT_ALIGN_CENTER,
                        pos = {h, h/2}
                    })

                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(self.icon)
                    surface.DrawTexturedRect(4, 4, h - 8, h - 8)
                end

                local limitsLabel = vgui.Create("DPanel", editor)
                limitsLabel:SetPos(editor:GetWide() * 0.6 + 9, 60)
                limitsLabel:SetSize(editor:GetWide() - limitsLabel:GetX() - 8, categoryLabel:GetTall())
                limitsLabel.text = "Limits"
                limitsLabel.icon = Material("icon16/pencil.png")
                function limitsLabel:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, labelColor)
                    draw.Text({
                        text = self.text,
                        font = "nadmin_derma",
                        color = labelTextColor,
                        yalign = TEXT_ALIGN_CENTER,
                        pos = {h + 2, h/2}
                    })

                    surface.SetDrawColor(255, 255, 255, 255)
                    surface.SetMaterial(self.icon)
                    surface.DrawTexturedRect(4, 4, h - 8, h - 8)
                end
                

                local selectedCategory    = NULL
                local selectedSubCategory = NULL
                local selectedPermission  = NULL

                local permissionTree = {
                    ["Commands"] = {
                        permissions = {},
                        subCategories = {}
                    },
                    ["Tabs"] = {
                        permissions = nadmin.menu.tabs,
                        subCategories = {}
                    },
                    ["Spawnmenu"] = {
                        permissions = {},
                        subCategories = {
                            ["Entities"]     = {permissions = {}}, -- list "SpawnableEntities"
                            ["NPCs"]         = {permissions = {}}, -- list "NPC"
                            ["Props/Models"] = {permissions = {}}, -- Too many models to try to show, instead just have them paste a model path and show currently added models
                            ["Tools"]        = {permissions = {}}, -- spawnmenu.GetTools()
                            ["Vehicles"]     = {permissions = {}}, -- lists "Vehicles" and "simfphys_vehicles"
                            ["Weapons"]      = {permissions = {}}  -- list "Weapon"
                        }
                    }
                }

                -- When the search bar text changes, this will populate by going through the permission tree and only showing relevant stuff
                local filteredPermissionTree = {}

                for id, permission in pairs(nadmin.perms) do 
                    if not istable(permissionTree[permission.category]) then 
                        permissionTree[permission.category] = {
                            permissions = {},
                            subCategories = {}
                        }
                    end
                    local treeReference = permissionTree[permission.category]

                    if isstring(permission.subCategory) then 
                        if not istable(treeReference.subCategories[permission.subCategory]) then 
                            treeReference.subCategories[permission.subCategory] = {permissions = {}}
                        end
                        table.insert(treeReference.subCategories[permission.subCategory].permissions, permission)
                    else 
                        table.insert(treeReference.permissions, permission)
                    end
                end

                local commandsTreeReference = permissionTree["Commands"].subCategories
                for id, command in pairs(nadmin.commands) do 
                    if not istable(commandsTreeReference[command.category]) then 
                        commandsTreeReference[command.category] = {permissions = {}}
                    end
                    table.insert(commandsTreeReference[command.category].permissions, command)
                end

                local spawnmenuReference = permissionTree["Spawnmenu"].subCategories
                local entitiesReference  = spawnmenuReference["Entities"].permissions
                local npcsReference      = spawnmenuReference["NPCs"].permissions
                local vehiclesReference  = spawnmenuReference["Vehicles"].permissions
                local weaponsReference   = spawnmenuReference["Weapons"].permissions
                local toolReference      = spawnmenuReference["Tools"].permissions
                
                for className, entity in pairs(list.Get("SpawnableEntities")) do 
                    table.insert(entitiesReference, {title = entity.PrintName, id = className})
                end
                
                for className, npc in pairs(list.Get("NPC")) do 
                    table.insert(npcsReference, {title = npc.Name, id = className})
                end
                
                for className, vehicle in pairs(list.Get("Vehicles")) do 
                    table.insert(vehiclesReference, {title = vehicle.Name, id = className})
                end
                local simfphysVehicles = list.Get("simfphys_vehicles")
                if istable(simfphysVehicles) then 
                    for className, vehicle in pairs(simfphysVehicles) do 
                        table.insert(vehiclesReference, {title = vehicle.Name, id = className})
                    end
                end

                for className, weapon in pairs(list.Get("Weapon")) do 
                    table.insert(weaponsReference, {title = weapon.PrintName, id = className})
                end

                local toolCategories = spawnmenu.GetTools()[1].Items
                for toolCategoryIndex, toolCategory in ipairs(toolCategories) do 
                    for toolIndex, tool in ipairs(toolCategory) do 
                        local toolTitle = language.GetPhrase(tool.Text)
                        if string.StartsWith(toolTitle, "#") then 
                            toolTitle = string.sub(toolTitle, 2)
                        end
                        table.insert(toolReference, {title = toolTitle, id = tool.ItemName})
                    end
                end


                local categoryContainer = vgui.Create("DScrollPanel", editor)
                categoryContainer:SetPos(categoryLabel:GetX(), categoryLabel:GetY() + categoryLabel:GetTall())
                categoryContainer:SetSize(categoryLabel:GetWide(), editor:GetTall() - categoryLabel:GetY() - categoryLabel:GetTall() - 8)
                categoryContainer:GetVBar():SetWide(0)
                function categoryContainer:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.theme, -15))
                end

                local permissionsContainer = vgui.Create("DScrollPanel", editor)
                permissionsContainer:SetPos(permissionLabel:GetX(), permissionLabel:GetY() + permissionLabel:GetTall())
                permissionsContainer:SetSize(permissionLabel:GetWide(), editor:GetTall() - permissionLabel:GetY() - permissionLabel:GetTall() - 8)
                permissionsContainer:GetVBar():SetWide(0)
                function permissionsContainer:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.theme, -15))
                end

                local limitsContainer = vgui.Create("DScrollPanel", editor)
                limitsContainer:SetPos(limitsLabel:GetX(), limitsLabel:GetY() + limitsLabel:GetTall())
                limitsContainer:SetSize(limitsLabel:GetWide(), editor:GetTall() - limitsLabel:GetY() - limitsLabel:GetTall() - 8)
                limitsContainer:GetVBar():SetWide(0)
                function limitsContainer:Paint(w, h)
                    draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.theme, -15))
                end

                local function createCategoryButton(panel, text, darker, isSubCategory, isBackButton)
                    local categoryButton = vgui.Create("DButton", panel)
                    categoryButton:Dock(TOP)
                    categoryButton:SetText("")
                    categoryButton:SetFont("nadmin_derma")
                    categoryButton:SetTall(24)
                    categoryButton.backgroundColor = darker and nadmin:BrightenColor(nadmin.colors.gui.theme, -20) or nadmin:BrightenColor(nadmin.colors.gui.theme, -10)
                    categoryButton.darker = darker
                    categoryButton.renderText = text
                    if not isSubCategory and not isBackButton then categoryButton.hasSubCategories = not table.IsEmpty(permissionTree[text].subCategories) end
                    if isBackButton then categoryButton.isBackButton = true end
                    function categoryButton:Paint(w, h)
                        local color
                        if selectedCategory == self.renderText or selectedSubCategory == self.renderText or self.isBackButton then 
                            color = nadmin.colors.gui.blue
                            if self.isBackButton and not self:IsHovered() then 
                                color = nadmin:BrightenColor(color, -25)
                            end
                        else 
                            if self:IsDown() then 
                                color = self.darker and nadmin:BrightenColor(self.backgroundColor, -5) or nadmin:BrightenColor(self.backgroundColor, -15)
                            elseif self:IsHovered() then 
                                color = nadmin:BrightenColor(self.backgroundColor, 15)
                            else 
                                color = self.backgroundColor
                            end
                        end

                        draw.RoundedBox(0, 0, 0, w, h, color)

                        draw.Text({
                            text = self.renderText,
                            font = self:GetFont(),
                            color = nadmin:TextColor(color),
                            pos = {w/2, h/2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER
                        })

                        if self.hasSubCategories then 
                            draw.Text({
                                text = ">",
                                font = self:GetFont(),
                                color = nadmin:TextColor(color),
                                pos = {w-4, h/2},
                                xalign = TEXT_ALIGN_RIGHT,
                                yalign = TEXT_ALIGN_CENTER
                            })
                        end

                        if self.isBackButton then 
                            draw.Text({
                                text = "<",
                                font = self:GetFont(),
                                color = nadmin:TextColor(color),
                                pos = {4, h/2},
                                xalign = TEXT_ALIGN_LEFT,
                                yalign = TEXT_ALIGN_CENTER
                            })
                        end
                    end

                    return categoryButton
                end

                local function createPermissionButton(panel, text, permissionID, darker, isPrivilege)
                    local permissionButton = vgui.Create("DButton", panel)
                    permissionButton:Dock(TOP)
                    permissionButton:SetText("")
                    permissionButton:SetFont("nadmin_derma")
                    permissionButton:SetTall(24)
                    permissionButton.backgroundColor = darker and nadmin:BrightenColor(nadmin.colors.gui.theme, -20) or nadmin:BrightenColor(nadmin.colors.gui.theme, -10)
                    permissionButton.darker = darker
                    permissionButton.renderText = text
                    permissionButton.id = permissionID
                    permissionButton.isPrivilege = isPrivilege
                    function permissionButton:Paint(w, h)
                        local overlayAlpha = 20
                        if selectedPermission == self.renderText then 
                            overlayAlpha = 40
                        end

                        local overlayColor = nadmin.colors.gui.red
                        if self.isPrivilege then 
                            -- Check if selected rank has privilege
                        else 
                            -- Check if selected rank is restricted
                        end

                        local baseColor
                        if self:IsDown() then 
                            baseColor = self.darker and nadmin:BrightenColor(self.backgroundColor, -5) or nadmin:BrightenColor(self.backgroundColor, -15)
                        elseif self:IsHovered() then 
                            baseColor = nadmin:BrightenColor(self.backgroundColor, 15)
                        else 
                            baseColor = self.backgroundColor
                        end

                        draw.RoundedBox(0, 0, 0, w, h, baseColor)
                        draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(overlayColor, overlayAlpha))

                        draw.Text({
                            text = self.renderText,
                            font = self:GetFont(),
                            color = nadmin:TextColor(baseColor),
                            pos = {w/2, h/2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER
                        })
                    end

                    return permissionButton
                end
                
                local function drawPermissions(pickedCategory, pickedSubCategory)
                    permissionsContainer:Clear()

                    local dark = false

                    local activeTree
                    if table.IsEmpty(filteredPermissionTree) and searchBar:GetValue() == "" then 
                        activeTree = permissionTree 
                    else
                        activeTree = filteredPermissionTree
                    end

                    local toShow = activeTree[pickedCategory]
                    if istable(toShow) and isstring(pickedSubCategory) then 
                        toShow = toShow.subCategories[pickedSubCategory]
                    end
                    
                    if not istable(toShow) then return end
                    if not istable(toShow.permissions) then return end

                    table.sort(toShow.permissions, function(a, b)
                        local left = a.title or a.id
                        local right = b.title or b.id
                        return string.lower(left) < string.lower(right)
                    end)

                    for index, permission in ipairs(toShow.permissions) do 
                        local permissionButton = createPermissionButton(permissionsContainer, permission.title or permission.id, permission.id, dark, pickedCategory == "Spawnmenu")
                        function permissionButton:DoClick()
                            selectedPermission = self.renderText
                        end

                        dark = not dark
                    end
                end

                local function drawCategories(pickedCategory)
                    categoryContainer:Clear()
                    permissionsContainer:Clear()

                    local dark = false

                    local activeTree
                    if table.IsEmpty(filteredPermissionTree) and searchBar:GetValue() == "" then 
                        activeTree = permissionTree 
                    else
                        activeTree = filteredPermissionTree
                    end

                    local toShow = table.GetKeys(activeTree)
                    if pickedCategory and istable(activeTree[pickedCategory]) then 
                        toShow = table.GetKeys(activeTree[pickedCategory].subCategories)
                        
                        local backButton = createCategoryButton(categoryContainer, pickedCategory, dark, false, true)
                        function backButton:DoClick()
                            selectedCategory = NULL
                            selectedSubCategory = NULL
                            selectedPermission = NULL
                            drawCategories()
                            permissionsContainer:Clear()
                        end

                        dark = not dark
                    end

                    table.sort(toShow)

                    for index, category in ipairs(toShow) do
                        local isSubCategory = isstring(pickedCategory)
    
                        local categoryButton = createCategoryButton(categoryContainer, category, dark, isSubCategory, false)
    
                        function categoryButton:DoClick()
                            if isstring(selectedCategory) and isSubCategory then 
                                selectedSubCategory = self.renderText
                            else 
                                selectedCategory = self.renderText
                            end 
                            selectedPermission = NULL

                            if self.hasSubCategories then drawCategories(category) end

                            drawPermissions(selectedCategory, selectedSubCategory)
                        end

                        dark = not dark
                    end
                end

                local searchDelay = 0.33
                local searchTimerIdentifier = "nadminRankPermissionSearch"
                function searchBar:OnValueChange(searchQuery)
                    timer.Create(searchTimerIdentifier, searchDelay, 1, function()
                        -- selectedCategory = NULL 
                        -- selectedSubCategory = NULL 
                        -- selectedPermission = NULL

                        searchQuery = string.lower(searchQuery)
                        table.Empty(filteredPermissionTree)
                        for categoryTitle, category in pairs(permissionTree) do 
                            for index, permission in ipairs(category.permissions) do 
                                local found = false
                                if isstring(permission.title) and string.find(string.lower(permission.title), searchQuery, 1, true) then found = true end
                                if isstring(permission.id)    and string.find(string.lower(permission.id),    searchQuery, 1, true) then found = true end

                                if found then 
                                    if not filteredPermissionTree[categoryTitle] then 
                                        filteredPermissionTree[categoryTitle] = {
                                            permissions = {},
                                            subCategories = {}
                                        }
                                    end
                                    table.insert(filteredPermissionTree[categoryTitle].permissions, permission)
                                end
                            end

                            for subCategoryTitle, subCategory in pairs(category.subCategories) do
                                for index, permission in ipairs(subCategory.permissions) do 
                                    local found = false
                                    if isstring(permission.title) and string.find(string.lower(permission.title), searchQuery, 1, true) then found = true end
                                    if isstring(permission.id)    and string.find(string.lower(permission.id),    searchQuery, 1, true) then found = true end
    
                                    if found then 
                                        if not filteredPermissionTree[categoryTitle] then 
                                            filteredPermissionTree[categoryTitle] = {
                                                permissions = {},
                                                subCategories = {}
                                            }
                                        end
                                        if not filteredPermissionTree[categoryTitle].subCategories[subCategoryTitle] then 
                                            filteredPermissionTree[categoryTitle].subCategories[subCategoryTitle] = {permissions = {}}
                                        end
                                        table.insert(filteredPermissionTree[categoryTitle].subCategories[subCategoryTitle].permissions, permission)
                                    end
                                end
                            end
                        end

                        if not istable(filteredPermissionTree[selectedCategory]) then 
                            selectedCategory = NULL
                            selectedSubCategory = NULL
                            selectedPermission = NULL
                        else 
                            if not istable(filteredPermissionTree[selectedCategory].subCategories[selectedSubCategory]) then 
                                selectedSubCategory = NULL
                                selectedPermission = NULL
                            else 
                                for index, permission in ipairs(filteredPermissionTree[selectedCategory].subCategories[selectedSubCategory].permissions) do 
                                    local found = false
                                    if isstring(permission.title) and string.find(string.lower(permission.title), searchQuery, 1, true) then found = true end
                                    if isstring(permission.id)    and string.find(string.lower(permission.id),    searchQuery, 1, true) then found = true end

                                    if not found then 
                                        selectedPermission = NULL
                                    end
                                end
                            end
                        end

                        drawCategories(selectedCategory)
                        if selectedCategory and selectedSubCategory then 
                            drawPermissions(selectedCategory, selectedSubCategory)
                        end
                    end)
                end
                function searchBar:OnEnter()
                    timer.Adjust(searchTimerIdentifier, 0) -- Stops and executes the timer callback
                end

                function searchBar:BackgroundDraw(w, h)
                    local timeLeft = timer.TimeLeft(searchTimerIdentifier)
                    if isnumber(timeLeft) and timeLeft > 0 then 
                        local progress = (searchDelay - timeLeft) / searchDelay
                        draw.RoundedBox(0, 0, h-4, w * progress, 4, nadmin:AlphaColor(nadmin.colors.gui.green, 15))
                    end
                end

                drawCategories()
            end)
            local rankMembersTab = rankPropertiesTabManager:AddTab("Members", function(editor) 
                function editor:Paint() end

            end)

            rankInformationTab:SetIcon("icon16/cog.png")
            rankPermissionsTab:SetIcon("icon16/wrench.png")
            rankMembersTab:SetIcon("icon16/user.png")

            local newRank = ranksTabManager:AddTab("New Rank", function()
                nadmin.rankTab.selectRank()
            end, true)

            local ranks = {}
            local myRank = LocalPlayer():GetRank()
            for i, rank in pairs(nadmin.ranks) do 
                local canEdit = false 
                if myRank.access == nadmin.access.owner then canEdit = true end 
                
                if not canEdit then 
                    if myRank.access > rank.access or (myRank.access == rank.access and myRank.immunity > rank.immunity) then canEdit = true end
                end
                
                if canEdit then 
                    table.insert(ranks, rank)
                end
            end

            -- Sort by access level, or if access is equal, then immunity
            table.sort(ranks, function(a, b) return a.access == b.access and a.immunity > b.immunity or a.access > b.access end)

            for i, rank in ipairs(ranks) do 
                local rankTab = ranksTabManager:AddTab(rank.title, function()
                    nadmin.rankTab.selectRank(rank.id)
                end)
                rankTab:SetSelectedColor(rank.color)
                rankTab:SetUnselectedTextColor(rank.color)
                rankTab:SetIcon(rank.icon)
            end

        end
    })

    function nadmin.rankTab.selectRank(rankid)
        if isstring(rankid) and not istable(nadmin.ranks[rankid]) then error("Bad argument #1: \"" .. rankid .. "\" is not a valid rank id.") end
        local rank = nadmin.ranks[rankid]
        nadmin.rankTab.selectedRankId = rankid or null

        local editor = nadmin.rankTab.editor
        
        if IsValid(editor.saveRankButton) then 
            if isstring(rankid) then 
                editor.saveRankButton:SetText("Save " .. rank.title)
                editor.saveRankButton:SetWide(editor.saveRankButton.baseWidth)

                editor.deleteRankButton:SetText("Delete " .. rank.title)
                editor.deleteRankButton:SetVisible(true)

                editor.titleEntry:SetValue(rank.title)
                editor.idEntry:SetValue(rank.id)
                editor.colorPicker:SetColor(table.Copy(rank.color))
                editor.iconPreview:SetImage(rank.icon)
                
                editor.immunityEntry:SetValue(rank.immunity)
                editor.immunityEntry.setImmunity = rank.immunity

                local inheritRank = nadmin.ranks[rank.inheritFrom]
                editor.inheritFrom:SetText(istable(inheritRank) and (inheritRank.title .. " (" .. inheritRank.id .. ")") or "Do not inherit")
                editor.inheritFrom.customDataValue = istable(inheritRank) and inheritRank.id or nil

                local localAccess = LocalPlayer():GetRank().access
                for index, accessButton in ipairs(editor.accessButtons) do 
                    accessButton:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessButton:SetToolTip(accessButton.baseToolTip)
                    accessButton:SetEnabled(true)

                    if localAccess < nadmin.access.owner then 
                        if index - 1 <= localAccess then 
                            accessButton:SetToolTip("You cannot set the access higher than your access")
                            accessButton:SetEnabled(false)
                        end
                    end
                end
                editor.accessButtons[rank.access + 1]:SetColor(nadmin.colors.gui.blue)
                editor.selectedAccess = rank.access
                editor.startedAccess = rank.access

                editor.autoPromotionToggle:SetChecked(rank.autoPromote.enabled)
                editor.autoPromotionContainer:SetVisible(rank.autoPromote.enabled)
                editor.autoPromoteAfter:SetValue(nadmin:TimeToString(rank.autoPromote.when))

                local promotionRank = nadmin.ranks[rank.autoPromote.rank]
                editor.autoPromoteTo:SetText(istable(promotionRank) and (promotionRank.title .. " (" .. promotionRank.id .. ")") or "Select a rank (required)...")
                editor.autoPromoteTo.customDataValue = istable(promotionRank) and promotionRank.id or nil
            else 
                editor.saveRankButton:SetText("Create Rank")
                editor.saveRankButton:SetWide(editor.saveRankButton.fullWidth)

                editor.deleteRankButton:SetVisible(false)
                editor.titleEntry:SetValue("")
                editor.idEntry:SetValue("")
                editor.colorPicker:SetColor(Color(math.random(0, 255), math.random(0, 255), math.random(0, 255)))
                editor.iconPreview:SetImage("icon16/user.png")

                editor.immunityEntry:SetValue("")
                editor.immunityEntry.setImmunity = 0
                
                editor.inheritFrom:SetText("Do not inherit")
                editor.inheritFrom.customDataValue = nil

                local localAccess = LocalPlayer():GetRank().access
                for index, accessButton in ipairs(editor.accessButtons) do 
                    accessButton:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    accessButton:SetToolTip(accessButton.baseToolTip)
                    accessButton:SetEnabled(true)

                    if localAccess < nadmin.access.owner then 
                        if index - 1 <= localAccess then 
                            accessButton:SetToolTip("You cannot set the access higher than your access")
                            accessButton:SetEnabled(false)
                        end
                    end
                end
                editor.accessButtons[nadmin.access.user + 1]:SetColor(nadmin.colors.gui.blue)
                editor.selectedAccess = nadmin.access.user
                editor.startedAccess = nadmin.access.user

                editor.autoPromotionToggle:SetChecked(false)
                editor.autoPromotionContainer:SetVisible(false)
                editor.autoPromoteAfter:SetValue("1s")

                editor.autoPromoteTo:SetText("Select a rank (required)...")
                editor.autoPromoteTo.customDataValue = nil
            end
        -- elseif
        end
    end
else -- SERVER 
    util.AddNetworkString("nadmin_manage_rank")

    net.Receive("nadmin_manage_rank", function(length, ply)
        if not ply:HasPerm("manage_ranks") then 
            return nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
        end

        local managing = net.ReadUInt(2)
        if managing == 0 then -- information
            local isEditingRank = net.ReadBool()

            local targetRankIdentifier
            local targetRank
            if isEditingRank then 
                targetRankIdentifier = net.ReadString() 

                targetRank = nadmin.ranks[targetRankIdentifier]
                if not istable(targetRank) then 
                    return nadmin:Notify(ply, nadmin.colors.red, "Selected rank to edit doesn't exist.")
                end
            end

            local rankDetails = net.ReadTable()

            if istable(targetRank) then 

            else 

            end
        elseif managing == 1 then -- permissions
        
        elseif managing == 2 then -- members

        end
        
        -- local newRank = {}
        -- newRank.identifier = editor.idEntry:GetText()
        -- newRank.title = editor.titleEntry:GetText()
        -- newRank.access = editor.selectedAccess
        -- newRank.immunity = tonumber(editor.immunityEntry:GetText())
        -- newRank.color = editor.colorPicker:GetColor()
        -- newRank.icon = editor.iconPreview:GetImage()

        -- local _, inheritedRank = editor.inheritFrom:GetSelected()
        -- if not isstring(inheritedRank) and isstring(editor.inheritFrom.customDataValue) then 
        --     inheritedRank = editor.inheritFrom.customDataValue
        -- end
        -- if isstring(inheritedRank) and istable(nadmin.ranks[inheritedRank]) then 
        --     newRank.inheritFrom = inheritedRank
        -- end

        -- if editor.autoPromotionToggle:GetChecked() then 
        --     newRank.autoPromote = {enabled = true}
        --     newRank.autoPromote.when = nadmin:ParseTime(editor.autoPromoteAfter:GetText())

        --     local _, promotionRank = editor.autoPromoteTo:GetSelected()
        --     if not isstring(promotionRank) and isstring(editor.autoPromoteTo.customDataValue) then 
        --         promotionRank = editor.autoPromoteTo.customDataValue
        --     end
        --     if isstring(promotionRank) and istable(nadmin.ranks[promotionRank]) then 
        --         newRank.autoPromote.rank = promotionRank
        --     end
        -- end
    end)
end