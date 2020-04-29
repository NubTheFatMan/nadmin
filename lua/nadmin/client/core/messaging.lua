--Notifications

function nadmin:Notify(...) --CLIENT version
    local arg = {...}

    local args = {}
    for _, a in ipairs(arg) do
        if isstring(a) or istable(a) then table.insert(args, a)
        elseif tostring(a) then table.insert(args, a) end
    end

    chat.AddText(unpack(args))
end

net.Receive("nadmin_notification", function(len)
    local argc = net.ReadUInt(16)
    local args = {}
    for i = 1, argc do
        if net.ReadBit() == 1 then
            table.insert(args, Color(net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8), net.ReadUInt(8)))
        else
            table.insert(args, net.ReadString())
        end
    end

    local silent = net.ReadBool()
    if silent then
        table.insert(args, 1, nadmin.colors.white)
        table.insert(args, 2, "(")
        table.insert(args, 3, nadmin.colors.blue)
        table.insert(args, 4, "SILENT")
        table.insert(args, 5, nadmin.colors.white)
        table.insert(args, 6, ") ")
    end

    chat.AddText(unpack(args))
end)

net.Receive("nadmin_announcement", function()
    if IsValid(nadmin.announcement) then nadmin.announcement:Remove() end
    local text = net.ReadString()
    local dur  = net.ReadFloat()

    nadmin.announcement = vgui.Create("DPanel")
    nadmin.announcement:SetSize(0, 8)
    nadmin.announcement:SetPos(ScrW()/2, ScrH()/2-4)
    function nadmin.announcement:Paint(w, h)
        draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
    end

    local font = "nadmin_derma_large_b"
    surface.SetFont(font)
    local w, h = surface.GetTextSize(text)
    w = w + 8
    h = h + 10

    local x = ScrW()/2 - w/2
    local y = 4

    nadmin.announcement:MoveTo(x, ScrH()/2 - 4, 0.5)
    nadmin.announcement:SizeTo(w, -1, 0.5, 0, -1, function()
        nadmin.announcement:MoveTo(x, ScrH()/2 - h/2, 0.5)
        nadmin.announcement:SizeTo(-1, h, 0.5, 0, -1, function()
            local txt = vgui.Create("DLabel", nadmin.announcement)
            txt:SetText(text)
            txt:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
            txt:SetFont(font)
            txt:SizeToContents()
            txt:SetPos(nadmin.announcement:GetWide()/2 - txt:GetWide()/2, nadmin.announcement:GetTall()/2 - txt:GetTall()/2 - 1)
            txt:SetAlpha(0)

            local prog = vgui.Create("DPanel", nadmin.announcement)
            prog:SetSize(nadmin.announcement:GetWide(), 2)
            prog:SetPos(0, nadmin.announcement:GetTall() - prog:GetTall())
            function prog:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.blue)
            end
            prog:SetAlpha(0)

            txt:AlphaTo(255, 0.2)
            prog:AlphaTo(255, 0.2, 0, function()
                nadmin.announcement:MoveTo(x, y, 0.3, 0, -1, function()
                    prog:SizeTo(0, -1, dur)
                    prog:MoveTo(nadmin.announcement:GetWide()/2, h-2, dur, 0, -1, function()
                        nadmin.announcement:MoveTo(x, -nadmin.announcement:GetTall(), 0.3, 0, -1, function()
                            nadmin.announcement:Remove()
                        end)
                    end)
                end)
            end)
        end)
    end)
end)
