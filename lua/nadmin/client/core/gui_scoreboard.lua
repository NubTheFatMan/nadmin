function nadmin.scoreboard:Show()
    if IsValid(self.panel) then return end --We don't want duplicates

    local font_large       = "nadmin_derma_large"
    local font_large_bold  = "nadmin_derma_large_b"
    local font_normal      = "nadmin_derma"
    local font_normal_bold = "nadmin_derma_b"
    local font_small       = "nadmin_derma_small"
    local font_small_bold  = "nadmin_derma_small_b"
    local icon             = Material(nadmin.icons["nadmin"])

    self.sorting = self.sorting or "playtime"
    self.sort_hl = nadmin:Ternary(isbool(self.sort_hl), self.sort_hl, true)
    self.player = self.player or NULL
    self.cmd = self.cmd or NULL
    self.call = self.call or NULL
    self.shouldClose = self.shouldClose or false

    self.panel = vgui.Create("DFrame")
    self.panel:SetSize(ScrW()/2, 100)
    self.panel:SetSizable(false)
    self.panel:SetDraggable(false)
    self.panel:ShowCloseButton(false)
    self.panel:SetTitle("")
    self.panel:Center()
    self.panel:MakePopup()
    self.panel:SetKeyboardInputEnabled(false)

    if IsValid(self.player) and type(self.player) == "Player" then
        local back = Material(nadmin.icons["back_arrow"])
        if istable(self.cmd) then
            self.panel:SetTall(92 + (#self.cmd - 1)*44)
            self.panel:Center()
            self.panel:SetKeyboardInputEnabled(true)
            function self.panel:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
            end

            self.back = vgui.Create("DButton", self.panel)
            self.back:SetPos(4, 4)
            self.back:SetSize(40, 40)
            self.back:SetText("")
            function self.back:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
                local txtcol = nadmin:TextColor(nadmin.colors.gui.theme)
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                surface.SetMaterial(back)
                surface.DrawTexturedRect(4, h/2 - 16, 32, 32)
            end
            function self.back:DoClick()
                nadmin.scoreboard.cmd = NULL
                nadmin.scoreboard.call = NULL
                nadmin.scoreboard:Hide()
                nadmin.scoreboard:Show()
            end

            self.target = vgui.Create("DLabel", self.panel)
            self.target:SetPos(48, 4)
            self.target:SetSize(self.panel:GetWide()-52, 40)
            self.target:SetText("")
            function self.target:Paint(w, h)
                surface.SetFont(font_large)
                local wid = surface.GetTextSize("Target: " .. nadmin.scoreboard.player:Nick())
                draw.Text({
                    text = "Target: " .. nadmin.scoreboard.player:Nick(),
                    font = font_large,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " (" .. nadmin.scoreboard.player:SteamID() .. ")",
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end

            local function checkErr()
                local errored = false
                for i, arg in ipairs(nadmin.scoreboard.args) do
                    if not IsValid(arg) then continue end

                    if errored then break end
                    local types = string.Explode("/", arg.type)
                    if not table.HasValue(types, "any") then
                        if not isfunction(arg.GetText) then continue end
                        for x, t in ipairs(types) do
                            if t == "number" then
                                if not tonumber(arg:GetText()) then
                                    errored = true
                                end
                            end
                            if t == "time" then
                                if not isnumber(nadmin:ParseTime(arg:GetText())) then
                                    errored = true
                                end
                            end
                        end
                    end
                end
                return errored
            end

            local function commit(silent)
                if isstring(nadmin.scoreboard.call) and not checkErr() then
                    local args = {nadmin.scoreboard.player:SteamID()}
                    for i, arg in ipairs(nadmin.scoreboard.args) do
                        if not IsValid(arg) then continue end
                        if not isfunction(arg.GetText) then continue end

                        table.insert(args, arg:GetText())
                    end
                    LocalPlayer():ConCommand((silent and "nadmins" or "nadmin") .. " " .. nadmin.scoreboard.call .. " \""  .. table.concat(args, "\" \"") .. "\"")
                    nadmin.scoreboard:Hide()
                    nadmin.scoreboard.cmd = NULL
                    nadmin.scoreboard.call = NULL
                end
            end

            local apply = vgui.Create("DButton", self.panel)
            apply:SetPos(4, self.panel:GetTall() - 44)
            apply:SetSize(self.panel:GetWide() - 8, 40)
            apply:SetText("Apply")
            apply:SetTextColor(nadmin:TextColor(nadmin.colors.gui.blue))
            apply:SetFont(font_large)
            function apply:Paint(w, h)
                local errored = checkErr()

                local color = nadmin:Ternary(errored, nadmin.colors.gui.red, nadmin.colors.gui.blue)
                if self:IsHovered() then color = nadmin:BrightenColor(color, 25) end
                draw.RoundedBox(0, 0, 0, w, h, color)
                self:SetTextColor(nadmin:Ternary(errored, nadmin:TextColor(nadmin.colors.gui.red), nadmin:TextColor(nadmin.colors.gui.blue)))
            end
            function apply:DoClick()
                commit(false)
            end
            function apply:DoRightClick()
                commit(true)
            end

            self.args = {}
            local i = 0
            for ind = 2, #self.cmd do
                local arg = self.cmd[ind]
                i = i + 1

                local l = vgui.Create("DLabel", self.panel)
                l:SetText(arg.text .. ":")
                l:SetFont(font_large)
                l:SetTextColor(nadmin:TextColor(nadmin.colors.gui.theme))
                l:SizeToContents()
                l:SetPos(4, 8 + 44*i)

                if arg.type == "player" then
                    self.args[i] = vgui.Create("DComboBox", self.panel)
                    self.args[i]:SetPos(l:GetWide() + 8, 4 + 44*i)
                    self.args[i]:SetSize(self.panel:GetWide() - 12 - l:GetWide(), 40)
                    self.args[i]:SetFont(font_large)
                    self.args[i]:SetValue("Select a player...")

                    local target_mode = nadmin.MODE_ALL
                    if isnumber(arg.targetMode) then target_mode = arg.targetMode end

                    local plys = {}
                    for i, ply in ipairs(player.GetAll()) do
                        if target_mode == nadmin.MODE_ALL then table.insert(plys, ply) continue end

                        if target_mode == nadmin.MODE_SAME then
                            if LocalPlayer():BetterThanOrEqual(ply) then table.insert(plys, ply) continue end
                        elseif target_mode == nadmin.MODE_BELOW then
                            if LocalPlayer():BetterThan(ply) then table.insert(plys, ply) continue end
                        end
                    end

                    local canTargSelf = true
                    if isbool(arg.canTargetSelf) then canTargSelf = arg.canTargSelf end

                    if table.HasValue(plys, LocalPlayer()) and not canTargSelf then
                        for i, ply in ipairs(plys) do
                            if ply == LocalPlayer() then table.remove(plys, i) break end
                        end
                    end

                    table.sort(plys, function(a, b) return a:Nick() < b:Nick() end)

                    local combo = self.args[i]
                    for i, ply in ipairs(plys) do
                        combo:AddChoice(ply:Nick() .. " (" .. ply:SteamID() .. ")", ply:SteamID())
                    end
                elseif arg.type == "dropdown" then
                    self.args[i] = vgui.Create("DComboBox", self.panel)
                    self.args[i]:SetPos(l:GetWide() + 8, 4 + 44*i)
                    self.args[i]:SetSize(self.panel:GetWide() - 12 - l:GetWide(), 40)
                    self.args[i]:SetFont(font_large)
                    self.args[i]:SetSortItems(false)
                    local options = {}
                    if isstring(arg.options) then
                        local r = LocalPlayer():GetRank()
                        local tr = self.player:GetRank()
                        if arg.options == "ranks_below" then
                            for x, rank in pairs(nadmin.ranks) do
                                if rank.immunity < r.immunity and rank ~= tr then
                                    table.insert(options, rank)
                                end
                            end
                        elseif arg.options == "ranks_same" then
                            for x, rank in pairs(nadmin.ranks) do
                                if rank.immunity <= r.immunity and rank ~= tr then
                                    table.insert(options, rank)
                                end
                            end
                        elseif arg.options == "ranks" then
                            for x, rank in pairs(nadmin.ranks) do
                                if rank ~= tr then
                                    table.insert(options, rank)
                                end
                            end
                        end
                    elseif istable(arg.type) then
                        options = arg.options
                    end

                    table.sort(options, function(a, b) if istable(a) and istable(b) then return a.immunity < b.immunity else return a < b end end)

                    local rank = self.player:GetRank()
                    self.args[i]:SetValue(rank.id .. " | " .. rank.title)

                    for x, option in ipairs(options) do
                        if istable(option) then
                            self.args[i]:AddChoice(option.id .. " | " .. option.title)
                        elseif isstring(option) then
                            self.args[i]:AddChoice(option)
                        end
                    end
                else
                    self.args[i] = vgui.Create("DTextEntry", self.panel)
                    self.args[i]:SetPos(l:GetWide() + 8, 4 + 44*i)
                    self.args[i]:SetSize(self.panel:GetWide() - 12 - l:GetWide(), 40)
                    self.args[i]:SetFont(font_large)

                    if arg.default ~= nil then self.args[i]:SetText(tostring(arg.default)) end

                    local edit = self.args[i]
                    function edit:Paint(w, h)
                        local errored = false
                        local types = string.Explode("/", arg.type)
                        if not table.HasValue(types, "any") then
                            for i, t in ipairs(types) do
                                if t == "number" then
                                    errored = false
                                    if not tonumber(self:GetText()) then
                                        errored = true
                                    end
                                end
                                if t == "time" then
                                    errored = false
                                    if not isnumber(nadmin:ParseTime(self:GetText())) then
                                        errored = true
                                    end
                                end
                            end
                        end
                        draw.RoundedBox(0, 0, h-4, w, 4, nadmin:Ternary(errored, nadmin.colors.gui.red, nadmin.colors.gui.blue))

                        if #self:GetText() == 0 then
                            draw.Text({
                                text = arg.type .. ":" .. arg.text,
                                font = self:GetFont(),
                                pos = {0, h/2},
                                yalign = TEXT_ALIGN_CENTER,
                                color = nadmin:BrightenColor(nadmin.colors.gui.theme, 50)
                            })
                        end

                        self:DrawTextEntryText(nadmin:TextColor(nadmin.colors.gui.theme), nadmin.colors.gui.blue, nadmin:TextColor(nadmin.colors.gui.theme))
                    end
                end

                self.args[i].type = arg.type
            end
        else
            if self.shouldClose then self:Hide() self.shouldClose = false end
            local mute = Material("icon16/sound.png")
            local unmute = Material("icon16/sound_mute.png")
            local copy = Material("icon16/page_white_copy.png")

            local y = 4

            self.panel:SetTall(280)
            self.panel:Center()
            function self.panel:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)
            end

            self.back = vgui.Create("DButton", self.panel)
            self.back:SetPos(4, 4)
            self.back:SetSize(40, 220)
            self.back:SetText("")
            function self.back:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
                surface.SetDrawColor(nadmin:TextColor(nadmin.colors.gui.blue).r, nadmin:TextColor(nadmin.colors.gui.blue).g, nadmin:TextColor(nadmin.colors.gui.blue).b)
                surface.SetMaterial(back)
                surface.DrawTexturedRect(4, h/2 - 16, 32, 32)
            end
            function self.back:DoClick()
                nadmin.scoreboard.player = NULL
                nadmin.scoreboard:Hide()
                nadmin.scoreboard:Show()
            end

            local avatar = vgui.Create("AvatarImage", self.panel)
            avatar:SetPos(48, 4)
            avatar:SetSize(184, 184)
            avatar:SetPlayer(self.player, 184)

            if self.player:SteamID64() == "76561198142667790" then 
                local dev = vgui.Create("DImageButton", avatar)
                dev:SetPos(4, 4)
                dev:SetSize(16, 16)
                dev:SetImage("icon16/star.png")
                dev:SetToolTip("This person is a developer of this administration mod\nClick to open their website")
                function dev:DoClick()
                    gui.OpenURL("https://nubstoys.xyz/")
                end
            end

            local name = vgui.Create("DLabel", self.panel)
            name:SetPos(48, 188)
            name:SetSize(184, 32)
            name:SetText("")
            function name:Paint(w, h)
                local nick = nadmin.scoreboard.player:Nick()
                local f = font_large
                surface.SetFont(f)
                local wid = surface.GetTextSize(nick)
                if wid > w then
                    f = font_normal
                    surface.SetFont(f)
                    wid = surface.GetTextSize(nick)
                    if wid > w then
                        f = font_small
                    end
                end
                draw.Text({
                    text = nick,
                    font = f,
                    pos = {w/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end

            local info = vgui.Create("DPanel", self.panel)
            info:SetPos(self.back:GetWide() + avatar:GetWide() + 12, 4)
            info:SetSize(self.panel:GetWide() - (self.back:GetWide() + avatar:GetWide() + 16), 220)
            function info:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end

            local health = vgui.Create("DPanel", info)
            health:SetPos(4, y)
            health:SetSize(info:GetWide()/2 - 6, 16)
            function health:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(nadmin.colors.gui.health, 25))
                local hp = math.Clamp((nadmin.scoreboard.player:Health() / nadmin.scoreboard.player:GetMaxHealth()), 0, 1)
                draw.RoundedBox(0, 0, 0, w * hp, h, nadmin.colors.gui.health)
            end
            local armor = vgui.Create("DPanel", info)
            armor:SetPos(info:GetWide()/2 + 2, y)
            armor:SetSize(health:GetWide(), 16)
            function armor:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:AlphaColor(nadmin.colors.gui.armor, 25))
                local a = math.Clamp((nadmin.scoreboard.player:Armor() / 100), 0, 1)
                draw.RoundedBox(0, 0, 0, w * a, h, nadmin.colors.gui.armor)
            end
            y = y + health:GetTall() + 4

            if nadmin.plugins.levels then
                local lvl = vgui.Create("DButton", info)
                lvl:SetPos(4, y)
                lvl:SetSize(info:GetWide() - 8, 16)
                lvl:SetText("")
                function lvl:Paint(w, h)
                    local info = nadmin.scoreboard.player:GetLevel()
                    surface.SetFont(font_small)

                    local lvl = "LVL: " .. tostring(info.level) .. " (XP: " .. tostring(info.xp) .. "/" .. tostring(info.need) .. ")"

                    local wid = surface.GetTextSize(lvl) + 8
                    draw.RoundedBox(0, 0, 0, wid, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
                    draw.Text({
                        text = lvl,
                        font = font_small,
                        pos = {wid/2, h/2},
                        xalign = TEXT_ALIGN_CENTER,
                        yalign = TEXT_ALIGN_CENTER,
                        color = nadmin:TextColor(nadmin.colors.gui.theme)
                    })

                    local wBar = w - wid - 4
                    local xp = math.Clamp(info.xp/info.need, 0, 1)
                    draw.RoundedBox(0, wid+4, 0, wBar, h, nadmin:AlphaColor(nadmin.colors.gui.xp, 50))
                    draw.RoundedBox(0, wid+4, 0, wBar * xp, h, nadmin.colors.gui.xp)

                    if self:IsHovered() then
                        local copy = "Click to Copy"
                        local width = surface.GetTextSize(copy)
                        local xPos = math.Clamp(gui.MouseX() - self:LocalToScreen(0, 0), (wid + 8) + width/2, w - width/2 - 4)
                        draw.Text({
                            text = copy,
                            font = font_small,
                            pos = {xPos, h/2},
                            xalign = TEXT_ALIGN_CENTER,
                            yalign = TEXT_ALIGN_CENTER,
                            color = Color(255, 255, 255)
                        })
                    end
                end
                function lvl:DoClick()
                    local info = nadmin.scoreboard.player:GetLevel()
                    SetClipboardText("LVL: " .. tostring(info.level) .. " (XP: " .. tostring(info.xp) .. "/" .. tostring(info.need) .. ")")
                    notification.AddLegacy("Level copied to clipboard!", NOTIFY_HINT, 3)
                    surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
                end
                y = y + lvl:GetTall() + 4
            end

            local copySteam = vgui.Create("DButton", info)
            copySteam:SetPos(4, y)
            copySteam:SetSize(24, 24)
            copySteam:SetText("")
            function copySteam:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copySteam:DoClick()
                SetClipboardText(nadmin.scoreboard.player:SteamID())
                notification.AddLegacy("Steam ID copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copySteamL = vgui.Create("DLabel", info)
            copySteamL:SetPos(32, y)
            copySteamL:SetSize(info:GetWide() - 36, 24)
            copySteamL:SetText("")
            function copySteamL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Steam ID:")
                draw.Text({
                    text = "Steam ID:",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " " .. nadmin.scoreboard.player:SteamID(),
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            y = y + copySteam:GetTall() + 4

            local copyKills = vgui.Create("DButton", info)
            copyKills:SetPos(4, y)
            copyKills:SetSize(24, 24)
            copyKills:SetText("")
            function copyKills:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copyKills:DoClick()
                SetClipboardText(nadmin.scoreboard.player:Frags())
                notification.AddLegacy("Kills copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copyKillsL = vgui.Create("DLabel", info)
            copyKillsL:SetPos(32, y)
            copyKillsL:SetSize(info:GetWide() - 36, 24)
            copyKillsL:SetText("")
            function copyKillsL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Kills:")
                draw.Text({
                    text = "Kills:",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " " .. nadmin.scoreboard.player:Frags(),
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            y = y + copyKills:GetTall() + 4

            local copyDeaths = vgui.Create("DButton", info)
            copyDeaths:SetPos(4, y)
            copyDeaths:SetSize(24, 24)
            copyDeaths:SetText("")
            function copyDeaths:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copyDeaths:DoClick()
                SetClipboardText(nadmin.scoreboard.player:Deaths())
                notification.AddLegacy("Deaths copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copyDeathsL = vgui.Create("DLabel", info)
            copyDeathsL:SetPos(32, y)
            copyDeathsL:SetSize(info:GetWide() - 36, 24)
            copyDeathsL:SetText("")
            function copyDeathsL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Deaths:")
                draw.Text({
                    text = "Deaths:",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " " .. nadmin.scoreboard.player:Deaths(),
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            y = y + copyDeaths:GetTall() + 4

            local copyPlaytime = vgui.Create("DButton", info)
            copyPlaytime:SetPos(4, y)
            copyPlaytime:SetSize(24, 24)
            copyPlaytime:SetText("")
            function copyPlaytime:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copyPlaytime:DoClick()
                SetClipboardText(nadmin:TimeToString(nadmin.scoreboard.player:GetPlayTime(), true))
                notification.AddLegacy("Playtime copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copyPlaytimeL = vgui.Create("DLabel", info)
            copyPlaytimeL:SetPos(32, y)
            copyPlaytimeL:SetSize(info:GetWide() - 36, 24)
            copyPlaytimeL:SetText("")
            function copyPlaytimeL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Playtime:")
                draw.Text({
                    text = "Playtime:",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " " .. nadmin:TimeToString(nadmin.scoreboard.player:GetPlayTime(), true),
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            y = y + copyPlaytime:GetTall() + 4

            local copyPing = vgui.Create("DButton", info)
            copyPing:SetPos(4, y)
            copyPing:SetSize(24, 24)
            copyPing:SetText("")
            function copyPing:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copyPing:DoClick()
                SetClipboardText(nadmin.scoreboard.player:Ping())
                notification.AddLegacy("Ping copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copyPingL = vgui.Create("DLabel", info)
            copyPingL:SetPos(32, y)
            copyPingL:SetSize(info:GetWide() - 36, 24)
            copyPingL:SetText("")
            function copyPingL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Ping:")
                draw.Text({
                    text = "Ping:",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
                draw.Text({
                    text = " " .. nadmin.scoreboard.player:Ping(),
                    font = font_normal,
                    pos = {wid, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })
            end
            y = y + copyPing:GetTall() + 4

            local copyRank = vgui.Create("DButton", info)
            copyRank:SetPos(4, y)
            copyRank:SetSize(24, 24)
            copyRank:SetText("")
            function copyRank:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(4, 4, 16, 16)
            end
            function copyRank:DoClick()
                SetClipboardText(nadmin.scoreboard.player:GetRank().title)
                notification.AddLegacy("Rank copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            local copyRankL = vgui.Create("DLabel", info)
            copyRankL:SetPos(32, y)
            copyRankL:SetSize(info:GetWide() - 36, 24)
            copyRankL:SetText("")
            local ranks = {}
            for i, rank in pairs(nadmin.ranks) do
                ranks[rank.id] = Material(rank.icon)
            end
            function copyRankL:Paint(w, h)
                surface.SetFont(font_normal_bold)
                local wid = surface.GetTextSize("Rank:")
                draw.Text({
                    text = "Rank: ",
                    font = font_normal_bold,
                    pos = {0, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.theme)
                })

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(ranks[nadmin.scoreboard.player:GetRank().id])
                surface.DrawTexturedRect(wid + 4, 4, 16, 16)

                draw.Text({
                    text = nadmin.scoreboard.player:GetRank().title,
                    font = font_normal,
                    pos = {wid + 24, h/2},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin.scoreboard.player:GetRank().color
                })
            end
            y = y + copyRank:GetTall() + 4

            local copyAll = vgui.Create("DButton", info)
            copyAll:SetPos(4, y)
            copyAll:SetSize(info:GetWide() - 8, 24)
            copyAll:SetText("")
            function copyAll:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                surface.SetFont(font_normal)
                local wid = surface.GetTextSize("Copy All") + 24

                surface.SetDrawColor(255, 255, 255)
                surface.SetMaterial(copy)
                surface.DrawTexturedRect(w/2 - wid/2, 4, 16, 16)

                draw.Text({
                    text = "Copy All",
                    font = font_normal,
                    pos = {w/2 - wid/2 + 20, 12},
                    yalign = TEXT_ALIGN_CENTER,
                    color = nadmin:TextColor(nadmin.colors.gui.blue)
                })
            end
            function copyAll:DoClick()
                local ply = nadmin.scoreboard.player
                local info = ply:GetLevel()
                local str = "Player: " .. ply:Nick()
                str = str .. "\n" .. "Steam ID: " .. ply:SteamID()
                str = str .. "\n" .. "Kills: " .. ply:Frags()
                str = str .. "\n" .. "Deaths: " .. ply:Deaths()
                str = str .. "\n" .. "Playtime: " .. nadmin:TimeToString(ply:GetPlayTime(), true)
                str = str .. "\n" .. "Ping: " .. ply:Ping()
                str = str .. "\n" .. "Rank: " .. ply:GetRank().title
                str = str .. "\n" .. "Level: " .. tostring(info.level) .. " (XP: " .. tostring(info.xp) .. "/" .. tostring(info.need) .. ")"
                SetClipboardText(str)
                notification.AddLegacy("All player info copied to clipboard!", NOTIFY_HINT, 3)
                surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
            end
            y = y + copyAll:GetTall() + 4

            self.back:SetTall(y)
            info:SetTall(y)
            name:SetTall(y - 184)

            local perms = {{"local_mute"}} --Hardcoded permission; everyone should have it

            local ind = 1
            local r = LocalPlayer():GetRank()
            local r2 = self.player:GetRank()
            for id, cmd in pairs(nadmin.commands) do
                if istable(cmd.scoreboard) then
                    if not istable(cmd.advUsage) then continue end
                    if not table.IsSequential(cmd.advUsage) then continue end
                    if cmd.advUsage[1].type ~= "player" then continue end

                    if LocalPlayer():HasPerm(id) then
                        if isbool(cmd.scoreboard.canTargetSelf) and not cmd.scoreboard.canTargetSelf and LocalPlayer() == self.player then continue end
                        if cmd.scoreboard.targetMode == nadmin.MODE_BELOW and not (r.immunity > r2.immunity) and self.player ~= LocalPlayer() then continue end
                        if cmd.scoreboard.targetMode == nadmin.MODE_SAME and not (r.immunity >= r2.immunity) then continue end
                        if #perms[ind] >= 6 then
                            ind = ind + 1
                            if not perms[ind] then perms[ind] = {} end
                        end
                        table.insert(perms[ind], id)
                    end
                end
            end

            self.panel:SetTall(y + 12 + (#perms * 48) + ((#perms - 1) * 4))
            self.panel:Center()

            for x, perm in ipairs(perms) do
                for i, p in ipairs(perm) do
                    local btn = vgui.Create("DButton", self.panel)
                    btn:SetSize((self.panel:GetWide()/#perms[x] + (#perms[x]-1)/1.5) - 8, 48)
                    btn:SetPos((i*4) + ((i-1)*btn:GetWide()), y + 8 + (x-1)*52)
                    local px = btn:GetPos()
                    if i == #perm and px + btn:GetWide() ~= self.panel:GetWide() - 4 then
                        local dif = (self.panel:GetWide()-4) - (px+btn:GetWide())
                        btn:SetWide(btn:GetWide() + dif)
                    end
                    btn:SetText(string.Replace(string.upper(string.sub(p, 1, 1)) .. string.sub(p, 2), "_", " "))
                    btn:SetFont(font_normal)
                    btn:SetTextColor(Color(0, 0, 0, 0))
                    if p == "local_mute" then
                        function btn:Paint(w, h)
                            local muted = nadmin.scoreboard.player:IsMuted()
                            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                            surface.SetDrawColor(255, 255, 255)
                            surface.SetMaterial(nadmin:Ternary(muted, unmute, mute))
                            surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

                            draw.Text({
                                text = nadmin:Ternary(muted, "Unmute", "Mute"),
                                font = font_normal,
                                pos = {w/2, h-4},
                                xalign = TEXT_ALIGN_CENTER,
                                yalign = TEXT_ALIGN_BOTTOM,
                                color = nadmin:TextColor(nadmin.colors.gui.blue)
                            })
                        end
                        function btn:DoClick(w, h)
                            nadmin.scoreboard.player:SetMuted(!nadmin.scoreboard.player:IsMuted())
                        end
                    else
                        local sb = nadmin.commands[p]
                        if not (istable(sb) and istable(sb.scoreboard)) then --Command must have been deleted somehow, skip
                            continue
                        end
                        sb = sb.scoreboard

                        function btn:Paint(w, h)
                            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))

                            local f = font_normal
                            surface.SetFont(f)
                            local wid = surface.GetTextSize(self:GetText())
                            if wid > w then f = font_small end
                            local txt = {
                                text = self:GetText(),
                                font = font_normal,
                                pos = {w/2, h-4},
                                xalign = TEXT_ALIGN_CENTER,
                                yalign = TEXT_ALIGN_BOTTOM,
                                color = nadmin:TextColor(nadmin.colors.gui.blue)
                            }
                            if isfunction(sb.iconRender) then
                                sb.iconRender(self, w, h, nadmin.scoreboard.player)
                            else
                                txt.pos[2] = h/2
                                txt.yalign = TEXT_ALIGN_CENTER
                            end
                            draw.Text(txt)
                        end
                        function btn:DoClick()
                            if isfunction(sb.OnClick) then sb.OnClick(nadmin.scoreboard.player, false) end
                        end
                        function btn:DoRightClick()
                            if isfunction(sb.OnClick) then sb.OnClick(nadmin.scoreboard.player, true) end
                        end
                    end
                end
            end
        end
    else
        if self.shouldClose then self:Hide() self.shouldClose = false end
        function self.panel:Paint(w, h)
            draw.RoundedBoxEx(34, 0, 0, w, h, nadmin.colors.gui.theme, true, false, false, false)
            draw.RoundedBoxEx(34, 0, 0, w, 92, nadmin.colors.gui.blue, true, false, false, false)

            surface.SetDrawColor(255, 255, 255)
            surface.SetMaterial(icon)
            surface.DrawTexturedRect(4, 4, 64, 64)

            surface.SetFont(font_large)
            local tw, th = surface.GetTextSize(GetHostName())
            surface.SetFont(font_normal)
            local sw, sh = surface.GetTextSize(game.GetIPAddress())

            draw.Text({
                text = GetHostName(),
                pos = {w/2, 4},
                xalign = TEXT_ALIGN_CENTER,
                font = font_large,
                color = nadmin:TextColor(nadmin.colors.gui.blue)
            })
            draw.Text({
                text = game.GetIPAddress(),
                pos = {w/2, th/2 + sh/2 + 12},
                xalign = TEXT_ALIGN_CENTER,
                font = font_normal,
                color = nadmin:DarkenColor(nadmin:TextColor(nadmin.colors.gui.blue), 25)
            })
            draw.Text({
                text = "TPS: " .. tostring(math.Round(1/engine.ServerFrameTime())),
                pos = {w - 4, th/2 + sh/2 + 12},
                xalign = TEXT_ALIGN_RIGHT,
                font = font_normal,
                color = nadmin:DarkenColor(nadmin:TextColor(nadmin.colors.gui.blue), 25)
            })
        end

        local txtcol = nadmin:TextColor(nadmin.colors.gui.blue)
        -- Sorting options: Name, Kills, Deaths, Playtime, Ping
        local sort_names = vgui.Create("DButton", self.panel)
        sort_names:SetPos(32, 72)
        sort_names:SetSize(self.panel:GetWide()/2 - 32, 16)
        sort_names:SetText("Name")
        sort_names:SetFont(font_small)
        sort_names:SetTextColor(txtcol)
        function sort_names:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:Ternary(self:IsHovered(), nadmin:BrightenColor(nadmin.colors.gui.blue, 25), nadmin.colors.gui.blue))
            if nadmin.scoreboard.sorting == "name" then
                local points = {}
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                draw.NoTexture()
                surface.SetFont(font_small)
                local tw = surface.GetTextSize(self:GetText())
                local offset = w/2 + tw/2 + 2
                if nadmin.scoreboard.sort_hl then
                    points[1] = {x = offset, y = 4}
                    points[2] = {x = offset + 8, y = 4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = h-4}
                else
                    points[1] = {x = offset + 8, y = h-4}
                    points[2] = {x = offset, y = h-4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = 4}
                end
                surface.DrawPoly(points)
            end
        end
        function sort_names:DoClick()
            if nadmin.scoreboard.sorting ~= "name" then
                nadmin.scoreboard.sorting = "name"
            else
                nadmin.scoreboard.sort_hl = !nadmin.scoreboard.sort_hl
            end
            nadmin.scoreboard.lastPlayerCount = 0 --Refresh the scoreboard
        end

        local sort_kills = vgui.Create("DButton", self.panel)
        sort_kills:SetPos(self.panel:GetWide()/2, 72)
        sort_kills:SetSize(self.panel:GetWide()/8, 16)
        sort_kills:SetText("Kills")
        sort_kills:SetFont(font_small)
        sort_kills:SetTextColor(txtcol)
        function sort_kills:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
            if nadmin.scoreboard.sorting == "kills" then
                local points = {}
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                draw.NoTexture()
                surface.SetFont(font_small)
                local tw = surface.GetTextSize(self:GetText())
                local offset = w/2 + tw/2 + 2
                if nadmin.scoreboard.sort_hl then
                    points[1] = {x = offset, y = 4}
                    points[2] = {x = offset + 8, y = 4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = h-4}
                else
                    points[1] = {x = offset + 8, y = h-4}
                    points[2] = {x = offset, y = h-4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = 4}
                end
                surface.DrawPoly(points)
            end
        end
        function sort_kills:DoClick()
            if nadmin.scoreboard.sorting ~= "kills" then
                nadmin.scoreboard.sorting = "kills"
            else
                nadmin.scoreboard.sort_hl = !nadmin.scoreboard.sort_hl
            end
            nadmin.scoreboard.lastPlayerCount = 0 --Refresh the scoreboard
        end

        local sort_deaths = vgui.Create("DButton", self.panel)
        sort_deaths:SetSize(self.panel:GetWide()/8, 16)
        sort_deaths:SetPos(self.panel:GetWide()/2 + sort_deaths:GetWide(), 72)
        sort_deaths:SetText("Deaths")
        sort_deaths:SetFont(font_small)
        sort_deaths:SetTextColor(txtcol)
        function sort_deaths:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
            if nadmin.scoreboard.sorting == "deaths" then
                local points = {}
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                draw.NoTexture()
                surface.SetFont(font_small)
                local tw = surface.GetTextSize(self:GetText())
                local offset = w/2 + tw/2 + 2
                if nadmin.scoreboard.sort_hl then
                    points[1] = {x = offset, y = 4}
                    points[2] = {x = offset + 8, y = 4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = h-4}
                else
                    points[1] = {x = offset + 8, y = h-4}
                    points[2] = {x = offset, y = h-4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = 4}
                end
                surface.DrawPoly(points)
            end
        end
        function sort_deaths:DoClick()
            if nadmin.scoreboard.sorting ~= "deaths" then
                nadmin.scoreboard.sorting = "deaths"
            else
                nadmin.scoreboard.sort_hl = !nadmin.scoreboard.sort_hl
            end
            nadmin.scoreboard.lastPlayerCount = 0 --Refresh the scoreboard
        end

        local sort_playtime = vgui.Create("DButton", self.panel)
        sort_playtime:SetSize(self.panel:GetWide()/8, 16)
        sort_playtime:SetPos(self.panel:GetWide()/2 + sort_deaths:GetWide()*2, 72)
        sort_playtime:SetText("Playtime")
        sort_playtime:SetFont(font_small)
        sort_playtime:SetTextColor(txtcol)
        function sort_playtime:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
            if nadmin.scoreboard.sorting == "playtime" then
                local points = {}
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                draw.NoTexture()
                surface.SetFont(font_small)
                local tw = surface.GetTextSize(self:GetText())
                local offset = w/2 + tw/2 + 2
                if nadmin.scoreboard.sort_hl then
                    points[1] = {x = offset, y = 4}
                    points[2] = {x = offset + 8, y = 4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = h-4}
                else
                    points[1] = {x = offset + 8, y = h-4}
                    points[2] = {x = offset, y = h-4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = 4}
                end
                surface.DrawPoly(points)
            end
        end
        function sort_playtime:DoClick()
            if nadmin.scoreboard.sorting ~= "playtime" then
                nadmin.scoreboard.sorting = "playtime"
            else
                nadmin.scoreboard.sort_hl = !nadmin.scoreboard.sort_hl
            end
            nadmin.scoreboard.lastPlayerCount = 0 --Refresh the scoreboard
        end

        local sort_ping = vgui.Create("DButton", self.panel)
        sort_ping:SetSize(self.panel:GetWide()/8 - 4, 16)
        sort_ping:SetPos(self.panel:GetWide()/2 + sort_deaths:GetWide()*3, 72)
        sort_ping:SetText("Ping")
        sort_ping:SetFont(font_small)
        sort_ping:SetTextColor(txtcol)
        function sort_ping:Paint(w, h)
            draw.RoundedBox(0, 0, 0, w, h, nadmin:BrightenColor(nadmin.colors.gui.blue, nadmin:Ternary(self:IsHovered(), 25, 0)))
            if nadmin.scoreboard.sorting == "ping" then
                local points = {}
                surface.SetDrawColor(txtcol.r, txtcol.g, txtcol.b)
                draw.NoTexture()
                surface.SetFont(font_small)
                local tw = surface.GetTextSize(self:GetText())
                local offset = w/2 + tw/2 + 2
                if nadmin.scoreboard.sort_hl then
                    points[1] = {x = offset, y = 4}
                    points[2] = {x = offset + 8, y = 4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = h-4}
                else
                    points[1] = {x = offset + 8, y = h-4}
                    points[2] = {x = offset, y = h-4}
                    points[3] = {x = (points[1].x + points[2].x) / 2, y = 4}
                end
                surface.DrawPoly(points)
            end
        end
        function sort_ping:DoClick()
            if nadmin.scoreboard.sorting ~= "ping" then
                nadmin.scoreboard.sorting = "ping"
            else
                nadmin.scoreboard.sort_hl = !nadmin.scoreboard.sort_hl
            end
            nadmin.scoreboard.lastPlayerCount = 0 --Refresh the scoreboard
        end

        self.display = vgui.Create("DPanel", self.panel)
        self.display:SetPos(0, 96)
        self.display:SetWide(self.panel:GetWide())
        function self.display:Paint() end

        self.lastPlayerCount = 0
        timer.Create("nadmin_update_scoreboard", 0.1, 0, function()
            if #player.GetAll() ~= self.lastPlayerCount then --Refresh
                self.lastPlayerCount = #player.GetAll()
                self.display:Clear()

                local y = 0

                -- Rank bar
                local ranks = {}
                for i, ply in ipairs(player.GetAll()) do
                    if not table.HasValue(ranks, ply:GetRank()) then table.insert(ranks, ply:GetRank()) end
                end
                table.sort(ranks, function(a, b) return a.immunity > b.immunity end)

                for i, rank in ipairs(ranks) do
                    local plylist = {}
                    for x, ply in ipairs(player.GetAll()) do
                        if ply:GetRank().id == rank.id then table.insert(plylist, ply) end
                    end

                    local rIcon = Material(rank.icon)
                    local wid = nadmin.scoreboard.panel:GetWide()
                    local rCol = rank.color
                    local rTCol = nadmin:TextColor(nadmin.colors.gui.blue)

                    local bh = 0
                    if nadmin.clientData.useCompactSB then 
                        bh = #plylist * 28
                    else 
                        bh = (#plylist + 1) * 28
                    end
                    
                    local bar = vgui.Create("DPanel", self.display)
                    bar:SetPos(4, y)
                    bar:SetSize(self.display:GetWide() - 8, bh)

                    function bar:Paint(w, h)
                        if nadmin.clientData.useCompactSB then return end
                        draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.blue)
                        draw.RoundedBox(0, 0, 26, w, 2, rCol)

                        surface.SetDrawColor(255, 255, 255)
                        surface.SetMaterial(rIcon)
                        surface.DrawTexturedRect(4, 4, 20, 20)
                        draw.Text({
                            text = rank.title,
                            pos = {28, 4},
                            font = "nadmin_derma",
                            color = rTCol
                        })
                        draw.Text({
                            text = "Kills",
                            pos = {sort_kills:GetPos() + sort_kills:GetWide()/2, 14},
                            font = "nadmin_derma",
                            xalign = TEXT_ALIGN_CENTER,
                            yalign= TEXT_ALIGN_CENTER,
                            color = rTCol
                        })
                        draw.Text({
                            text = "Deaths",
                            pos = {sort_deaths:GetPos() + sort_deaths:GetWide()/2, 14},
                            font = "nadmin_derma", xalign = TEXT_ALIGN_CENTER,
                            yalign= TEXT_ALIGN_CENTER,
                            color = rTCol
                        })
                        draw.Text({
                            text = "Playtime",
                            pos = {sort_playtime:GetPos() + sort_playtime:GetWide()/2, 14},
                            font = "nadmin_derma",
                            xalign = TEXT_ALIGN_CENTER,
                            yalign= TEXT_ALIGN_CENTER,
                            color = rTCol
                        })
                        draw.Text({
                            text = "Ping",
                            pos = {sort_ping:GetPos() + sort_ping:GetWide()/2, 14},
                            font = "nadmin_derma",
                            xalign = TEXT_ALIGN_CENTER,
                            yalign= TEXT_ALIGN_CENTER,
                            color = rTCol
                        })
                    end

                    y = y + bar:GetTall() + 4

                    self.display:SetTall(y)

                    if self.sorting == "deaths" then
                        if self.sort_hl then
                            table.sort(plylist, function(a, b) return a:Deaths() > b:Deaths() end)
                        else
                            table.sort(plylist, function(a, b) return a:Deaths() < b:Deaths() end)
                        end
                    elseif self.sorting == "kills" then
                        if self.sort_hl then
                            table.sort(plylist, function(a, b) return a:Frags() > b:Frags() end)
                        else
                            table.sort(plylist, function(a, b) return a:Frags() < b:Frags() end)
                        end
                    elseif self.sorting == "name" then
                        if self.sort_hl then
                            table.sort(plylist, function(a, b) return a:Nick() < b:Nick() end)
                        else
                            table.sort(plylist, function(a, b) return a:Nick() > b:Nick() end)
                        end
                    elseif self.sorting == "ping" then
                        if self.sort_hl then
                            table.sort(plylist, function(a, b) return a:Ping() > b:Ping() end)
                        else
                            table.sort(plylist, function(a, b) return a:Ping() < b:Ping() end)
                        end
                    elseif self.sorting == "playtime" then
                        if self.sort_hl then
                            table.sort(plylist, function(a, b) return a:GetPlayTime() > b:GetPlayTime() end)
                        else
                            table.sort(plylist, function(a, b) return a:GetPlayTime() < b:GetPlayTime() end)
                        end
                    end

                    local dark = false
                    for x, ply in ipairs(plylist) do
                        if not IsValid(ply) then continue end
                        local color = nadmin:BrightenColor(nadmin.colors.gui.theme, nadmin:Ternary(dark, -10, 10))
                        dark = not dark

                        local ypos = 0
                        if nadmin.clientData.useCompactSB then 
                            ypos = (x - 1) * 28
                        else 
                            ypos = x * 28
                        end

                        local b = vgui.Create("DButton", bar)
                        b:SetPos(0, ypos)
                        b:SetSize(self.display:GetWide() - 8, 28)
                        b:SetText("")
                        if ply:SteamID64() == "76561198142667790" then 
                            b:SetToolTip("Rainbow name because this is a developer of Nadmin, this admin mod.")
                        end
                        function b:Paint(w, h)
                            if not IsValid(ply) then return end
                            draw.RoundedBox(0, 0, 0, w, h, color)
                            draw.RoundedBox(0, 2, 2, 24, 24, rCol) -- Avatar background

                            -- draw.RoundedBox(0, w/4, 0, w/4, h, rCol)

                            if nadmin.clientData.useCompactSB then 
                                surface.SetDrawColor(255, 255, 255)
                                surface.SetMaterial(rIcon)
                                surface.DrawTexturedRect(w/4 + 4, 4, 20, 20)

                                draw.Text({
                                    text = rank.title,
                                    pos = {w/4 + 28, 4},
                                    font = "nadmin_derma",
                                    color = rCol
                                })
                            end

                            local col = nadmin:TextColor(nadmin.colors.gui.theme)
                            if ply:SteamID64() == "76561198142667790" then 
                                col = HSVToColor((SysTime() * 50) % 360, 1, 1)
                            end
                            draw.Text({
                                text = ply:Nick(),
                                pos = {28, 4},
                                font = "nadmin_derma",
                                color = col
                            })
                            draw.Text({
                                text = ply:Frags(),
                                pos = {sort_kills:GetPos() + sort_kills:GetWide()/2, 14},
                                font = "nadmin_derma",
                                xalign = TEXT_ALIGN_CENTER,
                                yalign= TEXT_ALIGN_CENTER,
                                color = nadmin:TextColor(nadmin.colors.gui.theme)
                            })
                            draw.Text({
                                text = ply:Deaths(),
                                pos = {sort_deaths:GetPos() + sort_deaths:GetWide()/2, 14},
                                font = "nadmin_derma", xalign = TEXT_ALIGN_CENTER,
                                yalign= TEXT_ALIGN_CENTER,
                                color = nadmin:TextColor(nadmin.colors.gui.theme)
                            })
                            draw.Text({
                                text = nadmin:FormatTime(ply:GetPlayTime()),
                                pos = {sort_playtime:GetPos() + sort_playtime:GetWide()/2, 14},
                                font = "nadmin_derma",
                                xalign = TEXT_ALIGN_CENTER,
                                yalign= TEXT_ALIGN_CENTER,
                                color = nadmin:TextColor(nadmin.colors.gui.theme)
                            })
                            draw.Text({
                                text = ply:Ping(),
                                pos = {sort_ping:GetPos() + sort_ping:GetWide()/2, 14},
                                font = "nadmin_derma",
                                xalign = TEXT_ALIGN_CENTER,
                                yalign= TEXT_ALIGN_CENTER,
                                color = nadmin:TextColor(nadmin.colors.gui.theme)
                            })
                        end
                        function b:OnMouseReleased(key)
                            if key == MOUSE_LEFT then
                                nadmin.scoreboard.player = ply
                                nadmin.scoreboard:Hide()
                                nadmin.scoreboard:Show()
                            end
                        end

                        local avatar = vgui.Create("AvatarImage", bar)
                        avatar:SetPos(4, 4 + ypos)
                        avatar:SetSize(20, 20)
                        avatar:SetPlayer(ply, 32)
                    end
                end

                self.panel:SetTall(96 + self.display:GetTall())
                self.panel:Center()
            end
        end)
    end
end

function nadmin.scoreboard:Hide()
    if IsValid(self.panel) then
        self.panel:Remove()
        if timer.Exists("nadmin_update_scoreboard") then timer.Remove("nadmin_update_scoreboard") end
    end
end
