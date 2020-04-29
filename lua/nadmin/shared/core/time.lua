function nadmin:FormatTime(t)
    if not isnumber(t) then return "nan" end
    if t < 0 then
        return "Forever"
    elseif t < nadmin.time.m then
        return t .. " second" .. nadmin:Ternary(t > 1, "s", "")
    elseif t < nadmin.time.h then
        local ti = math.floor(t/nadmin.time.m)
        return ti .. " minute" .. nadmin:Ternary(ti > 1, "s", "")
    elseif t < nadmin.time.d then
        local ti = math.floor(t/nadmin.time.h)
        return ti .. " hour" .. nadmin:Ternary(ti > 1, "s", "")
    elseif t < nadmin.time.w then
        local ti = math.floor(t/nadmin.time.d)
        return ti .. " day" .. nadmin:Ternary(ti > 1, "s", "")
    elseif t < nadmin.time.mo then
        local ti = math.floor(t/nadmin.time.w)
        return ti .. " week" .. nadmin:Ternary(ti > 1, "s", "")
    else
        local ti = math.floor(t/nadmin.time.mo)
        return ti .. " month" .. nadmin:Ternary(ti > 1, "s", "")
    end
end

function nadmin:TimeToString(time, long)
    local t = math.abs(time)
    local s =  math.floor((t % (60 * nadmin.time.s))  / nadmin.time.s)
    local m =  math.floor((t % (60 * nadmin.time.m))  / nadmin.time.m)
    local h =  math.floor((t % (24 * nadmin.time.h))  / nadmin.time.h)
    local d =  math.floor((t % (7  * nadmin.time.d))  / nadmin.time.d)
    local w =  math.floor((t % (30 * nadmin.time.d))  / nadmin.time.w)
    local mo = math.floor((t % (12 * nadmin.time.mo)) / nadmin.time.mo)
    local y =  math.floor(t / nadmin.time.y)

    local str = ""
    if long then
        if y > 0 then str = str .. y .. " year" .. nadmin:Ternary(y > 1, "s ", " ") end
        if mo > 0 then str = str .. mo .. " month" .. nadmin:Ternary(mo > 1, "s ", " ") end
        if w > 0 then str = str .. w .. " week" .. nadmin:Ternary(w > 1, "s ", " ") end
        if d > 0 then str = str .. d .. " day" .. nadmin:Ternary(d > 1, "s ", " ") end
        if h > 0 then str = str .. h .. " hour" .. nadmin:Ternary(h > 1, "s ", " ") end
        if m > 0 then str = str .. m .. " minute" .. nadmin:Ternary(m > 1, "s ", " ") end
        if s > 0 then str = str .. s .. " second" .. nadmin:Ternary(s > 1, "s ", " ") end
    else
        if y > 0 then str = str .. y .. "y" end
        if mo > 0 then str = str .. mo .. "mo" end
        if w > 0 then str = str .. w .. "w" end
        if d > 0 then str = str .. d .. "d" end
        if h > 0 then str = str .. h .. "h" end
        if m > 0 then str = str .. m .. "m" end
        if s > 0 then str = str .. s .. "s" end
    end
    return string.Trim(str)
end

function nadmin:ParseTime(str)
    if not isstring(str) then return end

    local val = 0

    if string.find(string.lower(str), "forever") then return math.huge end

    local changed = false

    for s in string.gmatch(string.lower(str), "%d+[(s)(m)(h)(d)(w)(y)]*[(mo)]*") do
        local st = string.Trim(s)
        if string.EndsWith(st, "s") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.s)
            end
        elseif string.EndsWith(st, "m") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.m)
            end
        elseif string.EndsWith(st, "h") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.h)
            end
        elseif string.EndsWith(st, "d") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.d)
            end
        elseif string.EndsWith(st, "w") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.w)
            end
        elseif string.EndsWith(st, "mo") then
            local time = tonumber(string.sub(st, 1, #st - 2))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.mo)
            end
        elseif string.EndsWith(st, "y") then
            local time = tonumber(string.sub(st, 1, #st - 1))
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.y)
            end
        else
            local time = tonumber(st)
            if isnumber(time) then
                changed = true
                val = val + (time * nadmin.time.s)
            end
        end
    end

    if changed then return val end
end
