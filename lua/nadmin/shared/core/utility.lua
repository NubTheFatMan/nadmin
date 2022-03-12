function nadmin:Ternary(cond, tret, fret)
    if cond then return tret end
    return fret
end

function nadmin:BoolToInt(bool)
    if isbool(bool) and bool then return 1 end
    return 0
end
function nadmin:IntToBool(int)
    if tonumber(int) > 0 then return true end
    return false
end

function table.length(tbl)
    local count = 0
    for _ in ipairs(tbl) do count = count + 1 end
    return count
end

function nadmin:GetNameColor(obj)
    if isentity(obj) and obj:IsPlayer() then
        return obj:GetRank().color
    elseif isstring(obj) and SERVER then
        local data = nadmin.userdata[obj]
        if istable(data) then
            local rank = nadmin:FindRank(data.rank)
            if istable(rank) and data.lastJoined.name ~= "" then
                return rank.color
            end
        end
    end
end

-- Smooth(er)Step functions made from a wikipedia article
-- https://en.wikipedia.org/wiki/Smoothstep
function nadmin:SmoothStep(p1, p2, x)
    if not isnumber(p1) then error("nadmin:SmoothStep: Bad argument #1: Must be a number, got " .. type(p1)) end
    if not isnumber(p2) then error("nadmin:SmoothStep: Bad argument #2: Must be a number, got " .. type(p1)) end
    if not isnumber(x) then error("nadmin:SmoothStep: Bad argument #3: Must be a number, got " .. type(p1)) end

    x = math.Clamp((x - p1) / (p2 - p1), 0, 1)
    return x * x * (3 - 2*x)
end
function nadmin:SmootherStep(p1, p2, x)
    if not isnumber(p1) then error("nadmin:SmootherStep: Bad argument #1: Must be a number, got " .. type(p1)) end
    if not isnumber(p2) then error("nadmin:SmootherStep: Bad argument #2: Must be a number, got " .. type(p1)) end
    if not isnumber(x) then error("nadmin:SmootherStep: Bad argument #3: Must be a number, got " .. type(p1)) end

    x = math.Clamp((x - p1) / (p2 - p1), 0, 1)
    return x * x * x * (x * (x * 6 - 15) + 10)
end

function nadmin:Lerp(s, e, p)
    if not isnumber(s) then error("nadmin:SmootherStep: Bad argument #1: Must be a number, got " .. type(s)) end
    if not isnumber(e) then error("nadmin:SmootherStep: Bad argument #2: Must be a number, got " .. type(e)) end
    if not isnumber(p) then error("nadmin:SmootherStep: Bad argument #3: Must be a number, got " .. type(p)) end

    p = math.Clamp(p, 0, 1)

    return s * (1 - p) + e * p
end

-- Easing in and out animations
-- Want to see a demo of this function in action? Check my website
-- https://nubstoys.xyz/gfd/animation_graph_visualizer/
function nadmin:EaseInOut(value, exp)
    if not isnumber(value) then error("nadmin:EaseInOut: Bad argument #1: Expected a number, got " .. type(value)) end
    if not isnumber(exp)   then error("nadmin:EaseInOut: Bad argument #2: Expected a number, got " .. type(exp)) end
    if value < 0.5 then 
        return (2 ^ (exp - 1)) * (value ^ exp)
    else 
        return 1 - ((-2 * value + 2) ^ exp) / 2
    end
end
