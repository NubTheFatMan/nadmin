nadmin.motd = nadmin.motd or {}

function nadmin.motd:Open(data)
    if IsValid(nadmin.motd.panel) then nadmin.motd.panel:Remove() end

    nadmin.motd.panel = nadmin.vgui:DFrame(nil, {ScrW() * 0.9, ScrH() * 0.9})
    local motd = nadmin.motd.panel

    motd:Center()
    motd:SetTitle("Message Of The Day")
    motd:ShowCloseButton(false)
    motd:MakePopup()

    motd.close = nadmin.vgui:DButton(nil, {motd:GetWide() - 8, 48}, motd)
    motd.close:Dock(BOTTOM)
    motd.close:DockMargin(4, 0, 4, 4)
    motd.close:SetText("Close")

    function motd.close:DoClick()
        motd:Remove()
    end

    if isstring(data) then
        motd.html = vgui.Create("DHTML", motd)
        motd.html:Dock(FILL)
        motd.html:DockMargin(4, 0, 4, 4)
        if string.StartWith(data, "http") then
            motd.html:OpenURL(data)
        else
            motd.html:SetHTML(data)
        end

        function motd.html:Paint(w, h)
            local tc = nadmin:TextColor(nadmin.colors.gui.theme)

            draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            draw.Circle(w/2, h/2, 16, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
            draw.Circle(w/2, h/2, 16, 360, 270, (SysTime() % 360) * 180, tc)
            draw.Circle(w/2, h/2, 14, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
        end

        function motd.html:OnFinishLoadingDocument()
            function self:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end
        end
    elseif istable(data) then

    else

    end
end

net.Receive("nadmin_open_motd", function()
    local using = net.ReadString()

    if using == "Generator" then

    elseif using == "Local File" or using == "URL" then
        nadmin.motd:Open(net.ReadString())
    end
end)
