-- Function copied from gmod wiki `surface.DrawPoly` and then modified to support wedges
function draw.Circle(x, y, radius, seg, arc, angOffset, col)
    local cir = {}

    draw.NoTexture()
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360) * (arc/360) - math.rad(angOffset)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
    end
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

    surface.SetDrawColor(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
    surface.DrawPoly(cir)
end

-- Draws a circle flipped horizontally (for the arc)
function draw.CircleInverse(x, y, radius, seg, arc, angOffset, col)
    local cir = {}

    draw.NoTexture()
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})
    for i = 0, seg do
        local a = math.rad((i / seg) * -360) * (arc/360) - math.rad(angOffset - arc)
        table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})
    end
    table.insert(cir, {x = x, y = y, u = 0.5, v = 0.5})

    local a = math.rad(0) -- This is needed for non absolute segment counts
    table.insert(cir, {x = x + math.sin(a) * radius, y = y + math.cos(a) * radius, u = math.sin(a) / 2 + 0.5, v = math.cos(a) / 2 + 0.5})

    surface.SetDrawColor(col.r or 255, col.g or 255, col.b or 255, col.a or 255)
    surface.DrawPoly(cir)
end

function draw.Fluid(tbl)
    if not istable(tbl) then error("draw.Fluid: Bad argument #1: Must be a table, got " .. type(tbl)) end

    if not istable(tbl.pos) then error("draw.Fluid: Bad argument \"pos\": Must be a table, got " .. type(tbl.pos)) end
    if not isnumber(tbl.pos[1]) then error("draw.Fluid: Bad argument #1 in \"pos\": Must be a number, got " .. type(tbl.pos[1])) end
    if not isnumber(tbl.pos[2]) then error("draw.Fluid: Bad argument #2 in \"pos\": Must be a number, got " .. type(tbl.pos[2])) end

    if not istable(tbl.size) then error("draw.Fluid: Bad argument \"size\": Must be a table, got " .. type(tbl.size)) end
    if not isnumber(tbl.size[1]) then error("draw.Fluid: Bad argument #1 in \"size\": Must be a number, got " .. type(tbl.size[1])) end
    if not isnumber(tbl.size[2]) then error("draw.Fluid: Bad argument #2 in \"size\": Must be a number, got " .. type(tbl.size[2])) end

    local fl = {
        pos = {
            x = tbl.pos[1],
            y = tbl.pos[2]
        },
        size = {
            w = tbl.size[1],
            h = tbl.size[2] + tbl.pos[2]
        },
        change =    nadmin:Ternary(isnumber(tbl.change),    tbl.change,    4),
        frequency = nadmin:Ternary(isnumber(tbl.frequency), tbl.frequency, 3),
        speed =     nadmin:Ternary(isnumber(tbl.speed),     tbl.speed,     0.05),
        res =       nadmin:Ternary(isnumber(tbl.res),       tbl.res,       50),
        color =     nadmin:Ternary(IsColor(tbl.color),      tbl.color,     Color(255, 255, 255))
    }

    draw.NoTexture()
    surface.SetDrawColor(fl.color.r, fl.color.g, fl.color.b, fl.color.a)

    for i = 0, fl.res - 1 do
        local xPos = fl.pos.x + (fl.size.w/fl.res) * i
        local nextPos = fl.pos.x + (fl.size.w/fl.res) * (i + 1)
        local poly = {
            {x = xPos, y = (fl.pos.y + fl.change/2) + fl.change/2 * math.sin(fl.frequency * CurTime() + fl.speed * xPos)},
            {x = nextPos, y = (fl.pos.y + fl.change/2) + fl.change/2 * math.sin(fl.frequency * CurTime() + fl.speed * nextPos)},
            {x = nextPos, y = fl.size.h},
            {x = xPos, y = fl.size.h}
        }
        surface.DrawPoly(poly)
    end
end

local blur = Material("pp/blurscreen")
function draw.Blur(x, y, w, h, strength)
    if not isnumber(x) or not isnumber(y) then return end
    if not isnumber(w) or not isnumber(h) then return end

    surface.SetDrawColor(0, 0, 0)
    surface.SetMaterial(blur)

    for i = 1, 5 do
        blur:SetFloat("$blur", (i / 5) * nadmin:Ternary(isnumber(strength), strength, 5))
        blur:Recompute()

        render.UpdateScreenEffectTexture()

        render.SetScissorRect(x, y, x + w, y + h, true)
        surface.DrawTexturedRect(0, 0, ScrW(), ScrH())
        render.SetScissorRect(0, 0, 0, 0, false)
    end
end
