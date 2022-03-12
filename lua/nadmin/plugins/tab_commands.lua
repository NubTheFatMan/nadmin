if CLIENT then
    local selectedCommand = NULL 
    local cmdInfo = {}

    function showCommandInfo()
        if not istable(selectedCommand) then return end

        local parent = NULL 

        if IsValid(cmdInfo.desc) then 
            parent = cmdInfo.desc:GetParent()
            cmdInfo.desc:SetText(selectedCommand.description)
        end

        if not IsValid(parent) then return end

        if istable(cmdInfo.args) then 
            for i, arg in ipairs(cmdInfo.args) do 
                if IsValid(arg) then arg:Remove() end 
            end
        end
        cmdInfo.args = {}
        if istable(selectedCommand.advUsage) then 
            local col = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
            for i, us in ipairs(selectedCommand.advUsage) do 
                local arg
                if us.type == "player" then
                    arg = vgui.Create("NadminComboBox", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetValue("Select a player...")

                    local mode = nadmin.MODE_ALL
                    local cs = true
                    if isnumber(us.targetMode) then mode = us.targetMode end
                    if isbool(us.canTargetSelf) then cs = us.canTargetSelf end

                    local plys = {}
                    for i, ply in ipairs(player.GetAll()) do
                        if LocalPlayer() == ply and not cs then continue end

                        if mode == nadmin.MODE_ALL then table.insert(plys, ply) continue end

                        if mode == nadmin.MODE_SAME then
                            if LocalPlayer():BetterThanOrEqual(ply) then
                                table.insert(plys, ply)
                            end
                        elseif mode == nadmin.MODE_BELOW then
                            if LocalPlayer() == ply and cs then table.insert(plys, ply) continue end
                            if LocalPlayer():BetterThan(ply) then
                                table.insert(plys, ply)
                            end
                        end
                    end

                    table.sort(plys, function(a, b) return a:Nick() < b:Nick() end)

                    for i, ply in ipairs(plys) do
                        arg:AddChoice(ply:Nick() .. " (" .. ply:SteamID() .. ")", ply:SteamID())
                    end

                    function arg:OnSelect(index, value, data)
                        self.value = data
                    end
                elseif us.type == "dropdown" then
                    arg = vgui.Create("NadminComboBox", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetValue("Select from list...")
                    arg:SetSortItems(false)

                    local options = {}
                    if isstring(us.options) then
                        local r = LocalPlayer():GetRank()
                        if us.options == "ranks_below" then
                            for x, rank in pairs(nadmin.ranks) do
                                if rank.immunity < r.immunity then
                                    table.insert(options, rank)
                                end
                            end
                        elseif us.options == "ranks_same" then
                            for x, rank in pairs(nadmin.ranks) do
                                if rank.immunity <= r.immunity then
                                    table.insert(options, rank)
                                end
                            end
                        elseif us.options == "ranks" then
                            for x, rank in pairs(nadmin.ranks) do
                                table.insert(options, rank)
                            end
                        end
                    elseif istable(arg.type) then
                        options = arg.options
                    end

                    table.sort(options, function(a, b) if istable(a) and istable(b) then return a.immunity < b.immunity else return a < b end end)

                    for i, op in ipairs(options) do
                        if istable(op) then
                            arg:AddChoice(op.title .. " (" .. op.id .. ")", op.id)
                        else
                            arg:AddChoice(op, op)
                        end
                    end
                    function arg:OnSelect(index, value, data)
                        self.value = data
                    end
                elseif us.type == "checkbox" then
                    arg = vgui.Create("NadminCheckBox", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetText(us.text)
                    arg.value = "0"

                    function arg:OnChecked(checked)
                        self.value = (checked and "1" or "0")
                    end
                elseif us.type == "string" then
                    arg = vgui.Create("NadminTextEntry", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetPlaceholderText(us.text)
                    arg:SetUpdateOnType(true)
                    arg.value = ""

                    function arg:OnValueChange(val)
                        self.value = val
                    end
                elseif us.type == "number" then
                    arg = vgui.Create("NadminTextEntry", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetPlaceholderText(us.text)
                    arg:SetUpdateOnType(true)
                    arg:SetNumeric(true)

                    function arg:ErrorCondition() return self:GetText() == "" end

                    function arg:OnValueChange(val)
                        if self:IsErrored() then self.value = nil return end
                        self.value = val
                    end
                elseif us.type == "time" then
                    arg = vgui.Create("NadminTextEntry", parent)
                    arg:SetSize(parent:GetWide() - 8, 32)
                    arg:SetColor(col)
                    arg:SetPlaceholderText(us.text)
                    arg:SetUpdateOnType(true)

                    function arg:ErrorCondition()
                        return not isnumber(nadmin:ParseTime(self:GetText()))
                    end

                    function arg:OnChange()
                        local val = self:GetText()
                        if self:IsErrored() then self.value = nil return end
                        self.value = tostring(nadmin:ParseTime(self:GetText()))
                    end

                    arg.normalPaint = arg.Paint
                    function arg:Paint(w, h)
                        self:normalPaint(w, h)

                        if not self:IsErrored() then
                            surface.SetFont(self:GetFont())

                            local wid = surface.GetTextSize(self:GetText())
                            draw.SimpleText(nadmin:TimeToString(nadmin:ParseTime(self:GetText()), true), self:GetFont(), wid + 8, h/2, nadmin:AlphaColor(self:GetTextColor(), 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                        end
                    end
                end

                if IsValid(arg) then
                    arg:Dock(TOP)
                    arg:DockMargin(4, 4, 4, 0)
                    table.insert(cmdInfo.args, arg)
                end
            end
        else 
            local noArgs = vgui.Create("NadminLabel", parent)
            noArgs:Dock(TOP)
            noArgs:DockMargin(4, 12, 4, 0)
            noArgs:SetText("This command has no arguments.")
            table.insert(cmdInfo.args, noArgs)
        end
    end

    nadmin.menu:RegisterTab({
        title = "Commands",
        forcedPriv = true,
        content = function(parent, data)
            local categories = {}
            local commands = {}
            for id, cmd in pairs(nadmin.commands) do
                if not LocalPlayer():HasPerm(id) then continue end

                if not table.HasValue(categories, cmd.category) then table.insert(categories, cmd.category) end
                table.insert(commands, cmd)
            end

            table.sort(categories, function(a, b) return a < b end)
            table.sort(commands, function(a, b) return a.title < b.title end)

            local cmds = vgui.Create("NadminTabMenu", parent)
            cmds:SetPos(4, 4)
            cmds:SetSize(parent:GetWide() * 4/5, parent:GetTall() - 4)
            cmds:SetTabWidth(cmds:GetWide() * 1/4)
            cmds:UseVerticalTabs(true)
            cmds:SetColor(nadmin.colors.gui.theme)
            cmds:GetContentPanel():SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            for i, cat in ipairs(categories) do 
                cmds:AddTab(cat, function(scrollPanel) 
                    local first = true
                    for x, cmd in ipairs(commands) do 
                        if cmd.category == cat then 
                            local btn = vgui.Create("NadminSimpleButton", scrollPanel)
                            btn:Dock(TOP)
                            btn:DockMargin(4, 4, 4, 0)
                            btn:SetTall(46)
                            btn:SetText("")
                            btn.baseColor = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                            if first then 
                                first = false 
                                selectedCommand = cmd
                                showCommandInfo()
                            end

                            function btn:DoClick() 
                                selectedCommand = cmd
                                showCommandInfo()
                            end

                            btn.title = cmd.title
                            btn.desc = cmd.description
                            btn.id = cmd.id

                            btn.smallFont = "nadmin_derma_xs"
                            function btn:Paint(w, h)
                                local col = self.baseColor
                                local tc = nadmin:TextColor(col)
                                if self.id == selectedCommand.id then 
                                    col = nadmin.colors.gui.blue 
                                    tc = nadmin:TextColor(col)
                                end

                                if self:IsHovered() then 
                                    col = nadmin:BrightenColor(col, 15)
                                end
                                draw.RoundedBox(0, 0, 0, w, h, col)

                                draw.Text({
                                    text = self.title,
                                    font = self:GetFont(),
                                    color = tc,
                                    pos = {4, 4}
                                })

                                draw.RoundedBox(0, 0, 24, w, 2, nadmin:DarkenColor(col, 15))

                                draw.Text({
                                    text = self.desc,
                                    font = self.smallFont,
                                    color = tc,
                                    pos = {4, h - 4},
                                    yalign = TEXT_ALIGN_BOTTOM
                                })
                            end
                        end
                    end
                end, i == 1)
            end

            local controls = vgui.Create("NadminTabMenu", parent)
            controls:SetPos(cmds:GetWide() + 8, 4)
            controls:SetSize(parent:GetWide() - cmds:GetWide() - 12, parent:GetTall() - 44)
            controls:SetColor(nadmin.colors.gui.theme)
            controls:GetContentPanel():SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            local run = vgui.Create("NadminButton", parent)
            run:SetPos(cmds:GetWide() + 8, parent:GetTall() - 36)
            run:SetSize(controls:GetWide(), 32)
            run:SetText("Run Command")
            
            local args = controls:AddTab("Args", function(par)
                run:SetVisible(true)
                controls:SetTall(parent:GetTall() - 44)

                if IsValid(cmdInfo.desc) then cmdInfo.desc:Remove() end 

                cmdInfo.desc = vgui.Create("NadminLabel", par)
                cmdInfo.desc:Dock(TOP)
                cmdInfo.desc:DockMargin(4, 4, 4, 0)
                cmdInfo.desc:SetText("Select a command :^)")

                showCommandInfo()

                run:SetText("Run Command")
            end, true)
            args:SetIcon("icon16/comment.png")

            local restrictions = controls:AddTab("Limits", function(par) 
                run:SetVisible(false)
                controls:SetTall(parent:GetTall() - 8)

                local notImplemented = vgui.Create("NadminLabel", par)
                notImplemented:Dock(TOP)
                notImplemented:DockMargin(4, 4, 4, 0)
                notImplemented:SetText("This feature is not yet implemented.")
            end)
            restrictions:SetIcon("icon16/comment_delete.png")

            function run:DoClick() 
                if istable(selectedCommand) then 
                    -- Just gonna concatenate this in the console, so I have the first thing as nadmin
                    local concmd = {"nadmin", selectedCommand.call}

                    if istable(cmdInfo) and istable(cmdInfo.args) then 
                        for i, arg in ipairs(cmdInfo.args) do 
                            if arg.value ~= nil then 
                                table.insert(concmd, tostring(arg.value))
                            end
                        end
                    end
                    LocalPlayer():ConCommand(table.concat(concmd, " "))
                end
            end
        end
    })
end