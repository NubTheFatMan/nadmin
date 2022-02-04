-- NadminButton
local NadminButton = {}

function NadminButton:Init()
    self.text = "Button"
    self.font = "nadmin_derma"

    self.color = {}
    self.color.normal  = nadmin.colors.gui.blue
    self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
    self.color.down    = nadmin:BrightenColor(self.color.normal, 10)
    self.color.text    = nadmin:TextColor(self.color.normal)
    self.color.shadow  = nadmin:BrightenColor(self.color.normal, -50)

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

    function self:SetFont(font)
        if not isstring(font) then return end
        self.font = font
    end
    function self:GetFont()
        return self.font
    end

    function self:SetColor(color, noText)
        if not IsColor(color) then return end

        self.color.normal  = color
        self.color.hovered = nadmin:BrightenColor(self.color.normal, 25)
        self.color.down    = nadmin:BrightenColor(self.color.normal, 10)
        self.color.shadow  = nadmin:BrightenColor(self.color.normal, -50)

        if not noText then
            self.color.text = nadmin:TextColor(self.color.normal)
        end
    end
    function self:GetColor()
        return self.color.normal
    end

    function self:SetTextColor(color)
        if not IsColor(color) then return end

        self.color.text = color
    end
    function self:GetTextColor()
        return self.color.text
    end

    function self:GetPressSounds()
        if isnumber(self.selectedSound) then
            return self.buttonSounds[self.selectedSound]
        end
    end

    function self:SetPressSounds(ind)
        if not isnumber(ind) then return end

        self.selectedSound = ind
    end

    function self:PlayDown()
        local sounds = self:GetPressSounds()
        if istable(sounds) and isstring(sounds[1]) then
            surface.PlaySound(sounds[1])
        end
    end

    function self:PlayUp()
        local sounds = self:GetPressSounds()
        if istable(sounds) and isstring(sounds[2]) then
            surface.PlaySound(sounds[2])
        end
    end

    function self:OnDepressed()
        self:PlayDown()
    end
    function self:OnReleased()
        self:PlayUp()
    end

    function self:Paint(w, h) 
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

        draw.SimpleText(self:GetText(), self:GetFont(), w/2, h/2 + offset - 1, tc, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end
end