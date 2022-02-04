if CLIENT then 
    nadmin.hud:CreateCustom({
        title = "Simple",
        left = {
            height = 84,
            draw = function(panel, w, h)
                local font = "nadmin_hud"
                local y = 0

                surface.SetFont(font)

                -- Draw the armor
                if LocalPlayer():Armor() > 0 then
                    y = 76
                    draw.RoundedBox(0, 0, 8, w, h-8, nadmin.colors.gui.theme)

                    -- Armor background
                    draw.RoundedBox(0, 4, 12, w - 8, 32, nadmin:AlphaColor(nadmin.colors.gui.armor, 25))

                    -- Armor bar
                    local aw = (w * math.Clamp(LocalPlayer():Armor()/100, 0, 1)) - 8
                    draw.RoundedBox(0, 4, 12, aw, 32, nadmin.colors.gui.armor)

                    -- Armor Text
                    local atw = surface.GetTextSize(tostring(LocalPlayer():Armor()))
                    draw.Text({
                        text = LocalPlayer():Armor(),
                        font = font,
                        color = Color(0, 0, 0, 150),
                        yalign = TEXT_ALIGN_CENTER,
                        pos = {math.Clamp(aw - atw, 8, (w - 8) - atw), 28}
                    })

                    -- Armor Shine
                    draw.RoundedBoxEx(0, 4, 12, w - 8, 8, Color(255, 255, 255, 25), true, true, false,  false)

                    -- Armor shadow
                    draw.RoundedBoxEx(0, 4, 36, w - 8, 8, Color(0, 0, 0, 50), false, false, true, true)
                else
                    y = 40 -- Where to draw the xp
                    draw.RoundedBox(0, 0, h-40, w, 40, nadmin.colors.gui.theme)
                end

                -- Draw the HP
                -- Health background
                draw.RoundedBox(0, 4, h-36, w - 8, 32, nadmin:AlphaColor(nadmin.colors.gui.health, 50))

                -- Health bar
                local hw = (w * math.Clamp(LocalPlayer():Health()/LocalPlayer():GetMaxHealth(), 0, 1)) - 8
                draw.RoundedBox(0, 4, h-36, hw, 32, nadmin.colors.gui.health)

                -- Health text
                local htw = surface.GetTextSize(tostring(LocalPlayer():Health()))
                draw.Text({
                    text = LocalPlayer():Health(),
                    font = font,
                    color = Color(0, 0, 0, 150),
                    yalign = TEXT_ALIGN_CENTER,
                    pos = {math.Clamp(hw - htw, 8, (w - 8) - htw), h-20}
                })

                -- Health shine
                draw.RoundedBoxEx(0, 4, h-36, w - 8, 8, Color(255, 255, 255, 25), true, true, false, false)

                -- Health shadow
                draw.RoundedBoxEx(0, 4, h-12, w - 8, 8, Color(0, 0, 0, 50), false,   false, true, true)

                -- Draw the XP
                local info = LocalPlayer():GetLevel()
                if nadmin.plugins.levels and istable(info) then
                    -- Backround
                    local xPos = 4
                    local yPos = h - y - 8
                    local wid = w - 8
                    local ht = 8
                    draw.RoundedBoxEx(0, xPos, yPos, wid, ht, nadmin.colors.gui.theme, true, true, false, false)

                    -- XP Background
                    draw.RoundedBox(0, xPos + 4, yPos + 4, wid - 8, 4, nadmin:AlphaColor(nadmin.colors.gui.xp, 50))

                    -- XP Bar
                    draw.RoundedBox(0, xPos + 4, yPos + 4, (wid-8) * (info.xp/info.need), 4, nadmin.colors.gui.xp)
                end
            end
        },
        right = {
            height = 40,
            draw = function(panel, w, h)
                if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
                if not LocalPlayer():Alive() then return end

                local font = "nadmin_hud"

                surface.SetFont(font)

                surface.SetFont(font)

                local wep = LocalPlayer():GetActiveWeapon()
                local left = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

                if wep:Clip1() < 0 or wep:GetMaxClip1() < 1 then return end

                -- Main
                draw.RoundedBox(0, 0, 0, w, h, nadmin.colors.gui.theme)

                -- Background
                draw.RoundedBox(0, 4, 4, w - 8, h - 8, nadmin:AlphaColor(nadmin.colors.gui.ammo, 50))

                -- Bar
                local aw = (w * math.Clamp(wep:Clip1() / wep:GetMaxClip1(), 0, 1)) - 8
                draw.RoundedBox(0, 4, 4, aw, h-8, nadmin.colors.gui.ammo)

                -- Text
                local tw = surface.GetTextSize(tostring(wep:Clip1()) .. "/" .. wep:GetMaxClip1() .. " (" .. left .. ")")
                draw.Text({
                    text = tostring(wep:Clip1()) .. "/" .. wep:GetMaxClip1() .. " (" .. left .. ")",
                    font = font,
                    color = Color(0, 0, 0, 150),
                    yalign = TEXT_ALIGN_CENTER,
                    pos = {math.Clamp(aw - tw, 8, (w - 8) - tw), h / 2}
                })

                -- Shine
                draw.RoundedBoxEx(0, 4, 4, w - 8, (h-8)/4, Color(255, 255, 255, 25), true, true, false, false)

                -- Shadow
                draw.RoundedBoxEx(0, 4, h - 4 - ((h-8)/4), w-8, (h-8)/4, Color(0, 0, 0, 50), false, false, true, true)
            end
        }
    })

    nadmin.hud:CreateCustom({
        title = "Circular",
        left = {
            height = 128,
            draw = function(panel, w, h)
                draw.NoTexture()

                -- Usage of custom function
                -- draw.Circle(x, y, radius, seg, arc, angOffset, col)

                local hp = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1)
                local ar = math.Clamp(LocalPlayer():Armor() / 100, 0, 1)

                local r = h/2
                local res = 160
                -- Main
                draw.Circle(h/2, h/2, r, res, 360, 0, nadmin.colors.gui.theme)

                -- HP Background
                draw.Circle(h/2, h/2, r-8, res, 180, 90, nadmin:AlphaColor(nadmin.colors.gui.health, 50))

                -- HP Bar
                draw.Circle(h/2, h/2, r-8, res, 180 * hp, 90, nadmin.colors.gui.health)

                -- Armor Background
                draw.Circle(h/2, h/2, r-8, res, 180, -90, nadmin:AlphaColor(nadmin.colors.gui.armor, 50))

                -- Armor Bar
                draw.CircleInverse(h/2, h/2, r-8, res, 180 * ar, 90, nadmin.colors.gui.armor)

                -- Cover
                draw.Circle(h/2, h/2, r-20, res, 360, 0, nadmin.colors.gui.theme)

                -- XP
                if nadmin.plugins.levels then
                    local info = LocalPlayer():GetLevel()

                    local xp = math.Clamp(info.xp / info.need, 0, 1)

                    -- Background
                    draw.Circle(h/2, h/2, r-24, res, 360, 0, nadmin:AlphaColor(nadmin.colors.gui.xp, 50))

                    -- Bar
                    draw.Circle(h/2, h/2, r-24, res, 360 * xp, 180, nadmin.colors.gui.xp)

                    -- Cover
                    draw.Circle(h/2, h/2, r-28, res, 360, 0, nadmin.colors.gui.theme)
                end

                -- Draw HP and Armor values
                draw.Circle(h/2, h/2, r-32, res, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                draw.Text({
                    text = LocalPlayer():Health(),
                    pos = {h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.health
                })
                draw.Text({
                    text = LocalPlayer():Armor(),
                    pos = {h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.armor
                })
            end
        },
        right = {
            height = 128,
            draw = function(panel, w, h)
                if not LocalPlayer():Alive() then return end
                if not IsValid(LocalPlayer():GetActiveWeapon()) then return end

                local wep = LocalPlayer():GetActiveWeapon()
                local left = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())

                if wep:Clip1() < 0 or wep:GetMaxClip1() < 1 then return end

                local ammo = math.Clamp(wep:Clip1() / wep:GetMaxClip1(), 0, 1)

                local r = h/2
                local res = 60

                draw.NoTexture()

                -- Main
                draw.Circle(w - h/2, h/2, r, res, 360, 0, nadmin.colors.gui.theme)

                -- Background
                draw.Circle(w - h/2, h/2, r-8, res, 360, 0, nadmin:AlphaColor(nadmin.colors.gui.ammo, 50))

                -- Bar
                draw.CircleInverse(w - h/2, h/2, r-8, res, 360 * ammo, -90, nadmin.colors.gui.ammo)

                -- Cover
                draw.Circle(w - h/2, h/2, r-20, res, 360, 0, nadmin.colors.gui.theme)

                -- Text
                draw.Circle(w - h/2, h/2, r-24, res, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                draw.Text({
                    text = tostring(wep:Clip1()) .. "/" .. tostring(wep:GetMaxClip1()),
                    pos = {w - h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.xp
                })
                draw.Text({
                    text = "(" .. left .. ")",
                    pos = {w - h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.xp
                })
            end
        }
    })

    nadmin.hud:CreateCustom({
        title = "Circular Simple",
        left = {
            height = 128,
            draw = function(panel, w, h)
                draw.NoTexture()

                local r = h/2
                local res = 60

                local hp = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1)
                local ar = math.Clamp(LocalPlayer():Armor() / 100, 0, 1)

                -- Main background
                draw.RoundedBox(0, 0, 0, h/2, h/2, nadmin.colors.gui.theme)
                draw.RoundedBox(0, h/2, h/2, h/2, h/2, nadmin.colors.gui.theme)
                draw.Circle(h/2, h/2, r, res, 360, 0, nadmin.colors.gui.theme)

                -- HP background
                draw.Circle(h/2, h/2, r-8, res, 270, 90, nadmin:AlphaColor(nadmin.colors.gui.health, 50))

                -- HP bar
                draw.Circle(h/2, h/2, r-8, res, 270 * hp, 90, nadmin.colors.gui.health)

                -- Armor Background
                draw.Circle(h/2, h/2, r-20, res, 270, 90, nadmin.colors.gui.theme)
                draw.Circle(h/2, h/2, r-20, res, 270, 90, nadmin:AlphaColor(nadmin.colors.gui.armor, 50))

                -- Armor bar
                draw.Circle(h/2, h/2, r-20, res, 270 * ar, 90, nadmin.colors.gui.armor)

                draw.Circle(h/2, h/2, r-32, res, 270, 90, nadmin.colors.gui.theme)

                -- XP
                if nadmin.plugins.levels then
                    local info = LocalPlayer():GetLevel()
                    local xp = math.Clamp(info.xp / info.need, 0, 1)

                    draw.Circle(h/2, h/2, r-32, res, 270, 90, nadmin:AlphaColor(nadmin.colors.gui.xp, 50))
                    draw.Circle(h/2, h/2, r-32, res, 270 * xp, 90, nadmin.colors.gui.xp)
                    draw.Circle(h/2, h/2, r-38, res, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                else
                    draw.Circle(h/2, h/2, r-32, res, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                end

                -- Text
                draw.Text({
                    text = LocalPlayer():Health(),
                    pos = {h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.health
                })
                draw.Text({
                    text = LocalPlayer():Armor(),
                    pos = {h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.armor
                })
            end
        },
        right = {
            height = 128,
            draw = function(panel, w, h)
                if not IsValid(LocalPlayer():GetActiveWeapon()) then return end
                draw.NoTexture()

                local wep = LocalPlayer():GetActiveWeapon()
                local left = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
                if wep:Clip1() < 0 or wep:GetMaxClip1() < 1 then return end
                local ammo = math.Clamp(wep:Clip1() / wep:GetMaxClip1(), 0, 1)

                local r = h/2
                local res = 60

                -- Main
                draw.RoundedBox(0, w-h, h/2, h/2, h/2, nadmin.colors.gui.theme)
                draw.RoundedBox(0, w-h/2, 0, h/2, h/2, nadmin.colors.gui.theme)
                draw.Circle(w-h/2, h/2, r, res, 360, 0, nadmin.colors.gui.theme)

                -- Bar
                draw.CircleInverse(w-h/2, h/2, r-8, res, 270, -90, nadmin:AlphaColor(nadmin.colors.gui.ammo, 50))
                draw.CircleInverse(w-h/2, h/2, r-8, res, 270 * ammo, -90, nadmin.colors.gui.ammo)

                -- Cover
                draw.Circle(w-h/2, h/2, r-20, res, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                draw.Text({
                    text = tostring(wep:Clip1()) .. "/" .. tostring(wep:GetMaxClip1()),
                    pos = {w - h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.xp
                })
                draw.Text({
                    text = "(" .. left .. ")",
                    pos = {w - h/2, h/2},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_TOP,
                    font = "nadmin_hud_small",
                    color = nadmin.colors.gui.xp
                })
            end
        }
    })

    nadmin.hud:CreateCustom({
        title = "Fluid",
        left = {
            height = 128,
            draw = function(panel, w, h)
                local wid = h * 0.8
                draw.RoundedBox(0, 0, 0, wid, h, nadmin.colors.gui.theme)

                draw.RoundedBox(0, 4, 4, wid - 8, h-8, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
                local hp = math.Clamp(LocalPlayer():Health()/LocalPlayer():GetMaxHealth(), 0, 1)
                local ar = math.Clamp(LocalPlayer():Armor()/100, 0, 1)

                local y = (h-4) - ((h-4) * hp)
                draw.Fluid({
                    pos = {4, y},
                    size = {wid-8, (h-4) - y},
                    color = nadmin.colors.gui.health
                })
                draw.RoundedBox(0, 0, 0, wid, 4, nadmin.colors.gui.theme)

                draw.Text({
                    text = LocalPlayer():Health(),
                    font = "nadmin_hud",
                    pos = {(wid/2) - 1, h-8},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    color = Color(0, 0, 0, 150)
                })

                for i = 1, 9 do
                    local y = ((h - 8) / 10) * i
                    draw.RoundedBox(0, 4, 2 + y, nadmin:Ternary(i == 5, 16, 8), 4, Color(0, 0, 0, 150))
                end

                local x = wid
                if LocalPlayer():Armor() > 0 then
                    x = x + wid - 4
                    draw.RoundedBox(0, wid-4, 0, wid, h, nadmin.colors.gui.theme)
                    draw.RoundedBox(0, wid, 4, wid-8, h-8, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                    local y = (h-4) - ((h-4) * ar)
                    draw.Fluid({
                        pos = {wid, y},
                        size = {wid-9, (h-4) - y},
                        color = nadmin.colors.gui.armor
                    })
                    draw.RoundedBox(0, wid-4, 0, wid, 4, nadmin.colors.gui.theme)

                    draw.Text({
                        text = LocalPlayer():Armor(),
                        font = "nadmin_hud",
                        pos = {(wid*1.5) - 5, h-8},
                        xalign = TEXT_ALIGN_CENTER,
                        yalign = TEXT_ALIGN_BOTTOM,
                        color = Color(0, 0, 0, 150)
                    })

                    for i = 1, 9 do
                        local y = ((h - 8) / 10) * i
                        draw.RoundedBox(0, wid, 2 + y, nadmin:Ternary(i == 5, 16, 8), 4, Color(0, 0, 0, 150))
                    end
                end

                if nadmin.plugins.levels then
                    local info = LocalPlayer():GetLevel()
                    local xp = math.Clamp(info.xp/info.need, 0, 1)
                    draw.RoundedBox(0, x, 0, 8, h, nadmin.colors.gui.theme)
                    draw.RoundedBox(0, x, 4, 4, h - 8, nadmin:AlphaColor(nadmin.colors.gui.xp, 50))
                    local y = (h-4) - ((h-8)*xp)
                    draw.RoundedBox(0, x, y, 4, h - 4 - y, nadmin.colors.gui.xp)
                end
            end
        },
        right = {
            height = 128,
            draw = function(panel, w, h)
                if not IsValid(LocalPlayer():GetActiveWeapon()) then return end

                local wep = LocalPlayer():GetActiveWeapon()
                local left = LocalPlayer():GetAmmoCount(wep:GetPrimaryAmmoType())
                if wep:Clip1() < 0 or wep:GetMaxClip1() < 1 then return end
                local ammo = math.Clamp(wep:Clip1() / wep:GetMaxClip1(), 0, 1)

                local wid = h * 0.8
                draw.RoundedBox(0, w - wid, 0, wid, h, nadmin.colors.gui.theme)
                draw.RoundedBox(0, w - wid + 4, 4, wid - 8, h - 8, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

                local y = (h-4) - ((h-4) * ammo)
                draw.Fluid({
                    pos = {w - wid + 3, y},
                    size = {wid-8, (h-4) - y},
                    color = nadmin.colors.gui.ammo
                })
                draw.RoundedBox(0, w - wid, 0, wid, 4, nadmin.colors.gui.theme)

                for i = 1, 9 do
                    local y = ((h - 8) / 10) * i
                    draw.RoundedBox(0, w - wid + 4, 2 + y, nadmin:Ternary(i == 5, 16, 8), 4, Color(0, 0, 0, 150))
                end

                surface.SetFont("nadmin_hud_small")
                local current = tostring(wep:Clip1()) .. "/" .. tostring(wep:GetMaxClip1())
                local width, height = surface.GetTextSize(current)

                draw.Text({
                    text = current,
                    font = "nadmin_hud_small",
                    pos = {w - wid/2, (h - 7) - height},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    color = Color(0, 0, 0, 150)
                })
                draw.Text({
                    text = "(" .. tostring(left) .. ")",
                    font = "nadmin_hud_small",
                    pos = {w - wid/2, h - 7},
                    xalign = TEXT_ALIGN_CENTER,
                    yalign = TEXT_ALIGN_BOTTOM,
                    color = Color(0, 0, 0, 150)
                })
            end
        }
    })

    -- Following HUD never finished, didn't look that great
    nadmin.hud:CreateCustom({
        title = "Skewed (Incomplete)",
        left = {
            height = 84,
            draw = function(panel, w, h)
                if LocalPlayer():Health() <= 0 then return end

                draw.NoTexture()
                
                -- Health bar
                local maxWidH = w - 14
                local maxWidHT = w * (7/8)
                
                local th = nadmin.colors.gui.theme
                surface.SetDrawColor(th.r, th.g, th.b)
                surface.DrawPoly({
                    {x = 0,        y = h-32},
                    {x = maxWidHT, y = h-32},
                    {x = w,        y = h},
                    {x = 0,        y = h} 
                })

                local hp = nadmin.colors.gui.health
                surface.SetDrawColor(hp.r, hp.g, hp.b, 25)
                surface.DrawPoly({
                    {x = 4,        y = h-28},
                    {x = maxWidHT, y = h-28},
                    {x = maxWidH,  y = h-4},
                    {x = 4,        y = h-4}
                })

                local health = math.Clamp(LocalPlayer():Health() / LocalPlayer():GetMaxHealth(), 0, 1) * maxWidH
                surface.SetDrawColor(hp.r, hp.g, hp.b)
                surface.DrawPoly({
                    {x = 4,                                                      y = h-28},
                    {x = math.Clamp(health - (maxWidH - maxWidHT), 4, maxWidHT), y = h-28},
                    {x = math.Clamp(health, 4, maxWidH),                         y = h-4},
                    {x = 4,                                                      y = h-4}
                })

                -- Armor bar
                if LocalPlayer():Armor() > 0 then 
                    local maxWidA  = maxWidHT
                    local maxWidAT = w

                    surface.SetDrawColor(th.r, th.g, th.b)
                    surface.DrawPoly({
                        {x = 0,        y = h-64},
                        {x = maxWidAT, y = h-64},
                        {x = maxWidA,  y = h-32},
                        {x = 0,        y = h-32}
                    })
                    
                    local ar = nadmin.colors.gui.armor 
                    surface.SetDrawColor(ar.r, ar.g, ar.b, 25)
                    surface.DrawPoly({
                        {x = 4,            y = h-60},
                        {x = maxWidAT - 14, y = h-60},
                        {x = maxWidA - 4,  y = h-36},
                        {x = 4,            y = h-36}
                    })

                    local armor = math.Clamp(LocalPlayer():Armor() / 100, 0, 1) * maxWidAT - 14
                    surface.SetDrawColor(ar.r, ar.g, ar.b)
                    surface.DrawPoly({
                        {x = 4,                                                         y = h-60},
                        {x = math.Clamp(armor - (maxWidA - maxWidAT), 4, maxWidAT), y = h-60},
                        {x = math.Clamp(armor, 4, maxWidA - 4),                         y = h-36},
                        {x = 4,                                                         y = h-36}
                    })

                    if nadmin.plugins.levels then 
                        draw.RoundedBox(0, 4, h - 34, maxWidHT - 8, 4, nadmin:AlphaColor(nadmin.colors.gui.xp, 25))
                    end
                else

                end

                -- surface.SetDrawColor(nadmin.colors.gui.theme.r, nadmin.colors.gui.theme.g, nadmin.colors.gui.theme.b)
                -- draw.NoTexture()
                -- surface.DrawPoly({
                --     {x = 16,  y = 0},
                --     {x = w,   y = 0},
                --     {x = w-h, y = h},
                --     {x = 16,  y = h}
                -- })
    
                -- local hp = nadmin.colors.gui.health
                -- surface.SetDrawColor(hp.r, hp.g, hp.b, 25)
    
                -- local hpPoly = {
                --     {x = 40, y = 4},
                --     {x = w-8, y = 4},
                --     {x = w-40, y = 36},
                --     {x = 40, y = 36}
                -- }
                -- surface.DrawPoly(hpPoly)
    
                -- surface.SetDrawColor(hp.r, hp.g, hp.b)
                -- local health = math.Clamp(LocalPlayer():Health()/LocalPlayer():GetMaxHealth(), 0, 1)
                -- hpPoly[2].x = (w-8) * health
                -- hpPoly[3].x = (w-8) * health - 32
                -- surface.DrawPoly(hpPoly)
    
                -- local ar = nadmin.colors.gui.armor
                -- surface.SetDrawColor(ar.r, ar.g, ar.b, 25)
    
                -- local arPoly = {
                --     {x = 40, y = 44},
                --     {x = w-50, y = 44},
                --     {x = w-h-2, y = h-4},
                --     {x = 40, y = h-4}
                -- }
                -- surface.DrawPoly(arPoly)
    
                -- draw.RoundedBox(0, 0, 0, 32, h, nadmin.colors.gui.theme)
            end
        },
        right = {
            height = 40,
            draw = function(self, w, h)
    
            end
        }
    })
end