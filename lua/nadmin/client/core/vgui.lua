-- This file contains all the vgui functions
nadmin.vgui = nadmin.vgui or {}

function nadmin.vgui:DPanel(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local panel = vgui.Create("DPanel", parent)
    panel:SetPos(unpack(pos))
    panel:SetSize(unpack(size))
    panel.color = nadmin.colors.gui.theme

    function panel:SetColor(col)
        if IsColor(col) then self.color = col end
    end
    function panel:GetColor() return self.color end

    function panel:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        if IsColor(self.color) then
            draw.RoundedBox(0, 0, 0, w, h, self.color)
        end
    end

    return panel
end

function nadmin.vgui:DScrollPanel(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local panel = vgui.Create("DScrollPanel", parent)
    panel:SetPos(unpack(pos))
    panel:SetSize(unpack(size))
    panel.color = nadmin.colors.gui.theme
    panel.vbar_col = nadmin:BrightenColor(panel.color, 25)

    function panel:SetColor(col, no_update)
        if IsColor(col) then
            self.color = col

            if not no_update then
                self.vbar_col = nadmin:BrightenColor(col, 25)
            end
        end
    end
    function panel:GetColor() return self.color end

    function panel:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        draw.RoundedBox(0, 0, 0, w, h, self.color)
    end

    local vbar = panel:GetVBar()
    vbar:SetWide(8)
    function vbar:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, panel.color)
    end
    function vbar.btnUp:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, panel.vbar_col)
    end
    function vbar.btnDown:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, panel.vbar_col)
    end
    function vbar.btnGrip:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, panel.vbar_col)
    end

    return panel
end

local icons = {}
function nadmin.vgui:DButton(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local btn = vgui.Create("DButton", parent)
    btn:SetPos(unpack(pos))
    btn:SetSize(unpack(size))
    btn:SetText("")
    btn:SetTextColor(nadmin:TextColor(nadmin.colors.gui.blue))
    btn:SetFont("nadmin_derma")
    btn.text = ""
    btn.color = nadmin.colors.gui.blue
    btn.icon = ""
    btn.showIcon = false
    btn.xalign = TEXT_ALIGN_CENTER

    function btn:SetColor(col, no_update)
        if IsColor(col) then
            self.color = col

            if not no_update then
                self:SetTextColor(nadmin:TextColor(col))
            end
        end
    end
    function btn:GetColor() return self.color end

    function btn:SetText(text)
        self.text = tostring(text)
    end
    function btn:GetText() return self.text end

    function btn:SetIcon(icon)
        if not isstring(icon) then return end
        self.icon = icon

        if isfunction(self.ShowIcon) then self:ShowIcon(true) end
    end
    function btn:GetIcon(mat)
        if mat then return icons[self.icon] end
        return self.icon
    end
    function btn:RemoveIcon(keepShowing)
        self.icon = nil
        if not keepShowing and isfunction(self.ShowIcon) then
            self:ShowIcon(false)
        end
    end

    function btn:ShowIcon(show)
        if not isbool(show) then return end
        self.showIcon = show
    end

    function btn:SetTextAlign(xalign)
        if isnumber(xalign) then
            self.xalign = xalign
        end
    end
    function btn:GetTextAlign() return self.xalign end

    function btn:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        if self:IsMouseInputEnabled() then
            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))
        else
            draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(self:GetColor(), 25))
        end

        local ico
        if self.showIcon then
            if isstring(self.icon) then
                if not icons[self.icon] then icons[self.icon] = Material(self.icon) end
                ico = icons[self.icon]
            end
        end

        local txtPos = w/2
        local iconPos = 4
        local iconWid = math.min(w, h) - 8

        if self.xalign == TEXT_ALIGN_LEFT then
            if self.showIcon then
                txtPos = iconWid + 8
            else
                txtPos = 4
            end
        elseif self.xalign == TEXT_ALIGN_CENTER then
            surface.SetFont(self:GetFont())

            local wid = surface.GetTextSize(self:GetText())

            if self.showIcon then
                if self:GetText() ~= "" then
                    wid = wid + iconWid + 4
                    iconPos = w/2 - wid/2
                else
                    iconPos = w/2 - iconWid/2
                end
            end

            txtPos = w/2 - wid/2
            if self.showIcon then txtPos = txtPos + iconWid + 4 end
        end

        if self.showIcon and ico ~= nil then
            if self.icon == "icon16/bin_closed.png" then iconPos = iconPos - 2 txtPos = txtPos - 2 end
            -- draw.RoundedBox(0, iconPos, 4, iconWid, iconWid, Color(0, 0, 0))
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(ico)
            surface.DrawTexturedRect(iconPos, 4, iconWid, iconWid)
        end

        if self:GetText() ~= "" then
            draw.Text({
                text = self:GetText(),
                font = self:GetFont(),
                color = self:GetTextColor(),
                pos = {txtPos, h/2},
                yalign = TEXT_ALIGN_CENTER
            })
        end
    end

    return btn
end

function nadmin.vgui:DColorMixer(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local color = vgui.Create("DColorMixer", parent)
    color:SetPos(unpack(pos))
    color:SetSize(unpack(size))
    color:SetAlphaBar(false)
    color:SetPalette(false)

    return color
end

function nadmin.vgui:DCheckBox(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local box = nadmin.vgui:DButton(pos, size, parent)
    box.checked = false
    box.checkColor = nadmin.colors.gui.blue

    function box:SetChecked(enabled)
        if isbool(enabled) then self.checked = enabled end
    end
    function box:GetChecked() return self.checked end

    function box:SetCheckColor(col)
        if IsColor(col) then self.checkColor = col end
    end
    function box:GetCheckColor() return self.checkColor end

    function box:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))

        local s = math.min(w, h) - 8
        draw.RoundedBox(0, 4, h/2 - s/2, s, s, self:GetTextColor())

        local col = self:GetChecked() and self:GetCheckColor() or self:GetColor()

        draw.RoundedBox(0, 6, h/2 - s/2 + 2, s-4, s-4, col)

        draw.Text({
            text = self:GetText(),
            font = self:GetFont(),
            color = self:GetTextColor(),
            pos = {s + 8, h/2},
            yalign = TEXT_ALIGN_CENTER
        })
    end
    function box:DoClick()
        self.checked = not self.checked
        if isfunction(self.OnChecked) then self:OnChecked(self.checked) end
    end

    return box
end

function nadmin.vgui:DTextEntry(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local edit = vgui.Create("DTextEntry", parent)
    edit:SetPos(unpack(pos))
    edit:SetSize(unpack(size))
    edit:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
    edit:SetFont("nadmin_derma")
    edit.color = nadmin:DarkenColor(nadmin.colors.gui.theme, 25)
    edit.errorColor = nadmin.colors.gui.red
    edit.errorTextColor = nadmin:TextColor(nadmin.colors.gui.theme)

    function edit:SetColor(col, no_update)
        if IsColor(col) then
            self.color = col

            if not no_update then
                self:SetTextColor(nadmin:TextColor(col))
            end
        end
    end
    function edit:GetColor() return self.color end

    function edit:SetErrorColor(col, no_update)
        if IsColor(col) then
            self.errorColor = col

            if not no_update then
                self.errorTextColor = nadmin:TextColor(col)
            end
        end
    end
    function edit:GetErrorColor() return self.errorColor end

    function edit:SetErrorTextColor(col)
        if IsColor(col) then self.errorTextColor = col end
    end
    function edit:GetErrorTextColor() return self.errorTextColor end

    function edit:GetErrored()
        if isfunction(self.ErrorCondition) then
            return self:ErrorCondition()
        end

        return false
    end

    function edit:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        draw.RoundedBox(0, 0, 0, w, h, self:GetColor())

        local textCol = self:GetTextColor()
        if self:GetErrored() then
            textCol = self.errorTextColor
            draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(self.errorColor, 50))
        end

        if self:GetText() == "" then
            draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 2, h/2, nadmin:AlphaColor(textCol, 75), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
        end

        self:DrawTextEntryText(textCol, nadmin.colors.gui.blue, textCol)
    end

    return edit
end

local function makeTextFit(text, w)
    local out = {}
    local height = 0

    local wid, hei = surface.GetTextSize(text)

    if wid > w then
        local i = 0
        local runs = 0
        local maxruns = 1024

        local lastSpace = 0
        while i < #text and runs < maxruns do
            i = i + 1
            runs = runs + 1

            local wid = surface.GetTextSize(string.sub(text, 1, i))
            if text[i] == " " then lastSpace = i end

            if wid > w then
                if lastSpace > 0 then
                    i = lastSpace -- Move back to that space
                else
                    i = i - 1 -- Move back a character
                end
                table.insert(out, string.sub(text, 1, i))

                text = string.sub(text, i + 1)
                height = height + hei
                lastSpace = 0
                i = 0
            end
        end

        if text ~= "" then
            table.insert(out, text)
            height = height + hei
        end
    else
        table.insert(out, text)
        height = hei
    end

    return out, height
end

function nadmin.vgui:AdvancedDLabel(pos, text, parent, no_size)
    if not istable(pos) then pos = {0, 0} end
    if not isstring(text) then text = "DLabel" end

    local label = vgui.Create("DPanel", parent)
    label:SetPos(unpack(pos))
    if IsValid(parent) and not no_size then label:SetTall(parent:GetTall()) end

    label.text = text
    label.font = "nadmin_derma"
    label.textColor = nadmin:TextColor(nadmin.colors.gui.theme)
    label.autoResize = true

    label.req_height = 0

    function label:SetText(txt)
        if not isstring(txt) then return end
        self.text = txt
    end
    function label:GetText() return self.text end

    function label:SetFont(font)
        if not isstring(font) then return end
        self.font = font
    end
    function label:GetFont() return self.font end

    function label:SetTextColor(col)
        if not IsColor(col) then return end
        self.textColor = col
    end
    function label:GetTextColor() return self.textColor end

    function label:SetAutoResize(resize)
        if not isbool(resize) then return end
        self.autoResize = resize
    end
    function label:GetAutoResize() return self.autoResize end

    function label:SizeToContentsX()
        surface.SetFont(self:GetFont())
        local wid = surface.GetTextSize(self:GetText())
        self:SetWide(wid)
    end

    function label:SizeToContentsY()
        self:SetTall(self.req_height)
    end

    function label:SizeToContents()
        self:SizeToContentsX()
    end

    label:SizeToContents()

    label.cache = {size = {}}
    label.render = {}
    function label:Paint(w, h)
        if self.cache.text ~= self:GetText() or self.cache.font ~= self:GetFont() or self.cache.size[1] ~= w or self.cache.size[2] ~= h then
            self.cache.text = self:GetText()
            self.cache.font = self:GetFont()
            self.cache.size = {w, h}

            surface.SetFont(self:GetFont())
            local r, he = makeTextFit(self:GetText(), w)
            self.render = r
            self.req_height = he

            if self:GetAutoResize() then self:SizeToContentsY() end
        end

        local lh = self.req_height/#self.render
        for i, line in ipairs(self.render) do
            draw.SimpleText(line, self:GetFont(), 0, (i - 1) * lh, self:GetTextColor())
        end
    end

    return label
end

function nadmin.vgui:DLabel(pos, text, parent, no_size)
    if not istable(pos) then pos = {0, 0} end
    if not isstring(text) then text = "DLabel" end

    local label = vgui.Create("DLabel", parent)
    label:SetPos(unpack(pos))
    label:SetText(text)
    label:SetFont("nadmin_derma")
    label:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
    label:SizeToContentsX()
    if IsValid(parent) and not no_size then label:SetTall(parent:GetTall()) end

    return label
end

function nadmin.vgui:DComboBox(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local box = vgui.Create("DComboBox", parent)
    box:SetPos(unpack(pos))
    box:SetSize(unpack(size))
    box:SetFont("nadmin_derma")
    box:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
    box.color = nadmin:DarkenColor(nadmin.colors.gui.theme, 25)

    function box:SetColor(col, no_update)
        if IsColor(col) then
            self.color = col

            if not no_update then
                self:SetTextColor(nadmin:TextColor(col))
            end
        end
    end
    function box:GetColor() return self.color end

    function box:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        draw.RoundedBox(0, 0, 0, w, h, self.color)
    end

    function box.DropButton:Paint(w, h)
        if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        local par = self:GetParent()
        local col = par:GetTextColor()
        surface.SetDrawColor(col.r, col.g, col.b)
        draw.NoTexture()

        if par:IsMenuOpen() then
            surface.DrawPoly({
                {x = w/2, y = 4},
                {x = w - 4, y = h - 4},
                {x = 4, y = h - 4}
            })
        else
            surface.DrawPoly({
                {x = 4, y = 4},
                {x = w - 4, y = 4},
                {x = w/2, y = h - 4}
            })
        end
    end

    return box
end

function nadmin.vgui:DSlider(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {ScrW(), 24} end

    local slider = vgui.Create("DPanel", parent)
    slider:SetPos(unpack(pos))
    slider:SetSize(unpack(size))
    slider.text = "Slider"
    slider.font = "nadmin_derma"
    slider.color = nadmin.colors.gui.theme
    slider.textColor = nadmin:TextColor(slider.color)
    slider.min, slider.max = 0, 2
    slider.value = slider.min

    local label = vgui.Create("DLabel", slider)
    label:SetText(slider.text)
    label:SetFont(slider.font)
    label:SetTextColor(slider.textColor)
    label:SizeToContentsX()
    label:SetTall(size[2])
    label:Dock(LEFT)

    local slide = vgui.Create("DButton", slider)
    slide:SetText("")
    slide:Dock(FILL)
    slide:DockMargin(0, 0, 4, 0)

    local entry = nadmin.vgui:DTextEntry(nil, {size[2], size[2]}, slider)
    entry:SetColor(nadmin:DarkenColor(slider.color, 25))
    entry:Dock(RIGHT)
    entry:SetText(slider.value)
    entry:SetNumeric(true)

    function slider:_RUNFUNC()
        if isfunction(self.OnValueChanged) then self:OnValueChanged(self:GetValue()) end
    end

    function entry:OnTextChanged()
        slider.value = tonumber(self:GetText()) or slider.min
        slider:_RUNFUNC()
    end

    function entry:OnFocusChanged(gained)
        if not gained then
            if tonumber(self:GetText()) == nil then
                slider:SetValue(slider.min)
            end
        end
        slider:_RUNFUNC()
    end

    function entry:OnKeyCode(key)
        if key == KEY_UP then
            slider:SetValue(slider.value + 1)
            slider:_RUNFUNC()
        elseif key == KEY_DOWN then
            slider:SetValue(slider.value - 1)
            slider:_RUNFUNC()
        end
    end

    function slide:OnReleased()
        local w, h = self:GetWide(), self:GetTall()

        local pos = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
        pos = math.min(pos, w - h/2 - 2)

        local positions = {}
        local dif = slider.max - slider.min
        for i = 0, dif do
            table.insert(positions, {h/2 + (i * (w - h)/dif), slider.min + i})
        end

        local value
        for i = 1, #positions do
            if pos > positions[i][1] then continue end

            if istable(positions[i - 1]) then
                local dist1 = math.abs(pos - positions[i - 1][1])
                local dist2 = math.abs(pos - positions[i][1])
                if dist1 <= dist2 then
                    value = positions[i - 1][2]
                else
                    value = positions[i][2]
                end

                break
            elseif pos > w then -- Mouse was after end of slider
                value = slider.max
                break
            else  -- Mouse was before slider
                value = slider.min
                break
            end
        end

        if isnumber(value) then
            slider:SetValue(value)
        end
    end

    function slide:Paint(w, h)
        local wid = h/6
        local height = h -- Help with telling what is what; slider ball height
        local col = nadmin:BrightenColor(slider.color, 25)
        draw.RoundedBox(0, height/2, h/2-wid/2, w - height, wid, col)

        local dif = slider.max - slider.min
        for i = 0, dif do
            local x = i * (w - height)/dif
            if i == 1 then
                x = x + wid/2
            elseif i == dif then
                x = x - wid
            end

            draw.RoundedBox(0, height/2 + x, h/2, wid, h/2, col)
        end

        if self:IsDown() then
            local x = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
            x = x - h/2 - 2
            x = math.Clamp(x, 0, w - h - 2)

            local y = height/2
            draw.Circle(height/2 + wid/2 + x, y, height/2, 45, 360, 0, col)
            draw.Circle(height/2 + wid/2 + x, y, wid, 15, 360, 0, nadmin.colors.gui.blue)
        else
            local x, y = (slider.value - slider.min) * (w - height)/dif - 2, height/2
            draw.Circle(height/2 + wid/2 + x + wid/2, y, height/2, 45, 360, 0, col)
            draw.Circle(height/2 + wid/2 + x + wid/2, y, wid, 15, 360, 0, nadmin:DarkenColor(col, 25))
        end
    end

    function slider:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:GetColor())
    end

    function slider:SetText(text)
        if not isstring(text) then return end
        self.text = text
        label:SetText(text)
        if text == "" then
            label:SetWide(0)
            slide:DockMargin(0, 0, 4, 0)
        else
            slide:DockMargin(4, 0, 4, 0)
            label:SizeToContentsX()
        end
    end
    function slider:GetText() return self.text end

    function slider:SetFont(font)
        if not isstring(font) then return end
        self.font = font
        label:SetFont(font)
        if self:GetText() ~= "" then
            label:SizeToContentsX()
            slide:DockMargin(4, 0, 4, 0)
        end
    end
    function slider:GetFont() return self.font end

    function slider:SetColor(col, no_update)
        if not IsColor(col) then return end
        self.color = col

        if not no_update then
            self.textColor = nadmin:TextColor(col)
        end
    end
    function slider:GetColor(col) return self.color end

    function slider:SetTextColor(col)
        if not IsColor(col) then return end
        self.textColor = col
    end
    function slider:GetTextColor(col) return self.textColor end

    function slider:SetMinValue(min)
        if not isnumber(min) then return end
        slider.min = min
        if min > slider.value then self:SetValue(min) end
    end
    function slider:GetMinValue() return self.min end

    function slider:SetMaxValue(max)
        if not isnumber(max) then return end
        slider.max = max
        if max < slider.value then self:SetValue(max) end
    end
    function slider:GetMaxValue() return self.max end

    function slider:SetClampValue(min, max)
        if isnumber(min) then self.min = min end
        if isnumber(max) then self.max = max end
        if isnumber(min) or isnumber(max) then self:SetValue(math.Clamp(slider.value, min, max)) end
    end
    function slider:GetClampValue() return self.min, self.max end

    function slider:SetValue(val)
        if not isnumber(val) then return end
        self.value = val
        entry:SetText(tonumber(val))
        slider:_RUNFUNC()
    end
    function slider:GetValue() return self.value end

    return slider
end

function nadmin.vgui:CreateBlur(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {ScrW(), ScrH()} end

    local blur = vgui.Create("DPanel", parent)
    blur:SetPos(unpack(pos))
    blur:SetSize(unpack(size))
    blur.startFade = SysTime()
    blur.fadeVal = 150
    blur.blurVal = 5
    blur.dur = 2
    function blur:Paint(w, h)
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
    end

    return blur
end

local icon = Material(nadmin.icons["nadmin"])
function nadmin.vgui:DFrame(pos, size, parent)
    if not istable(pos) then pos = {0, 0} end
    if not istable(size) then size = {50, 50} end

    local frame = vgui.Create("DFrame", parent)
    frame:SetPos(unpack(pos))
    frame:SetSize(unpack(size))
    frame:SetTitle("")
    frame:ShowCloseButton(false)
    frame:SetDraggable(false)
    frame:SetSizable(false)
    frame:DockPadding(0, 34, 0, 0)
    frame.title = ""
    frame.color = nadmin.colors.gui.theme
    frame.showIcon = true

    function frame:SetTitle(str)
        if not isstring(str) then return end
        self.title = str
    end
    function frame:GetTitle() return self.title end

    function frame:SetColor(col)
        if IsColor(col) then self.color = col  end
    end
    function frame:GetColor() return self.color end

    function frame:ShowCloseButton(show)
        if show and not IsValid(frame.close_button) then
            frame.close_button = nadmin.vgui:DButton({self:GetWide() - 40, 0}, {40, 28}, self)
            frame.close_button:SetText("X")
            function frame.close_button:DoClick()
                if IsValid(self:GetParent():GetParent()) then self:GetParent():GetParent():Remove() return end
                if IsValid(self:GetParent()) then self:GetParent():Remove() return end
            end
        elseif not show and IsValid(frame.close_button) then
            frame.close_button:Remove()
        end
    end

    function frame:ShowIcon(show)
        if not isbool(show) then return end
        self.showIcon = show
    end

    frame:ShowCloseButton(true)

    function frame:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, self:GetColor())

        local headCol = nadmin:BrightenColor(self:GetColor(), 25)
        draw.RoundedBox(0, 0, 0, w, 28, headCol)

        draw.RoundedBox(0, 0, 28, w, 2, nadmin:DarkenColor(self:GetColor(), 25))

        local tp = 4
        if self.showIcon then
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(4, 4, 20, 20)

            tp = 28
        end

        draw.Text({
            text = self:GetTitle(),
            font = "nadmin_derma",
            color = nadmin:TextColor(headCol),
            pos = {tp, 14},
            yalign = TEXT_ALIGN_CENTER
        })

        if IsValid(self.close_button) then
            self.close_button:SetPos(self:GetWide() - self.close_button:GetWide(), 0)
        end
    end

    return frame
end
