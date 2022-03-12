local NadminButton = {}
function NadminButton:Init()
    self.text = "Button"
    self:SetFont("nadmin_derma")

    self.color = {}
    self.color.normal  = nadmin.colors.gui.blue
    self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
    self.color.down    = nadmin:BrightenColor(self.color.normal, 10)
    self.color.text    = nadmin:TextColor(self.color.normal)
    self.color.shadow  = nadmin:BrightenColor(self.color.normal, -50)

    self.icon = nil

    self.buttonSounds = {
        {"nadmin/clickdown.ogg", "nadmin/clickup.ogg"}
    }
    self.selectedSound = 1

    -- The paint function doesn't let me change how the text is shown on the button, so I use a separate variable and override this
    self:SetText("")

    -- These functions are inside init to allow the SetText above to work without conflicts

    function self:SetText(text)
        if not isstring(text) then return end
        self.text = text
    end
    function self:GetText()
        return self.text
    end
end

function NadminButton:SetColor(color, noText)
    if not IsColor(color) then return end

    self.color.normal  = color
    self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
    self.color.down    = nadmin:BrightenColor(self.color.normal, 10)
    self.color.shadow  = nadmin:BrightenColor(self.color.normal, -50)

    if not noText then
        self.color.text = nadmin:TextColor(self.color.normal)
    end
end
function NadminButton:GetColor()
    return self.color.normal
end

function NadminButton:GetPressSounds()
    if isnumber(self.selectedSound) then
        return self.buttonSounds[self.selectedSound]
    end
end

function NadminButton:SetPressSounds(ind)
    if not isnumber(ind) then return end

    self.selectedSound = ind
end

function NadminButton:OnDepressed()
    local sounds = self:GetPressSounds()
    if istable(sounds) and isstring(sounds[1]) then
        surface.PlaySound(sounds[1])
    end
end
function NadminButton:OnReleased()
    local sounds = self:GetPressSounds()
    if istable(sounds) and isstring(sounds[2]) then
        surface.PlaySound(sounds[2])
    end
end

local icons = {}
function NadminButton:SetIcon(icon)
    if not isstring(icon) then return end 
    self.icon = icon 
end
function NadminButton:GetIcon() return self.icon end
function NadminButton:GetIconMat() return icons[self.icon] end

function NadminButton:Paint(w, h) 
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end 
    end

    local offset = (self:IsEnabled() and (self:IsDown() and 2 or 0)) or 0

    local color = self:GetColor()
    local tc    = self:GetTextColor()

    if self:IsEnabled() then
        if self:IsDown() then
            color = self.color.down
        elseif self:IsHovered() then
            color = self.color.hovered
        end
    else 
        color = nadmin:BrightenColor(color, -15)
    end

    draw.RoundedBox(0, 0, offset, w, h, color)

    if self:IsEnabled() and not self:IsDown() then
        draw.RoundedBox(0, 0, h-2, w, 2, self.color.shadow)
    end

    -- Icon 
    local ico 
    if isstring(self.icon) then 
        if not icons[self.icon] then icons[self.icon] = Material(self.icon) end
        ico = icons[self.icon]
    end

    local textPos = 0
    local iconPos = 0
    local iconWid = math.min(w, h) - 8

    surface.SetFont(self:GetFont())
    local wid = surface.GetTextSize(self:GetText())

    if ico ~= nil then 
        if self:GetText() ~= "" then 
            textPos = w/2 + iconWid/2 + 4
            iconPos = textPos - wid/2 - iconWid - 4
        else 
            iconPos = w/2 - iconWid/2
        end

        if self.icon == "icon16/bin_closed.png" then 
            iconPos = iconPos - 2
            textPos = textPos - 2
        end

        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(ico)
        surface.DrawTexturedRect(iconPos, h/2 - iconWid/2 + offset, iconWid, iconWid)
    else 
        textPos = w/2 
    end

    if self:GetText() ~= "" then 
        draw.Text({
            text = self:GetText(),
            font = self:GetFont(),
            color = tc,
            pos = {textPos, h/2 + offset},
            xalign = TEXT_ALIGN_CENTER,
            yalign = TEXT_ALIGN_CENTER
        })
    end
end

vgui.Register("NadminButton", NadminButton, "DButton")


local NadminSimpleButton = {}
function NadminSimpleButton:Init()
    self.text = "Button"

    self.color = {}
    self.color.normal  = nadmin.colors.gui.blue
    self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
    self.color.down    = nadmin:BrightenColor(self.color.normal, 10)
    self.color.text    = nadmin:TextColor(self.color.normal)

    self.icon = nil
    self.xalign = TEXT_ALIGN_CENTER

    -- The paint function doesn't let me change how the text is shown on the button, so I use a separate variable and override this
    self:SetText("")
    self:SetFont("nadmin_derma")

    -- These functions are inside init to allow the SetText above to work without conflicts

    function self:SetText(text)
        if not isstring(text) then return end
        self.text = text
    end
    function self:GetText()
        return self.text
    end
end

function NadminSimpleButton:SetColor(color, noText)
    if not IsColor(color) then return end

    self.color.normal  = color
    self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
    self.color.down    = nadmin:BrightenColor(self.color.normal, 10)

    if not noText then
        self.color.text = nadmin:TextColor(self.color.normal)
    end
end
function NadminSimpleButton:GetColor()
    return self.color.normal
end

function NadminSimpleButton:SetIcon(icon)
    if not isstring(icon) then return end 
    self.icon = icon 
end
function NadminSimpleButton:GetIconMat() return icons[self.icon] end
function NadminSimpleButton:GetIconString() return self.icon end

function NadminSimpleButton:Paint(w, h) 
    if isfunction(self.RenderCondition) then if not self:RenderCondition() then return end end

        if not isfunction(self.BackgroundDraw) then 
            if self:IsMouseInputEnabled() then
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))
            else
                draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(self:GetColor(), 25))
            end
        else 
            self:BackgroundDraw(w, h)
        end

        local ico
        if isstring(self.icon) then
            if not icons[self.icon] then icons[self.icon] = Material(self.icon) end
            ico = icons[self.icon]
        end

        local txtPos = w/2
        local iconPos = 4
        local iconWid = math.min(w, h) - 8

        if self.xalign == TEXT_ALIGN_LEFT then
            if ico ~= nil then
                txtPos = iconWid + 8
            else
                txtPos = 4
            end
        elseif self.xalign == TEXT_ALIGN_CENTER then
            surface.SetFont(self:GetFont())

            local wid = surface.GetTextSize(self:GetText())

            if ico ~= nil then
                if self:GetText() ~= "" then
                    wid = wid + iconWid/2 + 4
                    iconPos = w/2 - wid/2
                else
                    iconPos = w/2 - iconWid/2
                end
            end

            txtPos = w/2
            if ico ~= nil then 
                txtPos = txtPos + iconWid/2 + 4 
            end
        end

        if ico ~= nil then
            if self.icon == "icon16/bin_closed.png" then 
                iconPos = iconPos - 2 
                txtPos = txtPos - 2 
            end
            -- draw.RoundedBox(0, iconPos, 4, iconWid, iconWid, Color(0, 0, 0))
            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(ico)
            surface.DrawTexturedRect(iconPos, h/2 - iconWid/2, iconWid, iconWid)
        end

        if self:GetText() ~= "" then
            draw.Text({
                text = self:GetText(),
                font = self:GetFont(),
                color = self:GetTextColor(),
                pos = {txtPos, h/2},
                xalign = self.xalign,
                yalign = TEXT_ALIGN_CENTER
            })
        end
end

vgui.Register("NadminSimpleButton", NadminSimpleButton, "DButton")


local NadminPanel = {}
function NadminPanel:Init()
    self.color = nadmin.colors.gui.theme 
end

function NadminPanel:SetColor(color)
    if IsColor(color) then self.color = color end
end
function NadminPanel:GetColor() return self.color end 

function NadminPanel:Paint(w, h) 
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end
    end

    if IsColor(self.color) then 
        draw.RoundedBox(0, 0, 0, w, h, self.color)
    end
end

vgui.Register("NadminPanel", NadminPanel, "DPanel")


local NadminScrollPanel = {}
function NadminScrollPanel:Init()
    self.color = nadmin.colors.gui.theme
    self.vbarColor = nadmin:BrightenColor(nadmin.colors.gui.theme, 25)

    local vbar = self:GetVBar()
    vbar:SetWide(8)
    vbar.panel = self
    vbar.btnUp.panel = self 
    vbar.btnDown.panel = self 
    vbar.btnGrip.panel = self
    function vbar:Paint(w, h)
        local col = self.panel.color
        if self:IsHovered() then col = nadmin:BrightenColor(col, 15) end

        draw.RoundedBox(0, 0, 0, w, h, col)
    end
    function vbar.btnUp:Paint(w, h)
        local col = self.panel.vbarColor
        if self:IsHovered() then col = nadmin:BrightenColor(col, 15) end

        draw.RoundedBox(0, 0, 0, w, h, col)
    end
    function vbar.btnDown:Paint(w, h)
        local col = self.panel.vbarColor
        if self:IsHovered() then col = nadmin:BrightenColor(col, 15) end

        draw.RoundedBox(0, 0, 0, w, h, col)
    end
    function vbar.btnGrip:Paint(w, h)
        local col = self.panel.vbarColor
        if self:IsHovered() then col = nadmin:BrightenColor(col, 15) end

        draw.RoundedBox(0, 0, 0, w, h, col)
    end
end

function NadminScrollPanel:SetColor(col, noVbar)
    if IsColor(col) then 
        self.color = col 

        if not noVbar then 
            self:SetVBarColor(nadmin:BrightenColor(col, 25))
        end
    end
end
function NadminScrollPanel:GetColor() return self.color end 

function NadminScrollPanel:SetVBarColor(col)
    if IsColor(col) then 
        self.vbarColor = col
    end
end
function NadminScrollPanel:GetVBarColor() return self.vbarColor end 

function NadminScrollPanel:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, self.color)
end

vgui.Register("NadminScrollPanel", NadminScrollPanel, "DScrollPanel")


local NadminCheckBox = {}
function NadminCheckBox:Init() 
    self.checked = false
    self.text = "Check Box"
    self.checkColor = nadmin.colors.gui.blue
    self.color = nadmin.colors.gui.theme
    self.textColor = nadmin:TextColor(self.color)
    self.style = nadmin.STYLE_BOX

    -- Button stuff
    self:SetFont("nadmin_derma")

    -- The paint function doesn't let me change how the text is shown on the button, so I use a separate variable and override this
    self:SetText("")

    -- These functions are inside init to allow the SetText above to work without conflicts

    function self:SetText(text)
        if not isstring(text) then return end
        self.text = text
    end
    function self:GetText()
        return self.text
    end
end

function NadminCheckBox:SetStyle(style)
    if isnumber(style) then 
        self.style = style 
    end
end
function NadminCheckBox:GetStyle() return self.style end

function NadminCheckBox:SetColor(col, noText)
    if IsColor(col) then 
        self.color = col

        if not noText then 
            self:SetTextColor(nadmin:TextColor(col))
        end
    end
end
function NadminCheckBox:GetColor() return self.color end

function NadminCheckBox:SetTextColor(col)
    if IsColor(col) then 
        self.textColor = col
    end
end
function NadminCheckBox:GetTextColor() return self.textColor end

function NadminCheckBox:SetChecked(checked)
    if isbool(checked) then 
        self.checked = checked 
    end
end
function NadminCheckBox:GetChecked() return self.checked end 

function NadminCheckBox:SetCheckColor(col)
    if IsColor(col) then 
        self.checkColor = col
    end
end
function NadminCheckBox:GetCheckColor() return self.checkColor end

function NadminCheckBox:Paint(w, h)
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end 
    end

    draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self:GetColor(), self:IsDown() and 10 or (self:IsHovered() and 25 or 0)))

    if self.style == nadmin.STYLE_BOX then 
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
    elseif self.style == nadmin.STYLE_SWITCH then 
        -- Toggle switch slider
        local dark = nadmin:DarkenColor(self:GetColor(), 25)
        local darker = nadmin:DarkenColor(self:GetColor(), 35)
        draw.RoundedBox(8, w - 46, h/2 - 8, 42, 16, dark)
        draw.RoundedBox(2, w - 38, h/2 - 2, 26, 4, darker)

        -- Check pos 
        local x = self:GetChecked() and w - 12 or w - 38

        -- Check render 
        -- x, y, radius, seg, arc, angOffset, col
        draw.Circle(x, h/2, 8, 16, 360, 0, self:GetChecked() and self:GetCheckColor() or self:GetTextColor())

        draw.Text({
            text = self:GetText(),
            font = self:GetFont(),
            color = self:GetTextColor(),
            pos = {4, h/2},
            yalign = TEXT_ALIGN_CENTER
        })
    end
end

function NadminCheckBox:DoClick()
    self.checked = not self.checked 
    if isfunction(self.OnChecked) then self:OnChecked(self.checked) end
end

vgui.Register("NadminCheckBox", NadminCheckBox, "DButton")


local NadminTextEntry = {}
function NadminTextEntry:Init()
    self.color = nadmin:DarkenColor(nadmin.colors.gui.theme, 25)
    self.errorColor = nadmin.colors.gui.red
    self.errorTextColor = nadmin:TextColor(nadmin.colors.gui.theme)
    self.warningColor = nadmin.colors.gui.warning

    self:SetTextColor(nadmin:TextColor(self.color))
    self:SetFont("nadmin_derma")
end

function NadminTextEntry:SetColor(col, noText)
    if IsColor(col) then 
        self.color = col 

        if not noText then 
            self:SetTextColor(nadmin:TextColor(col))
        end
    end
end
function NadminTextEntry:GetColor() return self.color end 

function NadminTextEntry:SetErrorColor(col)
    if IsColor(col) then 
        self.errorColor = col 
    end
end
function NadminTextEntry:GetErrorColor() return self.errorColor end 

function NadminTextEntry:SetErrorTextColor(col)
    if IsColor(col) then 
        self.errorTextColor = col
    end
end
function NadminTextEntry:GetErrorTextColor() return self.errorTextColor end 

function NadminTextEntry:SetWarningColor(col)
    if IsColor(col) then 
        self.warningColor = col 
    end
end
function NadminTextEntry:GetWarningColor() return self.warningColor end 

function NadminTextEntry:SetWarningTextColor(col)
    if IsColor(col) then 
        self.warningTextColor = col
    end
end
function NadminTextEntry:GetWarningTextColor() return self.warningTextColor end 

function NadminTextEntry:IsErrored() 
    if isfunction(self.ErrorCondition) then 
        return self:ErrorCondition()
    end

    return false
end 
function NadminTextEntry:IsWarned() 
    if isfunction(self.WarningCondition) then 
        return self:WarningCondition()
    end 

    return false
end

function NadminTextEntry:Paint(w, h)
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end 
    end

    draw.RoundedBox(0, 0, 0, w, h, self:GetColor())

    local textCol = self:GetTextColor() 
    local errored = self:IsErrored()
    if errored then 
        draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(self.errorColor, 25))

        if isstring(errored) then 
            draw.SimpleText(errored, self:GetFont(), w - 2, h/2, self.errorColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
        end
    else 
        local warned = self:IsWarned() 
        if warned then 
            draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(self.warningColor, 25))

            if isstring(warned) then 
                draw.SimpleText(warned, self:GetFont(), w - 2, h/2, self.warningColor, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER)
            end
        end
    end

    if self:GetText() == "" then 
        draw.SimpleText(self:GetPlaceholderText(), self:GetFont(), 2, h/2, nadmin:AlphaColor(textCol, 75), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER)
    end

    self:DrawTextEntryText(textCol, nadmin.colors.gui.blue, textCol)
end

vgui.Register("NadminTextEntry", NadminTextEntry, "DTextEntry")


-- This function can make text fit within a certain width, and give you each line and the overall height needed. 
-- Large amounts of text can cause lag, so be mindful of what you're inputing!
function nadmin:MakeTextFit(text, w)
    local out = {}
    local height = 0

    local wid, hei = surface.GetTextSize(text)

    if wid > w then 
        local i = 0

        while i < #text do
            i = i + 1

            local wid = surface.GetTextSize(string.sub(text, 1, i))
            if text[i] == " " then lastSpace = i end 

            -- Text be getting too long, time to move to a new line
            if wid > w then 
                if lastSpace > 0 then 
                    -- Move back to the last line break character. Currently only supports spaces, 
                    -- but I may allow it to include other characters, such as brackets or dashes
                    i = lastSpace 
                else 
                    -- Otherwise, just go back a character 
                    i = i - 1
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


local NadminLabel = {}
function NadminLabel:Init()
    self.text = "Label"
    self.font = "nadmin_derma"
    self.textColor = nadmin:TextColor(nadmin.colors.gui.theme)
    self.autoResize = true

    -- if autoResize is true, it will make the text wrap when it goes past the width. 
    -- This is the automatic height based on how far it goes down.
    self.autoHeight = 0 

    self.cache = {width = nil, text = nil, font = nil} -- A cache of stuff to monitor every frame. If any of these changes, the render variable below is refreshed and the autoHeight is recalculated
    self.lines = {} -- Each line of text that fits in the width
end

function NadminLabel:SetText(txt)
    if not isstring(txt) then return end
    self.text = txt
end
function NadminLabel:GetText() return self.text end

function NadminLabel:SetFont(font)
    if not isstring(font) then return end
    self.font = font
end
function NadminLabel:GetFont() return self.font end

function NadminLabel:SetTextColor(col)
    if not IsColor(col) then return end
    self.textColor = col
end
function NadminLabel:GetTextColor() return self.textColor end

function NadminLabel:SetAutoResize(resize)
    if not isbool(resize) then return end
    self.autoResize = resize
end
function NadminLabel:GetAutoResize() return self.autoResize end

function NadminLabel:SizeToContentsX()
    surface.SetFont(self:GetFont())
    local wid = surface.GetTextSize(self:GetText())
    self:SetWide(wid)
end

function NadminLabel:SizeToContentsY()
    self:SetTall(self.autoHeight)
end

function NadminLabel:SizeToContents()
    self:SizeToContentsX()
end

function NadminLabel:Paint(w, h)
    local textDif  = (self:GetText() ~= self.cache.text )
    local fontDif  = (self:GetFont() ~= self.cache.font )
    local widthDif = (             w ~= self.cache.width)

    -- Monitor properties that affect how the text is displayed
    if textDif or fontDif or widthDif then 
        self.cache.text    = self:GetText()
        self.cache.font    = self:GetFont()
        self.cache.width = w 

        surface.SetFont(self:GetFont())
        local lines, height = nadmin:MakeTextFit(self:GetText(), w)
        self.lines = lines
        self.autoHeight = height

        if self:GetAutoResize() then self:SizeToContentsY() end
    end

    local lineHeight = self.autoHeight / #self.lines 
    for i, line in ipairs(self.lines) do 
        draw.SimpleText(line, self:GetFont(), 0, (i - 1) * lineHeight, self:GetTextColor())
    end
end

vgui.Register("NadminLabel", NadminLabel, "DPanel")


local NadminComboBox = {}
function NadminComboBox:Init() 
    self.color = nadmin:DarkenColor(nadmin.colors.gui.theme, 25)

    self:SetFont("nadmin_derma")
    self:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))

    function self.DropButton:Paint(w, h)
        if isfunction(self.RenderCondition) then 
            if not self:RenderCondition() then return end 
        end
    
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
end

function NadminComboBox:SetColor(col, no_update)
    if IsColor(col) then
        self.color = col

        if not no_update then
            self:SetTextColor(nadmin:TextColor(col))
        end
    end
end
function NadminComboBox:GetColor() return self.color end

function NadminComboBox:Paint(w, h)
    if isfunction(self.RenderCondition) then 
        if not self:RenderCondition() then return end 
    end

    draw.RoundedBox(0, 0, 0, w, h, self.color)
end

vgui.Register("NadminComboBox", NadminComboBox, "DComboBox")


-- A panel that starts completely clear, but over time blurs
local NadminBlurPanel = {} 
function NadminBlurPanel:Init()
    self.startFade = SysTime() -- Want the blur to restart? Set it to SysTime() again

    self.fadeValue = 150
    self.blurValue = 5
    self.duration = 2

    self.fadeColor = Color(0, 0, 0, 0)
end

function NadminBlurPanel:Paint(w, h)
    local blur = 0
    if SysTime() < self.startFade + self.dur then -- fading
        local prog = (SysTime() - self.startFade) / self.dur
        self.fadeColor[4] = Nadmin:Lerp(0, self.fadeValue, prog)
        blur = nadmin:Lerp(0, self.blurValue, prog)
    else -- Fade animation is done, so just make it blured
        self.fadeColor[4] = self.fadeValue
        blur = self.blurVal
    end
    draw.RoundedBox(0, 0, 0, w, h, self.fadeColor)
    draw.Blur(0, 0, w, h, blur)
end

vgui.Register("NadminBlurPanel", NadminBlurPanel, "DPanel")


local NadminFrame = {}
function NadminFrame:Init()
    self.title          = "Menu"
    self.color          = nadmin.colors.gui.theme
    self.titleTextColor = nadmin:TextColor(self.color)
    self.showIcon       = true -- Should the Nadmin icon appear in the top left, next to the title?

    self.lastWidth = nil -- A stored variable of the width. When it changes, it repositions the close button if shown

    self:DockPadding(0, 30, 0, 0)

    -- Removing some functionality from the default DFrame, so these need to be in the init
    self:SetTitle("")
    self:ShowCloseButton(false)

    function self:SetTitle(str)
        if not isstring(str) then return end
        self.title = str
    end
    function self:GetTitle() return self.title end

    function self:ShowCloseButton(show)
        if show and not IsValid(self.closeButton) then 
            self.closeButton = vgui.Create("NadminButton", self)
            self.closeButton:SetPos(self:GetWide() - self.closeButton:GetWide() - 4, 4)
            self.closeButton:SetSize(40, 20)
            self.closeButton:SetText("X")
            self.closeButton.parent = self
            function self.closeButton:DoClick()
                if IsValid(self.parent) then self.parent:Remove() end
                if IsValid(self) then self:Remove() end
            end
        elseif not show and IsValid(self.closeButton) then 
            self.closeButton:Remove()
        end
    end
    self:ShowCloseButton(true)
end

function NadminFrame:SetColor(col, noTitle)
    if IsColor(col) then 
        self.color = col  

        if not noTitle then 
            self:SetTitleTextColor(nadmin:TextColor(nadmin:BrightenColor(col, 25)))
        end
    end
end
function NadminFrame:GetColor() return self.color end

function NadminFrame:SetTitleTextColor(col)
    if IsColor(col) then 
        self.titleTextColor = col
    end
end
function NadminFrame:GetTitleTextColor() return self.titleTextColor end

function NadminFrame:ShowNadminIcon(show)
    if isbool(show) then 
        self.showIcon = show
    end
end

local NadminIcon = Material(nadmin.icons["nadmin"])
function NadminFrame:Paint(w, h)
    draw.RoundedBox(0, 0, 0, w, h, self:GetColor())

    local headerColor = nadmin:BrightenColor(self:GetColor(), 25)
    draw.RoundedBox(0, 0, 0, w, 28, headerColor)

    -- Underline of the title bar
    draw.RoundedBox(0, 0,28, w, 2, nadmin:DarkenColor(self:GetColor(), 25))

    local textX = 4
    if self.showIcon then 
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(NadminIcon)
        surface.DrawTexturedRect(4, 4, 20, 20)

        textX = 28
    end

    draw.Text({
        text = self:GetTitle(),
        font = "nadmin_derma",
        color = self.titleTextColor,
        pos = {textX, 14},
        yalign = TEXT_ALIGN_CENTER
    })

    -- Change close button
    if self.lastWidth ~= w and IsValid(self.closeButton) then 
        self.closeButton:SetPos(self:GetWide() - self.closeButton:GetWide() - 4, 4)
    end
end

vgui.Register("NadminFrame", NadminFrame, "DFrame")


-- Creates a scroll panel with tabs on top or to the side that let you switch between different menus
local NadminTabMenu = {}
function NadminTabMenu:Init()
    self.backgroundColor  = nadmin:DarkenColor(nadmin.colors.gui.theme, 25) -- Background color of the scroll panel.
    self.baseTabColor     = nadmin.colors.gui.blue -- The base color for tabs, however can be overriden
    self.baseTabTextColor = nadmin:TextColor(self.baseTabColor)

    self.verticalTabs = false -- True to make taps appear on the left, false to appear on top

    self.tabs = {}

    self.selectedTab = NULL

    self.tabSizeW = 50
    self.tabSizeH = 28
    self.cacheWidth = 0

    self.tabContainerTop = vgui.Create("DPanel", self)
    self.tabContainerTop:Dock(TOP)
    self.tabContainerTop:SetTall(self.tabSizeH)
    self.tabContainerTop:SetVisible(false)
    function self.tabContainerTop:Paint(w, h) end -- Shouldn't be drawn
    
    self.tabContainerLeft = vgui.Create("DScrollPanel", self)
    self.tabContainerLeft:GetVBar():SetWide(0)
    self.tabContainerLeft:Dock(LEFT)
    self.tabContainerLeft:SetWide(self.tabSizeW)
    function self.tabContainerLeft:Paint(w, h) end -- Shouldn't be drawn

    self.scrollPanel = vgui.Create("NadminScrollPanel", self)
    self.scrollPanel:SetColor(Color(0, 0, 0, 0))
    self.scrollPanel:Dock(FILL)
end

function NadminTabMenu:GetContentPanel() return self.scrollPanel end

function NadminTabMenu:SetColor(col) 
    if IsColor(col) then 
        self.backgroundColor = col
    end
end
function NadminTabMenu:GetColor() return self.backgroundColor end

function NadminTabMenu:SetTabColor(col, noText)
    if IsColor(col) then 
        self.baseTabColor = col

        if not noText then 
            self.baseTabTextColor = nadmin:TextColor(col)
        end 
    end
end
function NadminTabMenu:GetTabColor() return self.baseTabColor end

function NadminTabMenu:SetTabTextColor(col)
    if IsColor(col) then 
        self.baseTabTextColor = col
    end
end
function NadminTabMenu:GetTabTextColor() return self.baseTabTextColor end

function NadminTabMenu:SetTabSize(w, h)
    if isnumber(w) then self:SetTabWidth(w) end
    if isnumber(h) then self:SetTabHeight(h) end
end
function NadminTabMenu:SetTabWidth(w)
    self.tabContainerLeft:SetWide(w)
    self.tabSizeW = w
end
function NadminTabMenu:SetTabHeight(h)
    self.tabContainerTop:SetTall(h)
    self.tabSizeH = h
end

function NadminTabMenu:UseVerticalTabs(vert)
    if isbool(vert) then 
        self.verticalTabs = vert 
        self:ValidateMenu()
    end
end

-- Makes sure the tabs are where they should be, and the contents panel is sized correctly
function NadminTabMenu:ValidateMenu()
    if not self.verticalTabs then -- Tabs are on top
        if not self.tabContainerTop:IsVisible() then self.tabContainerTop:SetVisible(true) end 
        if self.tabContainerLeft:IsVisible() then self.tabContainerLeft:SetVisible(false) end

        -- Position and size tabs
        local numTabs = #self.tabs
        local tabSize = (self.tabContainerTop:GetWide() / numTabs) - 4
        for i, tab in ipairs(self.tabs) do 
            if tab:GetParent() ~= self.tabContainerTop then 
                tab:Dock(NODOCK)
                tab:SetParent(self.tabContainerTop) 
            end

            tab:SetSize(tabSize, self.tabSizeH)
            tab:SetPos(((i - 1) / numTabs) * self.tabContainerTop:GetWide(), 0)
        end

        -- The final tab might not be aligned with the right side of the menu, so we are just going to increase the width to make it seamless
        local x = self.tabs[numTabs]:GetPos()
        self.tabs[numTabs]:SetWide(self.tabContainerTop:GetWide() - x)
    else -- Tabs are on the left
        if self.tabContainerTop:IsVisible() then self.tabContainerTop:SetVisible(false) end 
        if not self.tabContainerLeft:IsVisible() then self.tabContainerLeft:SetVisible(true) end

        local w = self.tabSizeW
        if not self.scrollPanel:IsVisible() then 
            w = self:GetWide()
            self.tabSizeW = w
            self.tabContainerLeft:SetWide(w)
        end

        for i, tab in ipairs(self.tabs) do 
            if tab:GetParent() ~= self.tabContainerLeft then 
                tab:SetParent(self.tabContainerLeft)
                tab:Dock(TOP)
                tab:DockMargin(0, 0, 0, 4)
            end

            tab:SetSize(w, self.tabSizeH)
        end
    end
end

function NadminTabMenu:AddTab(text, contents, selected, data)
    local tab = vgui.Create("NadminSimpleButton", self)
    if isfunction(contents) then tab.OnSelect = contents end
    tab.parent = self
    tab.vertical = false
    tab:SetText(text)
    if data ~= nil then tab.data = data end 

    function tab:DoClick(noClick)
        if not noClick then chat.PlaySound() end -- Some sound effects :^)
        self.animStart = SysTime()
        self.parent.selectedTab = self

        self.parent.scrollPanel:Clear()

        if isfunction(self.OnSelect) then 
            self.OnSelect(self.parent.scrollPanel, self.data) 
        end
    end

    -- Overriding some built in functions for the button :^)
    function tab:SetSelectedColor(col, noText)
        if IsColor(col) then 
            self.selColor = col

            if not noText then 
                self.selTextColor = nadmin:TextColor(col)
            end
        end
    end
    function tab:GetSelectedColor() return self.selColor or self.parent.baseTabColor end
    function tab:ResetSelectedColor() self.selColor = nil end 

    function tab:SetSelectedTextColor(col) -- was :SetTextColor
        if IsColor(col) then 
            self.selTextColor = col
        end
    end
    function tab:GetSelectedTextColor() return self.selTextColor or self.parent.baseTabTextColor end
    function tab:ResetSelectedTextColor() self.selTextColor = nil end 

    function tab:SetUnselectedColor(col, noText)
        if IsColor(col) then 
            self.unselColor = col

            if not noText then 
                self.unselTextColor = nadmin:TextColor(col)
            end
        end
    end
    function tab:GetUnselectedColor() return self.unselColor or self.parent.baseTabColor end
    function tab:ResetUnselectedColor() self.unselColor = nil end 

    function tab:SetUnselectedTextColor(col) -- was :SetTextColor
        if IsColor(col) then 
            self.unselTextColor = col
        end
    end
    function tab:GetUnselectedTextColor() return self.unselTextColor or self.parent.baseTabTextColor end
    function tab:ResetUnselectedTextColor() self.unselTextColor = nil end 

    function tab:BackgroundDraw(w, h)
        local col = self.unselColor or self.parent.baseTabColor
        if IsColor(self.selColor) then col = self.selColor end 

        if self.parent.selectedTab == self then 
            local tc = self.parent.baseTabTextColor 
            if IsColor(self.selTextColor) then tc = self.selTextColor end
            self:SetTextColor(tc)

            if isnumber(self.animStart) then 
                local anim = nadmin:SmootherStep(self.animStart, self.animStart + 0.33, SysTime())

                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self.parent.backgroundColor, 35))
                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h - h * anim, w, h, col)
                else 
                    draw.RoundedBox(0, w - w * anim, 0, w, h, col)
                end

                if SysTime() - self.animStart >= 0.33 then 
                    self.animStart = nil
                end
            else 
                draw.RoundedBox(0, 0, 0, w, h, col)
            end

            self.active = true
        else
            self:SetTextColor(self.unselTextColor or self.parent.baseTabTextColor)
            if self:IsHovered() and not isnumber(self.animStart) then 
                self.animStart = SysTime() 
                self.animDown = nil
            elseif not self:IsHovered() and isnumber(self.animStart) then 
                self.animStart = nil
                self.animDown = SysTime()
            elseif self.active then 
                self.active = nil 
                self.unselect = SysTime()
            end

            draw.RoundedBox(0, 0, 0, w, h, self.unselColor or self.parent.backgroundColor)

            local hoverLine = 3
            local brightenedColor = nadmin:BrightenColor(self.unselColor or self.parent.backgroundColor, 35)
            if isnumber(self.animStart) then 
                local anim = nadmin:SmootherStep(self.animStart, self.animStart + 0.33, SysTime())

                if self:IsDown() then hoverLine = 1 end 

                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h - h * anim, w, h, brightenedColor)
                    draw.RoundedBox(0, 0, h - hoverLine, w, hoverLine, col)
                else 
                    draw.RoundedBox(0, w - w * anim, 0, w, h, brightenedColor)
                    draw.RoundedBox(0, w - hoverLine, 0, hoverLine, h, col)
                end
            elseif isnumber(self.animDown) then 
                local anim = nadmin:SmootherStep(self.animDown, self.animDown + 0.66, SysTime())

                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h * anim, w, h, brightenedColor)
                    draw.RoundedBox(0, 0, h - hoverLine, w, hoverLine, col)
                else 
                    draw.RoundedBox(0, w * anim, 0, w, h, brightenedColor)
                    draw.RoundedBox(0, w - hoverLine, 0, hoverLine, h, col)
                end

                if SysTime() - self.animDown >= 0.66 then 
                    self.animDown = nil
                end
            elseif isnumber(self.unselect) then 
                local anim = nadmin:SmootherStep(self.unselect, self.unselect + 0.33, SysTime())

                -- draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(self.parent.backgroundColor, 35))
                if not self.parent.verticalTabs then 
                    draw.RoundedBox(0, 0, h * anim, w, h, col)
                else 
                    draw.RoundedBox(0, w * anim, 0, w, h, col)
                end

                if SysTime() - self.unselect >= 0.33 then 
                    self.unselect = nil
                end
            end
        end
    end

    table.insert(self.tabs, tab)
    
    self:ValidateMenu()
    
    -- For some reason, the scroll panel isn't sized correctly even after init, but a timer fixes it :shrug:
    if selected then timer.Simple(0.03, function() tab:DoClick(true) end) end
    return tab
end

function NadminTabMenu:RemoveTab(indexOrText)
    local tab = self:GetTab(indexOrText)
    if IsValid(tab) then 
        if isnumber(indexOrText) then 
            table.remove(self.tabs, indexOrText)
        else 
            for i, t in ipairs(self.tabs) do 
                if t == tab then 
                    table.remove(self.tabs, i)
                    break
                end
            end
        end
        tab:Remove()
    end
end

function NadminTabMenu:GetTab(indexOrText)
    if isnumber(indexOrText) then 
        if IsValid(self.tabs[indexOrText]) then 
            return self.tabs[indexOrText] 
        end
    elseif isstring(indexOrText) then 
        for i, t in ipairs(self.tabs) do 
            if t:GetText() == indexOrText then 
                return t
            end
        end
    end 
    return NULL
end

function NadminTabMenu:Paint(w, h)
    local x, y = 0, 0
    if self.verticalTabs then 
        x = self.tabSizeW
    else 
        y = self.tabSizeH
    end

    draw.RoundedBox(0, x, y, w, h, self.backgroundColor)

    -- Validate top tab container
    if self.cacheWidth ~= w and not self.verticalTabs then 
        self.tabContainerTop:SetWide(w) 
        self.cacheWidth = w
        self:ValidateMenu()
    end
end

vgui.Register("NadminTabMenu", NadminTabMenu, "DPanel")


-- Never made this use VGUI conventions, ended up not using it. Just holding onto the code just in case I decide I want to keep it
-- function nadmin.vgui:DSlider(pos, size, parent)
--     if not istable(pos) then pos = {0, 0} end
--     if not istable(size) then size = {ScrW(), 24} end

--     local slider = vgui.Create("DPanel", parent)
--     slider:SetPos(unpack(pos))
--     slider:SetSize(unpack(size))
--     slider.text = "Slider"
--     slider.font = "nadmin_derma"
--     slider.color = nadmin.colors.gui.theme
--     slider.textColor = nadmin:TextColor(slider.color)
--     slider.min, slider.max = 0, 2
--     slider.value = slider.min

--     local label = vgui.Create("DLabel", slider)
--     label:SetText(slider.text)
--     label:SetFont(slider.font)
--     label:SetTextColor(slider.textColor)
--     label:SizeToContentsX()
--     label:SetTall(size[2])
--     label:Dock(LEFT)

--     local slide = vgui.Create("DButton", slider)
--     slide:SetText("")
--     slide:Dock(FILL)
--     slide:DockMargin(0, 0, 4, 0)

--     local entry = nadmin.vgui:DTextEntry(nil, {size[2], size[2]}, slider)
--     entry:SetColor(nadmin:DarkenColor(slider.color, 25))
--     entry:Dock(RIGHT)
--     entry:SetText(slider.value)
--     entry:SetNumeric(true)

--     function slider:_RUNFUNC()
--         if isfunction(self.OnValueChanged) then self:OnValueChanged(self:GetValue()) end
--     end

--     function entry:OnTextChanged()
--         slider.value = tonumber(self:GetText()) or slider.min
--         slider:_RUNFUNC()
--     end

--     function entry:OnFocusChanged(gained)
--         if not gained then
--             if tonumber(self:GetText()) == nil then
--                 slider:SetValue(slider.min)
--             end
--         end
--         slider:_RUNFUNC()
--     end

--     function entry:OnKeyCode(key)
--         if key == KEY_UP then
--             slider:SetValue(slider.value + 1)
--             slider:_RUNFUNC()
--         elseif key == KEY_DOWN then
--             slider:SetValue(slider.value - 1)
--             slider:_RUNFUNC()
--         end
--     end

--     function slide:OnReleased()
--         local w, h = self:GetWide(), self:GetTall()

--         local pos = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
--         pos = math.min(pos, w - h/2 - 2)

--         local positions = {}
--         local dif = slider.max - slider.min
--         for i = 0, dif do
--             table.insert(positions, {h/2 + (i * (w - h)/dif), slider.min + i})
--         end

--         local value
--         for i = 1, #positions do
--             if pos > positions[i][1] then continue end

--             if istable(positions[i - 1]) then
--                 local dist1 = math.abs(pos - positions[i - 1][1])
--                 local dist2 = math.abs(pos - positions[i][1])
--                 if dist1 <= dist2 then
--                     value = positions[i - 1][2]
--                 else
--                     value = positions[i][2]
--                 end

--                 break
--             elseif pos > w then -- Mouse was after end of slider
--                 value = slider.max
--                 break
--             else  -- Mouse was before slider
--                 value = slider.min
--                 break
--             end
--         end

--         if isnumber(value) then
--             slider:SetValue(value)
--         end
--     end

--     function slide:Paint(w, h)
--         local wid = h/6
--         local height = h -- Help with telling what is what; slider ball height
--         local col = nadmin:BrightenColor(slider.color, 25)
--         draw.RoundedBox(0, height/2, h/2-wid/2, w - height, wid, col)

--         local dif = slider.max - slider.min
--         for i = 0, dif do
--             local x = i * (w - height)/dif
--             if i == 1 then
--                 x = x + wid/2
--             elseif i == dif then
--                 x = x - wid
--             end

--             draw.RoundedBox(0, height/2 + x, h/2, wid, h/2, col)
--         end

--         if self:IsDown() then
--             local x = self:ScreenToLocal(gui.MouseX(), gui.MouseY())
--             x = x - h/2 - 2
--             x = math.Clamp(x, 0, w - h - 2)

--             local y = height/2
--             draw.Circle(height/2 + wid/2 + x, y, height/2, 45, 360, 0, col)
--             draw.Circle(height/2 + wid/2 + x, y, wid, 15, 360, 0, nadmin.colors.gui.blue)
--         else
--             local x, y = (slider.value - slider.min) * (w - height)/dif - 2, height/2
--             draw.Circle(height/2 + wid/2 + x + wid/2, y, height/2, 45, 360, 0, col)
--             draw.Circle(height/2 + wid/2 + x + wid/2, y, wid, 15, 360, 0, nadmin:DarkenColor(col, 25))
--         end
--     end

--     function slider:Paint(w, h)
--         draw.RoundedBox(0, 0, 0, w, h, self:GetColor())
--     end

--     function slider:SetText(text)
--         if not isstring(text) then return end
--         self.text = text
--         label:SetText(text)
--         if text == "" then
--             label:SetWide(0)
--             slide:DockMargin(0, 0, 4, 0)
--         else
--             slide:DockMargin(4, 0, 4, 0)
--             label:SizeToContentsX()
--         end
--     end
--     function slider:GetText() return self.text end

--     function slider:SetFont(font)
--         if not isstring(font) then return end
--         self.font = font
--         label:SetFont(font)
--         if self:GetText() ~= "" then
--             label:SizeToContentsX()
--             slide:DockMargin(4, 0, 4, 0)
--         end
--     end
--     function slider:GetFont() return self.font end

--     function slider:SetColor(col, no_update)
--         if not IsColor(col) then return end
--         self.color = col

--         if not no_update then
--             self.textColor = nadmin:TextColor(col)
--         end
--     end
--     function slider:GetColor(col) return self.color end

--     function slider:SetTextColor(col)
--         if not IsColor(col) then return end
--         self.textColor = col
--     end
--     function slider:GetTextColor(col) return self.textColor end

--     function slider:SetMinValue(min)
--         if not isnumber(min) then return end
--         slider.min = min
--         if min > slider.value then self:SetValue(min) end
--     end
--     function slider:GetMinValue() return self.min end

--     function slider:SetMaxValue(max)
--         if not isnumber(max) then return end
--         slider.max = max
--         if max < slider.value then self:SetValue(max) end
--     end
--     function slider:GetMaxValue() return self.max end

--     function slider:SetClampValue(min, max)
--         if isnumber(min) then self.min = min end
--         if isnumber(max) then self.max = max end
--         if isnumber(min) or isnumber(max) then self:SetValue(math.Clamp(slider.value, min, max)) end
--     end
--     function slider:GetClampValue() return self.min, self.max end

--     function slider:SetValue(val)
--         if not isnumber(val) then return end
--         self.value = val
--         entry:SetText(tonumber(val))
--         slider:_RUNFUNC()
--     end
--     function slider:GetValue() return self.value end

--     return slider
-- end