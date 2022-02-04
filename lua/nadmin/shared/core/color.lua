function nadmin:DarkenColor(col, am)
    if not IsColor(col) then error("Can't darken a non-color - " .. tostring(col)) end
    local r = col.r or 255
    local g = col.g or 255
    local b = col.b or 255
    local a = col.a or 255
    local n = tonumber(am) or 25
    return setmetatable({r = math.Clamp(r - n, 0, 255), g = math.Clamp(g - n, 0, 255), b = math.Clamp(b - n, 0, 255), a = math.Clamp(a, 0, 255)}, debug.getregistry().Color)
end
function nadmin:BrightenColor(col, am)
    if not IsColor(col) then error("Can't brighten a non-color - " .. tostring(col)) end
    local r = col.r or 255
    local g = col.g or 255
    local b = col.b or 255
    local a = col.a or 255
    local n = tonumber(am) or 25
    return setmetatable({r = math.Clamp(r + n, 0, 255), g = math.Clamp(g + n, 0, 255), b = math.Clamp(b + n, 0, 255), a = math.Clamp(a, 0, 255)}, debug.getregistry().Color)
end
function nadmin:AlphaColor(col, am)
    if not IsColor(col) then error("Can't alpha a non-color - " .. tostring(col)) end
    local r = col.r or 255
    local g = col.g or 255
    local b = col.b or 255
    local a = tonumber(am) or 0
    return setmetatable({r = r, g = g, b = b, a = math.Clamp(a, 0, 255)}, debug.getregistry().Color)
end
function nadmin:InvertColor(col)
    if not IsColor(col) then error("Can't invert a non-color - " .. tostring(col)) end
    local r = col.r or 255
    local g = col.g or 255
    local b = col.b or 255
    local a = col.a or 255
    return setmetatable({r = 255 - r, g = 255 - g, b = 255 - b, a = a}, debug.getregistry().Color)
end

function nadmin:TextColor(col)
    if not IsColor(col) then error("Can't get the text color a non-color - " .. tostring(col)) end
    local r = col.r or 255
    local g = col.g or 255
    local b = col.b or 255
    local a = col.a or 255
    if (0.2126*r + 0.7152*g + 0.0722*b) > 127 then
        return Color(0, 0, 0, a)
    else
        return Color(255, 255, 255, a)
    end
end

function nadmin:ColorToHex(color)
    if not IsColor(color) then error("nadmin:ColorToHex - Color expected, got " .. type(color)) end
    return string.format("#%02X%02X%02X%02X", color.r, color.g, color.b, color.a)
end
function nadmin:HexToColor(hex)
    if not isstring(hex) then error("nadmin:HexToColor - String expected, got " .. type(hex)) end
    local len = #hex
    if len > 0 and string.sub(hex, 1, 1) == "#" then
        hex = string.sub(hex, 2)
        len = len - 1
    end
    if len >= 6 then
        local r = "0x" .. string.sub(hex, 1, 2)
        local g = "0x" .. string.sub(hex, 3, 4)
        local b = "0x" .. string.sub(hex, 5, 6)
        if len == 6 then return Color(tonumber(r), tonumber(g), tonumber(b))
        elseif len == 8 then
            local a = "0x" .. string.sub(hex, 7, 8)
            return Color(tonumber(r), tonumber(g), tonumber(b), tonumber(a))
        end
    end
end
