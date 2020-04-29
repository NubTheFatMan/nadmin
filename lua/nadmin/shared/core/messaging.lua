hook.Add("Initialize", "nadmin_register_silent_notify", function()
    nadmin:RegisterPerm({
        title = "See Silent Commands"
    })
end)

-- Parse a string as a commandline input
function nadmin:ParseArgs(str, normal)
    local out = {} -- This is the simple table

    local advOut = {__unindexed = {}} -- This is the commandline parsed output

    local quote = false -- Supports wrapping a string in quotes to preserve spaces; gets counted as a single argument
    local s = "" -- The current string to be added to out

    str = string.Explode("", str)
    for i, c in ipairs(str) do
        local t = string.Trim(s)
        if c == " " and not quote and #t > 0 then
            table.insert(out, t)
            s = ""
        elseif c == '"' and str[i - 1] ~= "\\" then
            quote = not quote
        else
            if c == "\\" and str[i + 1] == '"' then continue end
            s = s .. c
        end
    end

    local t = string.Trim(s)
    if #t > 0 then
        table.insert(out, t)
    end

    if not normal then
        local cmd = "__unindexed"
        for i, o in ipairs(out) do
            if string.StartWith(o, "-") then
                local newCmd = string.Trim(string.sub(o, 2))
                if #newCmd > 0 then
                    cmd = newCmd
                    continue
                end
            end
            if string.sub(o, 1, 2) == "\\-" then
                out[i] = string.sub(o, 2)
            end
            if not advOut[cmd] then advOut[cmd] = {} end
            table.insert(advOut[cmd], out[i])
        end
    end

    if normal then return out end
    return advOut, out
end
