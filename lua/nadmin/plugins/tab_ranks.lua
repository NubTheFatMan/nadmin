if CLIENT then
    nadmin.menu:RegisterTab({
        title = "Ranks",
        sort = 1,
        content = function(parent, data)
            local localRank = LocalPlayer():GetRank()

            local manager = vgui.Create("NadminTabMenu", parent)
            manager:SetPos(4, 4)
            manager:SetSize(parent:GetWide() * 1/5, parent:GetTall() - 4)
            manager:UseVerticalTabs(true)
            manager:SetColor(nadmin.colors.gui.theme)
            manager:GetContentPanel():SetVisible(false)

            local editor = vgui.Create("DPanel", parent)
            editor:SetPos(manager:GetWide() + 4, 4)
            editor:SetSize(parent:GetWide() - manager:GetWide() - 4, parent:GetTall() - 4)
            function editor:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, 4, 4, w - 4, h - 4, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end

            local configIcon = Material("icon16/cog.png")
            local generalConfig = vgui.Create("DPanel", editor)
            generalConfig:SetPos(8, 8)
            generalConfig:SetSize(editor:GetWide() * 3/5 - 10, editor:GetTall() * 2/3 - 16)
            function generalConfig:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, 0, 0, w, 28, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                surface.SetMaterial(configIcon)
                surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRect(4, 6, 16, 16)
                
                draw.SimpleText("Information", "nadmin_derma", 24, 14, nadmin:TextColor(nadmin.colors.gui.theme), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
            end

            local save = vgui.Create("NadminButton", generalConfig)
            save:SetIcon("icon16/disk.png")
            save:SetSize(24, 24)
            save:SetPos(generalConfig:GetWide() - save:GetWide() - 4, 2)
            save:SetText("")
            save:SetToolTip("Save Rank")

            local delete = vgui.Create("NadminButton", generalConfig)
            delete:SetIcon("icon16/bin_closed.png")
            delete:SetSize(24, 24)
            delete:SetPos(generalConfig:GetWide() - save:GetWide() - delete:GetWide() - 8, 2)
            delete:SetText("")
            delete:SetColor(nadmin.colors.gui.red)
            delete:SetToolTip("Delete Rank")



            local wrenchIcon = Material("icon16/wrench.png")
            local permissionsConfig = vgui.Create("DPanel", editor)
            local permSearch = vgui.Create("NadminTextEntry", permissionsConfig)
            local x = generalConfig:GetWide() + 14
            permissionsConfig:SetPos(x, 8)
            permissionsConfig:SetSize(editor:GetWide() - x - 4, editor:GetTall() - 12)
            function permissionsConfig:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, 0, 0, w, 28, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                surface.SetMaterial(wrenchIcon)
                surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRect(4, 6, 16, 16)
                
                draw.SimpleText("Permissions", "nadmin_derma", 24, 14, nadmin:TextColor(nadmin.colors.gui.theme), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if not isnumber(self.textWidth) then 
                    surface.SetFont("nadmin_derma")
                    
                    self.textWidth = surface.GetTextSize("Permissions")

                    local xPos = 40 + self.textWidth

                    permSearch:SetPos(xPos, 2)
                    permSearch:SetWide(self:GetWide() - xPos - 2)
                end
            end

            permSearch:SetSize(permissionsConfig:GetWide() / 2, 24)
            permSearch:SetPos(40, 2)
            permSearch:SetPlaceholderText("Search for Permission")
            permSearch:SetColor(nadmin.colors.gui.theme)

            
            local userIcon = Material("icon16/user.png")
            local memberManager = vgui.Create("DPanel", editor)
            local searchInput = vgui.Create("NadminTextEntry", memberManager) -- We are putting this here since the membermanager will need to reference it, otherwise it would be with its setters
            memberManager:SetPos(8, generalConfig:GetTall() + 14)
            memberManager:SetSize(generalConfig:GetWide(), editor:GetTall() - generalConfig:GetTall() - 18)
            function memberManager:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, 0, 0, w, 28, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                surface.SetMaterial(userIcon)
                surface.SetDrawColor(255, 255, 255)
                surface.DrawTexturedRect(4, 6, 16, 16)
                
                draw.SimpleText("Members", "nadmin_derma", 24, 14, nadmin:TextColor(nadmin.colors.gui.theme), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)

                if not isnumber(self.textWidth) then 
                    surface.SetFont("nadmin_derma")
                    
                    self.textWidth = surface.GetTextSize("Members")

                    local xPos = 40 + self.textWidth

                    searchInput:SetPos(xPos, 2)
                    searchInput:SetWide(self:GetWide() - xPos - 68)
                end
            end

            local addMember = vgui.Create("NadminButton", memberManager)
            addMember:SetIcon("icon16/user_add.png")
            addMember:SetSize(24, 24)
            addMember:SetPos(memberManager:GetWide() - addMember:GetWide() - 4, 2)
            addMember:SetText("")
            addMember:SetToolTip("Add a Member to this Rank")
            addMember:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 45))

            local searchBtn = vgui.Create("NadminButton", memberManager)
            searchBtn:SetIcon("icon16/magnifier.png")
            searchBtn:SetSize(24, 24)
            searchBtn:SetPos(memberManager:GetWide() - addMember:GetWide() - searchBtn:GetWide() - 16, 2)
            searchBtn:SetText("")
            searchBtn:SetToolTip("Search for member in rank")
            searchBtn:SetColor(addMember:GetColor())

            searchInput:SetSize(memberManager:GetWide() / 2, 24)
            searchInput:SetPos(40, 2)
            searchInput:SetPlaceholderText("Search for Member")
            searchInput:SetColor(nadmin.colors.gui.theme)


            -- General configuration of the rank 
            local configErrors = {}

            local configContainer = vgui.Create("NadminScrollPanel", generalConfig)
            configContainer:SetPos(0, 34)
            configContainer:SetSize(generalConfig:GetWide(), generalConfig:GetTall() - 34)


            local inheritContainer = vgui.Create("NadminPanel", configContainer)
            inheritContainer:Dock(TOP)
            inheritContainer:DockPadding(4, 0, 4, 0)
            inheritContainer:SetTall(28)
            
            local inheritLabel = vgui.Create("DLabel", inheritContainer)
            inheritLabel:SetFont("nadmin_derma")
            inheritLabel:SetText("Inherit From:")
            inheritLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            inheritLabel:SizeToContentsX()
            inheritLabel:SetTall(inheritContainer:GetTall())
            inheritLabel:Dock(LEFT)

            local inheritSelect = vgui.Create("NadminComboBox", inheritContainer)
            inheritSelect:Dock(FILL)
            inheritSelect:DockMargin(4, 0, 0, 0)
            inheritSelect:SetSortItems(false)
            inheritSelect:SetValue("None - Not functional, select to copy from a rank")

            local ranks = {}
            for id, rank in pairs(nadmin.ranks) do 
                if localRank.access < nadmin.access.owner then -- The owner rank shouldn't have any restrictions on creating ranks
                    if rank.access > localRank.access then continue end 
                    if rank.access == localRank.access and rank.immunity >= localRank.immunity then continue end
                end 

                table.insert(ranks, rank)
            end
            table.sort(ranks, function(a, b) return a.access == b.access and a.immunity < b.immunity or a.access < b.access end)
            for i, rank in ipairs(ranks) do 
                inheritSelect:AddChoice(rank.title .. " (" .. rank.id .. ")", rank.id)
            end


            local inheritDiv = vgui.Create("NadminPanel", configContainer)
            inheritDiv:Dock(TOP)
            inheritDiv:DockMargin(4, 8, 4, 0)
            inheritDiv:SetTall(3)
            inheritDiv:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))


            local idContainer = vgui.Create("NadminPanel", configContainer)
            idContainer:Dock(TOP)
            idContainer:DockPadding(4, 0, 4, 0)
            idContainer:DockMargin(0, 8, 0, 0)
            idContainer:SetTall(inheritContainer:GetTall())

            
            local idLabel = vgui.Create("DLabel", idContainer)
            idLabel:SetFont("nadmin_derma")
            idLabel:SetText("ID:")
            idLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            idLabel:SizeToContentsX()
            idLabel:SetTall(idContainer:GetTall())
            idLabel:Dock(LEFT)

            local idEntry = vgui.Create("NadminTextEntry", idContainer)
            idEntry:Dock(FILL)
            idEntry:DockMargin(4, 0, 0, 0)
            idEntry:SetPlaceholderText("True identifier of the rank")
            function idEntry:ErrorCondition()
                local trim = string.Trim(self:GetText())
                if trim == "" then return "Cannot be blank" end 
                if trim == nadmin.null_rank.id then return self:GetText() .. " is reserved" end

                for id, rank in pairs(nadmin.ranks) do 
                    if trim == id then 
                        return "A rank with this ID exists"
                    end
                end
            end
            function idEntry:WarningCondition() 
                if input.IsKeyDown(KEY_LSHIFT) or input.IsKeyDown(KEY_RSHIFT) then return "No capitals allowed" end
            end

            -- We don't want spaces or capitals in the ID. Nobody except for people who can manage ranks will see the ID anyway, this is just an identifier for the mod internally
            function idEntry:OnChange()
                local caret = self:GetCaretPos()
                self:SetText(string.Replace(string.lower(self:GetText()), " ", "_"))
                self:SetCaretPos(caret)

                -- If the ID is currently invalid, then we need to disable the button with some feedback 
                if self:IsErrored() and not table.HasValue(configErrors, "id") then 
                    table.insert(configErrors, "id")
                elseif table.HasValue(configErrors, "id") and not self:IsErrored() then 
                    table.RemoveByValue(configErrors, "id")
                end
            end


            local titleContainer = vgui.Create("NadminPanel", configContainer)
            titleContainer:Dock(TOP)
            titleContainer:DockPadding(4, 0, 4, 0)
            titleContainer:DockMargin(0, 4, 0, 0)
            titleContainer:SetTall(idContainer:GetTall())
            
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
                if string.Trim(self:GetText()) == "" then return "Cannot be blank" end 
            end
            function titleEntry:OnChange()
                if self:IsErrored() and not table.HasValue(configErrors, "title") then 
                    table.insert(configErrors, "title")
                elseif table.HasValue(configErrors, "title") and not self:IsErrored() then 
                    table.RemoveByValue(configErrors, "title")
                end
            end


            local nameDiv = vgui.Create("NadminPanel", configContainer)
            nameDiv:Dock(TOP)
            nameDiv:DockMargin(4, 8, 4, 0)
            nameDiv:SetTall(3)
            nameDiv:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))


            local accessContainer = vgui.Create("NadminPanel", configContainer)
            accessContainer:Dock(TOP)
            accessContainer:DockPadding(4, 0, 4, 0)
            accessContainer:DockMargin(0, 4, 0, 0)
            accessContainer:SetTall(idContainer:GetTall())
            
            local accessLabel = vgui.Create("DLabel", accessContainer)
            accessLabel:SetFont("nadmin_derma")
            accessLabel:SetText("Access Level:")
            accessLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            accessLabel:SizeToContentsX()
            accessLabel:SetTall(accessContainer:GetTall())
            accessLabel:Dock(LEFT)
            
            local accessSelect = vgui.Create("NadminComboBox", accessContainer)
            accessSelect:Dock(FILL)
            accessSelect:DockMargin(4, 0, 0, 0)
            accessSelect:SetSortItems(false)
            
            local accessList = {
                {"Restricted - Entity blacklist becomes a whitelist",           nadmin.access.restricted},
                {"Default - Given to newcomers, only one rank can have this",   nadmin.access.default   },
                {"User - Equal to Default, except has to be assigned manually", nadmin.access.user      },
                {"Administrator - Moderators of the server",                    nadmin.access.admin     },          
                {"SuperAdministrators - Almost equal to Owner, but not quite",  nadmin.access.superadmin},     
                {"Owner - Highest power, no restrictions",                      nadmin.access.owner     }          
            }
            for i, a in ipairs(accessList) do 
                if a[2] <= localRank.access then 
                    accessSelect:AddChoice(a[1], a[2], a[2] == nadmin.access.user)
                end
            end

            local imContainer = vgui.Create("NadminPanel", configContainer)
            imContainer:Dock(TOP)
            imContainer:DockPadding(4, 0, 4, 0)
            imContainer:DockMargin(0, 8, 0, 0)
            imContainer:SetTall(idContainer:GetTall())
            
            local imLabel = vgui.Create("DLabel", imContainer)
            imLabel:SetFont("nadmin_derma")
            imLabel:SetText("Immunity:")
            imLabel:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            imLabel:SizeToContentsX()
            imLabel:SetTall(imContainer:GetTall())
            imLabel:Dock(LEFT)
            
            local imEntry = vgui.Create("NadminTextEntry", imContainer)
            imEntry:Dock(FILL)
            imEntry:DockMargin(4, 0, 0, 0)
            imEntry:SetPlaceholderText("Immunity to other ranks")
            imEntry:SetNumeric(true)
            function imEntry:ErrorCondition() 
                if self:GetText() == "" then return "Immunity must be a number" end
                
                local _, access = accessSelect:GetSelected()
                if access == localRank.access then 
                    if tonumber(self:GetText()) >= localRank.access then return "You can't set a rank higher than yourself" end
                end
            end

            
            local accessDiv = vgui.Create("NadminPanel", configContainer)
            accessDiv:Dock(TOP)
            accessDiv:DockMargin(4, 8, 4, 0)
            accessDiv:SetTall(3)
            accessDiv:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))


            local iconContainer = vgui.Create("NadminPanel", configContainer)
            iconContainer:Dock(TOP)
            iconContainer:DockPadding(4, 0, 4, 0)
            iconContainer:DockMargin(0, 8, 0, 0)
            iconContainer:SetTall(idContainer:GetTall())
            
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
            iconPreview:SetWide(iconContainer:GetTall() - 8)

            local iconEntry = vgui.Create("NadminTextEntry", iconContainer)
            iconEntry:Dock(FILL)
            iconEntry:DockMargin(4, 0, 0, 0)
            iconEntry:SetPlaceholderText("Icon Search (Type to open browser, or click ->)")

            local iconBrowser = vgui.Create("NadminScrollPanel", configContainer)
            iconBrowser:Dock(TOP)
            iconBrowser:DockMargin(4, 4, 4, 0)
            iconBrowser:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            iconBrowser:SetTall(150)
            iconBrowser:SetVisible(false)
            local vbar = iconBrowser:GetVBar()

            local ibToggle = vgui.Create("NadminButton", iconContainer)
            ibToggle:Dock(RIGHT)
            ibToggle:DockMargin(4, 0, 0, 0)
            ibToggle:SetText("")
            ibToggle:SetToolTip("Show icon browser (or start searching)")
            ibToggle:SetWide(iconContainer:GetTall())
            ibToggle:SetIcon("icon16/application_side_expand.png")
            function ibToggle:DoClick() 
                if iconBrowser:IsVisible() then 
                    iconBrowser:SetVisible(false)
                    ibToggle:SetToolTip("Show icon browser (or start searching)")
                    ibToggle:SetIcon("icon16/application_side_expand.png")
                else 
                    iconBrowser:SetVisible(true)
                    ibToggle:SetToolTip("Hide icon browser")
                    ibToggle:SetIcon("icon16/application_side_contract.png")
                end

                configContainer:InvalidateChildren()
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
                iconBrowser.tempPanel:SetWide(configContainer:GetWide() - 8)
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
                    ibToggle:SetToolTip("Hide icon browser")
                    ibToggle:SetIcon("icon16/application_side_contract.png")
                    configContainer:InvalidateChildren()
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


            local iconDiv = vgui.Create("NadminPanel", configContainer)
            iconDiv:Dock(TOP)
            iconDiv:DockMargin(4, 8, 4, 0)
            iconDiv:SetTall(3)
            iconDiv:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))


            local apToggle = vgui.Create("NadminCheckBox", configContainer)
            apToggle:SetText("Auto Promotion")
            apToggle:SetTall(idContainer:GetTall())
            apToggle:Dock(TOP)
            apToggle:DockMargin(4, 8, 4, 0)
            apToggle:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 15))
            apToggle:SetStyle(nadmin.STYLE_SWITCH)

            local apContainer = vgui.Create("NadminPanel", configContainer)
            apContainer:Dock(TOP)
            apContainer:DockMargin(4, 0, 4, 4)
            apContainer:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 15))
            apContainer:SetTall(idContainer:GetTall() * 3 + 16)


            local apToContainer = vgui.Create("NadminPanel", apContainer)
            apToContainer:Dock(TOP)
            apToContainer:DockPadding(4, 0, 4, 0)
            apToContainer:DockMargin(0, 4, 0, 0)
            apToContainer:SetColor(apContainer:GetColor())
            apToContainer:SetTall(idContainer:GetTall())
            
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
            apToSelect:AddChoice("Rank", nil, true)


            local apAfterContainer = vgui.Create("NadminPanel", apContainer)
            apAfterContainer:Dock(TOP)
            apAfterContainer:DockPadding(4, 0, 4, 0)
            apAfterContainer:DockMargin(0, 4, 0, 0)
            apAfterContainer:SetColor(apContainer:GetColor())
            apAfterContainer:SetTall(idContainer:GetTall())
            
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
            function apAfterEntry:ErrorCondition() 
                -- Should only error if auto promotion is enabled
                if apToggle:GetChecked() then 
                    if string.Trim(self:GetText()) == "" then return "Cannot be blank" end 

                    local time = nadmin:ParseTime(self:GetText())
                    if not isnumber(time) then return "Invalid time" end
                    if time <= 0 then return "Must be at least 1 second" end
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


            local apTime = vgui.Create("NadminCheckBox", apContainer)
            apTime:Dock(TOP)
            apTime:DockMargin(4, 4, 4, 0)
            apTime:SetText("Time based on overall time")
            apTime:SetTall(idContainer:GetTall())
            apTime:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 10))
            apTime:SetStyle(nadmin.STYLE_SWITCH)

            apContainer:SetVisible(false)
            function apToggle:OnChecked(checked)
                if checked then 
                    apContainer:SetVisible(true)
                else 
                    apContainer:SetVisible(false)
                end
                configContainer:InvalidateChildren()
            end

            
            -- Saving ranks and save button erroring 
            save.normalPaint = save.Paint 
            function save:Paint(w, h)
                save:normalPaint(w, h)

                -- We are going to change the color if there are any errors
                if #configErrors > 0 and self:GetColor() ~= nadmin.colors.gui.warning then 
                    self:SetColor(nadmin.colors.gui.warning)
                    self:SetTooltip("Cannot save - has errors")
                elseif #configErrors == 0 and self:GetColor() ~= nadmin.colors.gui.blue then 
                    self:SetColor(nadmin.colors.gui.blue)
                    self:SetTooltip("Save / Create rank")
                end
            end

            function save:DoClick()
                -- Values that don't need validation, we just need to send them to the server
                local _, inheritFrom = inheritSelect:GetSelected() 
                local _, accessLevel = accessSelect:GetSelected() 
                local icon           = iconPreview:GetImage()
                local apEnabled      = apToggle:GetChecked()
                local _, apRank      = apToSelect:GetSelected()
                local apTimeBasis    = apTime:GetChecked()
                
                -- ID validation
                local id = string.Trim(idEntry:GetText())
                if id == "" then return end
                if string.find(id, " ", 1, true) then string.Replace(id, " ", "_") end
                if string.upper(id) ~= id then id = string.lower(id) end

                -- Title validation 
                local title = string.Trim(titleEntry:GetText())
                if title == "" then return end

                -- Immunity validation 
                local immunity = tonumber(imEntry:GetText())
                if not isnumber(immunity) then return end 
                if accessLevel == localRank.access and immunity > localRank.immunity then return end 

                -- Auto promo after validation
                local apAfter = nadmin:ParseTime(apAfterEntry:GetText())
                local saveApAfter = true
                if not isnumber(apAfter) then saveApAfter = false end
                if saveApAfter and apAfter < 1 then saveApAfter = false end
                if apEnabled and not saveApAfter then return end
                
                nadmin:Notify(nadmin.colors.blue, "Saved!")
            end


            local newRank = manager:AddTab("New Rank", function()
                
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
                local rankTab = manager:AddTab(rank.title, function()
                
                end)
                rankTab:SetSelectedColor(rank.color)
                rankTab:SetUnselectedTextColor(rank.color)
                rankTab:SetIcon(rank.icon)
            end
        end
    })
else
    
end

nadmin:RegisterPerm({
    title = "Manage Ranks"
})
nadmin:RegisterPerm({
    title = "Erase Player Data"
})