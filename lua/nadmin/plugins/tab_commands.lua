if CLIENT then
    nadmin.menu:RegisterTab({
        title = "Commands",
        forcedPriv = true,
        content = function(parent, data)
            local w = math.Round(parent:GetWide()/5)
            local h = parent:GetTall()

            local categ = nadmin.vgui:DScrollPanel(nil, {w, h}, parent)
            categ:GetCanvas():DockPadding(0, 0, 0, 4)

            local controls = nadmin.vgui:DPanel({parent:GetWide() - w, 0}, {w, h}, parent)

            local run = nadmin.vgui:DButton({4, h - 32}, {controls:GetWide() - 4, 32}, controls)
            run:SetText("Run")
            run:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            run:SetIcon("icon16/tick.png")
            run.normalPaint = run.Paint
            function run:ErrorCondition() end
            function run:Paint(w, h)
                local err = self:ErrorCondition()
                local col = err and nadmin.colors.red or nadmin:BrightenColor(nadmin.colors.gui.theme, 25)
                if err then
                    self:SetMouseInputEnabled(false)
                else
                    self:SetMouseInputEnabled(true)
                end

                self:SetColor(col)
                self:normalPaint(w, h)
            end

            local options = nadmin.vgui:DScrollPanel({4, 4}, {controls:GetWide() - 4, controls:GetTall() - run:GetTall() - 8}, controls)
            options:GetCanvas():DockPadding(0, 0, 0, 4)
            options:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            local desc = nadmin.vgui:AdvancedDLabel(nil, "Please select a command.", options, true)
            desc:Dock(TOP)
            desc:DockMargin(4, 4, 4, 0)

            local list = nadmin.vgui:DScrollPanel({categ:GetWide(), 0}, {parent:GetWide() - w * 2, h}, parent)
            list:GetCanvas():DockPadding(0, 0, 0, 4)
            list:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            local selCom
            if istable(data) then selCom = data.command end

            local categories = {}
            local commands = {}

            local myRank = LocalPlayer():GetRank()
            local perms = myRank.privileges
            for id, cmd in pairs(nadmin.commands) do
                if not LocalPlayer():HasPerm(id) then continue end

                if not table.HasValue(categories, cmd.category) then table.insert(categories, cmd.category) end
                table.insert(commands, cmd)
            end

            table.sort(categories, function(a, b) return a < b end)
            table.sort(commands, function(a, b) return a.title < b.title end)

            local function drawCmd(com)
                options:Clear()

                local cmd
                for i, c in ipairs(commands) do
                    if c.id == com then
                        cmd = c
                        break
                    end
                end

                if istable(cmd) then
                    local args = {}
                    local desc = nadmin.vgui:AdvancedDLabel(nil, cmd.description, options, true)
                    desc:Dock(TOP)
                    desc:DockMargin(4, 4, 4, 4)

                    if istable(cmd.advUsage) then
                        for i, us in ipairs(cmd.advUsage) do
                            -- if not table.HasValue({"checkbox"}, us.type) then
                            --     local l = nadmin.vgui:AdvancedDLabel(nil, us.text .. ":", options, true)
                            --     l:Dock(TOP)
                            --     l:DockMargin(4, 8, 4, 0)
                            -- end

                            local arg
                            if us.type == "player" then
                                arg = nadmin.vgui:DComboBox(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
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
                                arg = nadmin.vgui:DComboBox(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
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
                                arg = nadmin.vgui:DCheckBox(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
                                arg:SetText(us.text)
                                arg.value = "0"

                                function arg:OnChecked(checked)
                                    self.value = (checked and "1" or "0")
                                end
                            elseif us.type == "string" then
                                arg = nadmin.vgui:DTextEntry(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
                                arg:SetPlaceholderText(us.text)
                                arg:SetUpdateOnType(true)
                                arg.value = ""

                                function arg:OnValueChange(val)
                                    self.value = val
                                end
                            elseif us.type == "number" then
                                arg = nadmin.vgui:DTextEntry(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
                                arg:SetPlaceholderText(us.text)
                                arg:SetUpdateOnType(true)
                                arg:SetNumeric(true)

                                function arg:ErrorCondition() return self:GetText() == "" end

                                function arg:OnValueChange(val)
                                    if self:GetErrored() then self.value = nil return end
                                    self.value = val
                                end
                            elseif us.type == "time" then
                                arg = nadmin.vgui:DTextEntry(nil, {options:GetWide() - 8, 32}, options)
                                arg:SetColor(nadmin.colors.gui.theme)
                                arg:SetPlaceholderText(us.text)
                                arg:SetUpdateOnType(true)

                                function arg:ErrorCondition()
                                    return not isnumber(nadmin:ParseTime(self:GetText()))
                                end

                                function arg:OnChange()
                                    local val = self:GetText()
                                    if self:GetErrored() then self.value = nil return end
                                    self.value = tostring(nadmin:ParseTime(self:GetText()))
                                end

                                arg.normalPaint = arg.Paint
                                function arg:Paint(w, h)
                                    self:normalPaint(w, h)

                                    if not self:GetErrored() then
                                        surface.SetFont(self:GetFont())

                                        local wid = surface.GetTextSize(self:GetText())
                                        draw.SimpleText(nadmin:TimeToString(nadmin:ParseTime(self:GetText()), true), self:GetFont(), wid + 8, h/2, nadmin:AlphaColor(self:GetTextColor(), 100), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
                                    end
                                end
                            end

                            if IsValid(arg) then
                                arg:Dock(TOP)
                                arg:DockMargin(4, 4, 4, 0)
                                table.insert(args, arg)
                            end
                        end

                        function run:ErrorCondition()
                            local errored = false
                            for i, arg in ipairs(args) do
                                if not isstring(arg.value) then errored = true break end
                            end
                            return errored
                        end

                        function run:DoClick()
                            if not self:ErrorCondition() then
                                local vars = {}
                                for i, arg in ipairs(args) do
                                    table.insert(vars, arg.value)
                                end
                                LocalPlayer():ConCommand("nadmin " .. cmd.call .. " \"" .. table.concat(vars, "\" \"") .. "\"")
                            end
                        end
                    else
                        local l = nadmin.vgui:AdvancedDLabel(nil, "This command has no arguments.", options, true)
                        l:Dock(TOP)
                        l:DockMargin(4, 4, 4, 0)

                        function run:DoClick() LocalPlayer():ConCommand("nadmin " .. cmd.call) end
                        function run:ErrorCondition() end
                    end
                else
                    local reason = "The command you have selected doesn't exist."
                    if nadmin.commands[com] then reason = "You don't have permission to use this command." end

                    local desc = nadmin.vgui:AdvancedDLabel(nil, reason, options, true)
                    desc:Dock(TOP)
                    desc:DockMargin(4, 4, 4, 0)

                    function run:DoClick() end
                    function run:ErrorCondition() end
                end
            end

            local function drawCmds(sel, com)
                list:Clear()

                if not isstring(sel) then sel = categories[1] end

                local h = 46
                local delay = 0.03
                local dur = 0.075

                local ind = -1
                local cmds = {}
                for i, command in ipairs(commands) do
                    if command.category ~= sel then continue end

                    ind = ind + 1

                    local y = (h * ind) + (ind * 4) + 4
                    cmds[ind] = nadmin.vgui:DButton({list:GetWide()/2, y}, {list:GetWide() - 8, h}, list)

                    local cmd = cmds[ind]
                    cmd:MoveTo(4, y, dur, ind * delay, -1, function()
                        cmd:Dock(TOP)
                        cmd:DockMargin(4, 4, 4, 0)
                    end)
                    cmd:SetAlpha(0)
                    cmd:AlphaTo(255, dur, ind * delay)

                    cmd:SetText("")
                    cmd:SetTextAlign(TEXT_ALIGN_LEFT)
                    if isstring(com) then
                        if command.id ~= com then
                            cmd:SetColor(nadmin.colors.gui.theme)
                        else
                            drawCmd(com)
                        end
                    elseif ind > 0 then
                        cmd:SetColor(nadmin.colors.gui.theme)
                    elseif ind == 0 then
                        drawCmd(command.id)
                    end
                    function cmd:DoClick()
                        for i = 0, #cmds do
                            cmds[i]:SetColor(nadmin.colors.gui.theme)
                        end

                        self:SetColor(nadmin.colors.gui.blue)
                        drawCmd(self.id)
                    end

                    cmd.title = command.title
                    cmd.desc = command.description
                    cmd.id = command.id

                    cmd.normalPaint = cmd.Paint
                    cmd.smallFont = "nadmin_derma_xs"
                    function cmd:Paint(w, h)
                        self:normalPaint(w, h)

                        draw.Text({
                            text = self.title,
                            font = self:GetFont(),
                            color = self:GetTextColor(),
                            pos = {4, 4}
                        })

                        draw.RoundedBox(0, 0, 24, w, 2, nadmin:DarkenColor(self:GetColor(), 40))

                        draw.Text({
                            text = self.desc,
                            font = self.smallFont,
                            color = self:GetTextColor(),
                            pos = {4, h - 4},
                            yalign = TEXT_ALIGN_BOTTOM
                        })
                    end
                end
            end

            local selectors = {}
            for i, cat in ipairs(categories) do
                selectors[i] = nadmin.vgui:DButton(nil, {categ:GetWide() - 8, 32}, categ)

                local sel = selectors[i]
                sel:Dock(TOP)
                sel:DockMargin(0, 4, 4, 0)
                sel:SetText(cat)
                sel.index = i

                if isstring(selCom) then
                    local has
                    for i, cmd in ipairs(commands) do
                        if string.lower(cmd.id) == string.lower(selCom) then
                            has = true
                            break
                        end
                    end

                    if not has then sel:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25)) end
                else
                    if i ~= 1 then
                        sel:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    end
                end


                function sel:DoClick()
                    self:SetColor(nadmin.colors.gui.blue)
                    drawCmds(self:GetText())

                    for i, sel in ipairs(selectors) do
                        if sel.index ~= self.index then sel:SetColor(nadmin:BrightenColor(nadmin.colors.gui.theme, 25)) end
                    end
                end
            end

            drawCmds(selCat)
        end
    })
end
