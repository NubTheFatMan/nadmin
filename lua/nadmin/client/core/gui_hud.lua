nadmin.hud = nadmin.hud or {}
nadmin.huds = nadmin.huds or {}

function nadmin.hud:Show(redraw)
    if IsValid(self.left) and redraw then self.left:Remove() end
    if IsValid(self.right) and redraw then self.right:Remove()end
    if not IsValid(self.left) then
        if not istable(nadmin.huds[nadmin.clientData.hudStyle]) then
            nadmin.plugins.hud = false
            self:Hide()
            nadmin:Notify(nadmin.colors.red, "Error drawing HUD:")
            nadmin:Notify(nadmin.colors.red, "Invalid HUD ID to render, please open the menu and select a new style.")
        else
            nadmin.plugins.hud = true

            local hud = nadmin.huds[nadmin.clientData.hudStyle]
            if istable(hud.left) and isfunction(hud.left.draw) then
                local height = nadmin:Ternary(isnumber(hud.left.height), hud.left.height, 76)
                self.left = vgui.Create("DPanel")
                self.left:SetSize(ScrW()/4 - 4, height)
                self.left:SetPos(4, ScrH() - height - 4)
                function self.left:Paint(w, h)
                    if not IsValid(LocalPlayer()) then return end
                    local success, err = pcall(hud.left.draw, self, w, h)
                    if not success then
                        nadmin.plugins.hud = false
                        nadmin.hud:Hide()
                        nadmin:Notify(nadmin.colors.red, "Error drawing HUD:")
                        nadmin:Notify(nadmin.colors.red, err)
                    end
                end
                -- Move the custom chatbox above it
                if nadmin.chatbox and IsValid(nadmin.chatbox.panel) then
                    nadmin.chatbox.panel:SetPos(4, ScrH() - height - nadmin.chatbox.panel:GetTall() - 8)
                    nadmin.chatbox.text.panel:SetPos(8, ScrH() - height - nadmin.chatbox.panel:GetTall() - 4)
                end
            end

            if istable(hud.right) and isfunction(hud.right.draw) then
                local height = nadmin:Ternary(isnumber(hud.right.height), hud.right.height, 40)
                self.right = vgui.Create("DPanel")
                self.right:SetSize(ScrW()/4 - 4, height)
                self.right:SetPos(ScrW() - self.right:GetWide() - 4, ScrH() - height - 4)
                function self.right:Paint(w, h)
                    if not IsValid(LocalPlayer()) then return end
                    local success, err = pcall(hud.right.draw, self, w, h)
                    if not success then
                        nadmin.plugins.hud = false
                        nadmin.hud:Hide()
                        nadmin:Notify(nadmin.colors.red, "Error drawing HUD:")
                        nadmin:Notify(nadmin.colors.red, err)
                    end
                end
            end
        end
    end
end

function nadmin.hud:Hide()
    if IsValid(self.left) then self.left:Remove() end
    if IsValid(self.right) then self.right:Remove() end
end

function nadmin.hud:CreateCustom(tbl)
    local hud = table.Copy(tbl)
    hud.title = nadmin:Ternary(isstring(tbl.title), tbl.title, "Undefined")
    nadmin.huds[hud.title] = hud
end
