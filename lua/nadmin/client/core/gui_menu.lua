nadmin.menu.tabs = nadmin.menu.tabs or {}
function nadmin.menu:RegisterTab(tbl)
    local tab = table.Copy(tbl)
    tab.title = nadmin:Ternary(isstring(tbl.title), tbl.title, "Undefined")
    tab.id = nadmin:Ternary(isstring(tbl.id), tbl.id, string.lower(string.Replace(tab.title, " ", "_")))
    tab.sort = nadmin:Ternary(isnumber(tbl.sort), tbl.sort, 0)
    tab.forcedPriv = nadmin:Ternary(isbool(tbl.forcedPriv), tbl.forcedPriv, false)
    tab.content = tbl.content
    for i, tb in ipairs(nadmin.menu.tabs) do
        if tb.id == tab.id then table.remove(nadmin.menu.tabs, i) end
    end
    tab.forcedPriv = nadmin:Ternary(isbool(tbl.forcedPriv), tbl.forcedPriv, false)
    if tab.forcedPriv then
        nadmin.forcedPrivs[tab.id] = true
    end
    table.insert(nadmin.menu.tabs, table.Copy(tab))
    return tab
end


nadmin.menu.current_tab = 1
function nadmin.menu:Open(tab, data)
    if IsValid(nadmin.menu.panel) then nadmin.menu.panel:Remove() end

    nadmin.menu.panel = vgui.Create("DFrame")
    nadmin.menu.panel:SetSize(ScrW() * 0.66, ScrH() * 0.66)
    nadmin.menu.panel:Center()
    nadmin.menu.panel:SetSizable(false)
    nadmin.menu.panel:SetDraggable(false)
    nadmin.menu.panel:ShowCloseButton(false)
    nadmin.menu.panel:SetTitle("")
    local icon = Material(nadmin.icons["nadmin"])
    function nadmin.menu.panel:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
        draw.RoundedBox(0, 0, 0, w, 28, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
        surface.SetDrawColor(255, 255, 255)
        surface.SetMaterial(icon)
        surface.DrawTexturedRect(4, 4, 20, 20)
        draw.Text({
            text = "Nadmin [" .. nadmin.version .. "]",
            pos = {28, 4},
            font = "nadmin_derma",
            color = nadmin:TextColor(nadmin.colors.gui.theme)
        })
    end
    nadmin.menu.panel:MakePopup()

    nadmin.menu.close = vgui.Create("DButton", nadmin.menu.panel)
    nadmin.menu.close:SetPos(nadmin.menu.panel:GetWide() - 40, 0)
    nadmin.menu.close:SetSize(40, 28)
    nadmin.menu.close:SetText("X")
    nadmin.menu.close:SetFont("nadmin_derma")
    function nadmin.menu.close:Paint(w, h)
        self:SetTextColor(nadmin:TextColor(nadmin.colors.gui.blue))
        draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.blue)
    end
    function nadmin.menu.close:DoClick()
        nadmin.menu:Close()
    end

    nadmin.menu.tab_display = vgui.Create("DPanel", nadmin.menu.panel)
    nadmin.menu.tab_display:SetPos(4, 60)
    nadmin.menu.tab_display:SetSize(nadmin.menu.panel:GetWide() - 8, nadmin.menu.panel:GetTall() - 64)
    function nadmin.menu.tab_display:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
    end

    local canSee = {}
    local r = LocalPlayer():GetRank()
    for i, tab in ipairs(nadmin.menu.tabs) do
        if LocalPlayer():HasPerm(tab.id) then
            table.insert(canSee, tab)
        end
    end
    table.sort(canSee, function(a, b) return a.sort < b.sort end)

    nadmin.menu.tab = {}
    for i, tab in ipairs(canSee) do
        nadmin.menu.tab[i] = {tab = table.Copy(tab)}
        nadmin.menu.tab[i].btn = vgui.Create("DButton", nadmin.menu.panel)
        nadmin.menu.tab[i].btn:SetSize(((nadmin.menu.panel:GetWide()-4) / #canSee) - 3.5, 28)
        nadmin.menu.tab[i].btn:SetPos(4 + ((i - 1) / #canSee) * (nadmin.menu.panel:GetWide()-4), 32)
        nadmin.menu.tab[i].btn:SetText(tab.title)
        nadmin.menu.tab[i].btn:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
        nadmin.menu.tab[i].btn:SetFont("nadmin_derma")
        nadmin.menu.tab[i].btn.Paint = function(self, w, h)
            if nadmin.menu.current_tab == i then
                if not isnumber(self.smoothStepStart) then
                    self.smoothStepStart = SysTime()
                end
                local smooth = nadmin:SmootherStep(self.smoothStepStart, self.smoothStepStart + 0.25, SysTime())
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                draw.RoundedBox(0, 0, h - h * smooth, w, h, nadmin.colors.gui.blue)
                self:SetTextColor(nadmin:TextColor(nadmin.colors.gui.blue))
            else
                if self:IsHovered() and not isnumber(self.smoothStepStart) then
                    self.smoothStepStart = SysTime()
                elseif not self:IsHovered() and isnumber(self.smoothStepStart) then
                    self.smoothStepStart = nil
                end

                draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                if isnumber(self.smoothStepStart) then
                    local smooth = nadmin:SmootherStep(self.smoothStepStart, self.smoothStepStart + 0.25, SysTime())
                    draw.RoundedBox(0, 0, h - h * smooth, w, h, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
                    draw.RoundedBox(0, 0, h - 2, w, 2, nadmin.colors.gui.blue)
                end
                self:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            end
        end
        nadmin.menu.tab[i].btn.DoClick = function(self)
            self.smoothStepStart = nil
            nadmin.menu:SetTab(i, data)
        end
    end
    nadmin.menu:SetTab(tab or 1, data)
end
function nadmin.menu:SetTab(tab, data)
    if IsValid(nadmin.menu.panel) then
        nadmin.menu.tab_display:Clear()

        if isnumber(tab) then
            nadmin.menu.current_tab = math.Clamp(tab, 1, #nadmin.menu.tab)
        elseif isstring(tab) then
            for i, tb in ipairs(nadmin.menu.tab) do
                if string.lower(tab) == string.lower(tb.tab.id) then
                    nadmin.menu.current_tab = i
                end
            end
        end

        if not istable(nadmin.menu.tab[nadmin.menu.current_tab]) then
            nadmin.menu.current_tab = 1
        elseif not IsValid(nadmin.menu.tab[nadmin.menu.current_tab].btn) then
            nadmin.menu.current_tab = 1
        end

        if istable(nadmin.menu.tab[nadmin.menu.current_tab].tab) then
            if isfunction(nadmin.menu.tab[nadmin.menu.current_tab].tab.content) then
                local success, err = pcall(nadmin.menu.tab[nadmin.menu.current_tab].tab.content, nadmin.menu.tab_display, data)
                if not success then
                    nadmin.menu.tab_display:Clear()
                    local t = vgui.Create("DLabel", nadmin.menu.tab_display)
                    t:SetPos(4, 4)
                    t:SetText("Error drawing contents:\n" .. err)
                    t:SetTextColor(nadmin.colors.gui.red)
                    t:SetFont("nadmin_derma")
                    t:SizeToContents()
                end
            else
                local t = vgui.Create("DLabel", nadmin.menu.tab_display)
                t:SetPos(4, 4)
                t:SetText("No content for this tab.")
                t:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                t:SetFont("nadmin_derma")
                t:SizeToContents()
            end
        end
    end
end
function nadmin.menu:Close()
    if IsValid(nadmin.menu.panel) then nadmin.menu.panel:Remove() end
end
