if CLIENT then
    nadmin.menu:RegisterTab({
        title = "Client Settings",
        sort = 4,
        forcedPriv = true,
        content = function(parent)
            local y = 4

            -- Color palets from https://visme.co/blog/color-combinations/
            local preset = vgui.Create("DComboBox", parent)
            preset:SetPos(4, y)
            preset:SetSize(parent:GetWide() - 8, 28)
            preset:SetFont("nadmin_derma")
            preset:SetValue("Color Preset")
            preset:SetSortItems(false)
            preset:AddChoice("Default", {
                main = nadmin.defaults.colors.gui.theme,
                blue = nadmin.defaults.colors.gui.blue,
                red  = nadmin.defaults.colors.gui.red
            })
            preset:AddChoice("Classic/Retro", {
                main = nadmin:HexToColor("#282726"),
                blue = nadmin:HexToColor("#6a8a82"),
                red  = nadmin:HexToColor("#a7414a")
            })
            preset:AddChoice("Orange Sunset", {
                main = nadmin:HexToColor("#a3586d"),
                blue = nadmin:HexToColor("#5c4a72"),
                red  = nadmin:HexToColor("#f3b05a")
            })
            preset:AddChoice("Refreshing and Invigorating", {
                main = nadmin:HexToColor("#003d73"),
                blue = nadmin:HexToColor("#1ecfd6"),
                red  = nadmin:HexToColor("#c05640")
            })
            preset:AddChoice("Sophisticated and Calm", {
                main = nadmin:HexToColor("#132226"),
                blue = nadmin:HexToColor("#525b56"),
                red  = nadmin:HexToColor("#be9063")
            })
            preset:AddChoice("Summer Blueberries", {
                main = nadmin:HexToColor("#f4f3f4"),
                blue = nadmin:HexToColor("#824ca7"),
                red  = nadmin:HexToColor("#d50b53")
            })
            preset:AddChoice("Sunset over Swamp", {
                main = nadmin:HexToColor("#6465a5"),
                blue = nadmin:HexToColor("#f3e96b"),
                red  = nadmin:HexToColor("#f05837")
            })
            preset:AddChoice("Vintage 1950s", {
                main = nadmin:HexToColor("#80add7"),
                blue = nadmin:HexToColor("#0abda0"),
                red  = nadmin:HexToColor("#bf9d7a")
            })
            y = y + preset:GetTall() + 4

            local thText = vgui.Create("DLabel", parent)
            thText:SetPos(4, y)
            thText:SetText("")
            thText:SetSize(parent:GetWide() - 8, 19)
            thText:SetFont("nadmin_derma")
            function thText:Paint(w, h)
                draw.Text({
                    text = "Main Color:",
                    font = self:GetFont(),
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            local main = vgui.Create("DColorMixer", parent)
            main:SetPos(4, y + 24)
            main:SetSize(parent:GetWide() - 8, 125)
            main:SetAlphaBar(false)
            main:SetColor(nadmin.colors.gui.theme)
            main:SetPalette(false)
            function main:ValueChanged(col)
                nadmin.colors.gui.theme = col
            end
            y = y + thText:GetTall() + main:GetTall() + 12

            local btnText = vgui.Create("DLabel", parent)
            btnText:SetPos(4, y)
            btnText:SetText("")
            btnText:SetSize(parent:GetWide() - 8, 19)
            btnText:SetFont("nadmin_derma")
            function btnText:Paint(w, h)
                draw.Text({
                    text = "Button Color:",
                    font = self:GetFont(),
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            local blue = vgui.Create("DColorMixer", parent)
            blue:SetPos(4, y + 24)
            blue:SetSize(parent:GetWide() - 8, 125)
            blue:SetAlphaBar(false)
            blue:SetColor(nadmin.colors.gui.blue)
            blue:SetPalette(false)
            function blue:ValueChanged(col)
                nadmin.colors.gui.blue = col
            end
            y = y + btnText:GetTall() + blue:GetTall() + 12

            local errText = vgui.Create("DLabel", parent)
            errText:SetPos(4, y)
            errText:SetText("")
            errText:SetSize(parent:GetWide() - 8, 19)
            errText:SetFont("nadmin_derma")
            function errText:Paint(w, h)
                draw.Text({
                    text = "Error Color:",
                    font = self:GetFont(),
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            local red = vgui.Create("DColorMixer", parent)
            red:SetPos(4, y + 24)
            red:SetSize(parent:GetWide() - 8, 125)
            red:SetAlphaBar(false)
            red:SetColor(nadmin.colors.gui.red)
            red:SetPalette(false)
            function red:ValueChanged(col)
                nadmin.colors.gui.red = col
            end
            y = y + errText:GetTall() + red:GetTall() + 8

            local reset = vgui.Create("DButton", parent)
            reset:SetPos(4, y)
            reset:SetSize(parent:GetWide() - 8, 24)
            reset:SetText("")
            function reset:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
                draw.Text({
                    text = "Reset Colors",
                    font = "nadmin_derma",
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.blue)
                })
            end
            function reset:DoClick()
                nadmin.colors.gui.theme = table.Copy(nadmin.defaults.colors.gui.theme)
                main:SetColor(nadmin.colors.gui.theme)

                nadmin.colors.gui.blue = table.Copy(nadmin.defaults.colors.gui.blue)
                blue:SetColor(nadmin.colors.gui.blue)

                nadmin.colors.gui.red = table.Copy(nadmin.defaults.colors.gui.red)
                red:SetColor(nadmin.colors.gui.red)
            end
            y = y + reset:GetTall() + 4

            function preset:OnSelect(ind, val, data)
                nadmin.colors.gui.theme = data.main
                main:SetColor(nadmin.colors.gui.theme)

                nadmin.colors.gui.blue = data.blue
                blue:SetColor(nadmin.colors.gui.blue)

                nadmin.colors.gui.red = data.red
                red:SetColor(nadmin.colors.gui.red)
            end
        end
    })
end
