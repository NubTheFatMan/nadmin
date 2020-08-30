nadmin.vote = nadmin.vote or {}

net.Receive("nadmin_cast_vote", function()
    nadmin.vote = net.ReadTable()

    local back = vgui.Create("DPanel")
    back:SetPos(0, 0)
    back:SetSize(ScrW(), ScrH())
    function back:Paint(w, h)
        if nadmin.vote.forcedResponse then
            draw.Blur(0, 0, w, h, Color(0, 0, 0))
        end
    end

    local panel = vgui.Create("DPanel", back)
    function panel:Paint(w, h)
        local now = os.time()
        if istable(nadmin.vote) and nadmin.vote.active and now - nadmin.vote.start < nadmin.vote.timeout then
            draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)

            draw.RoundedBox(0, 0, 0, w, 24, nadmin:BrightenColor(nadmin.colors.gui.theme, 25))
            draw.Text({
                text = nadmin.vote.title .. " [" .. (nadmin.vote.timeout - (now - nadmin.vote.start)) .. "s left]",
                pos = {4, 12},
                yalign = TEXT_ALIGN_CENTER,
                font = "nadmin_derma",
                color = nadmin.colors.gui.themeText
            })

            -- Now we want to cast a vote
            if input.IsKeyDown(KEY_1) and #nadmin.vote.choices >= 1 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[1])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_2) and #nadmin.vote.choices >= 2 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[2])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_3) and #nadmin.vote.choices >= 3 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[3])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_4) and #nadmin.vote.choices >= 4 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[4])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_5) and #nadmin.vote.choices >= 5 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[5])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_6) and #nadmin.vote.choices >= 6 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[6])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_7) and #nadmin.vote.choices >= 7 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[7])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_8) and #nadmin.vote.choices >= 8 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[8])
                net.SendToServer()
                back:Remove()
            elseif input.IsKeyDown(KEY_9) and #nadmin.vote.choices >= 9 then
                net.Start("nadmin_cast_vote")
                    net.WriteEntity(LocalPlayer())
                    net.WriteString(nadmin.vote.choices[9])
                net.SendToServer()
                back:Remove()
            end
        else
            back:Remove()
        end
    end

    local desc = vgui.Create("DLabel", panel)
    desc:SetText(nadmin.vote.description)
    desc:SetTextColor(nadmin.colors.gui.themeText)
    desc:SetFont("nadmin_derma")
    desc:SizeToContents()
    desc:SetPos(4, 28)

    panel:SetSize(ScrW()/5 - 8, 32 + desc:GetTall() + (#nadmin.vote.choices * 28) + ((#nadmin.vote.choices - 1) * 4))
    if not nadmin.vote.forcedResponse then
        panel:SetPos(4, ScrH()/2 - panel:GetTall())
    else
        panel:Center()
        back:MakePopup()
    end

    for i, choice in ipairs(nadmin.vote.choices) do
        local btn = vgui.Create("DButton", panel)
        btn:SetPos(4, 28 + desc:GetTall() + ((i - 1) * 32))
        btn:SetSize(panel:GetWide() - 8, 28)
        btn:SetText("")
        function btn:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:Ternary(self:IsHovered(), nadmin:BrightenColor(nadmin.colors.gui.blue, 25), nadmin.colors.gui.blue))

            draw.Text({
                text = "[" .. i .. "] " .. choice,
                pos = {4, 12},
                yalign = TEXT_ALIGN_CENTER,
                font = "nadmin_derma",
                color = nadmin.colors.gui.blueText
            })
        end
        function btn:DoClick()
            net.Start("nadmin_cast_vote")
                net.WriteEntity(LocalPlayer())
                net.WriteString(choice)
            net.SendToServer()
            back:Remove()
        end
    end
end)
