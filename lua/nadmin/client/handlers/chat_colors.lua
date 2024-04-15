-- The purpose of this file is to replace chat colors to incorperate ranks.
hook.Add("OnPlayerChat", "nadmin_chat_replacement", function(ply, msg, isTeam, isDead)
    if #string.Trim(msg) > 0 then
        local tbl = {}

        if isDead then
            table.insert(tbl, nadmin.colors.chat.dead)
            table.insert(tbl, "*DEAD* ")
        end
        if isTeam then
            table.insert(tbl, nadmin.colors.chat.team)
            table.insert(tbl, "(TEAM) ")
        end
        if IsValid(ply) then
            local rank = ply:GetDisplayRank()
            if rank and rank.title then
                table.insert(tbl, nadmin.colors.chat.tag)
                table.insert(tbl, nadmin.config.chat.tagLeft .. rank.title .. nadmin.config.chat.tagRight .. " ")
            end

            if rank and rank.color then
                table.insert(tbl, rank.color)
            else
                table.insert(tbl, nadmin.colors.white)
            end

            table.insert(tbl, ply:Nick())
        else
            table.insert(tbl, nadmin.colors.white)
            table.insert(tbl, "CONSOLE")
        end

        table.insert(tbl, nadmin.colors.white)
        table.insert(tbl, ": ")
        table.insert(tbl, string.Trim(msg))

        chat.AddText(unpack(tbl))
    end
    return true
end)

hook.Add("ChatText", "nadmin_hide_default_joins", function(ind, name, text, typ)
    if typ == "joinleave" then return true end
end)

local open = false
local suggestions = {}
hook.Add("HUDPaint", "nadmin_autocomplete", function()
    if open then
        if #suggestions > 0 then
            local x, y = chat.GetChatBoxPos()
            local w, h = chat.GetChatBoxSize()
            x = x + w + 4

            surface.SetFont("ChatFont")
            for i, s in ipairs(suggestions) do
                local sx, sy = surface.GetTextSize(s.full)

                draw.SimpleText(s.full, "ChatFont", x, y, nadmin.colors.blue)
                if isstring(s.usage) then
                    draw.SimpleText(" " .. s.usage, "ChatFont", x + sx, y, nadmin.colors.white)
                end

                y = y + sy
            end
        end
    end
end)

hook.Add("ChatTextChanged", "nadmin_update_suggestions", function(str)
    suggestions = {}

    str = string.lower(str)

    local prefix
    for i, p in ipairs(nadmin.config.prefixes) do
        if string.StartWith(str, string.lower(p)) then prefix = string.lower(p) break end
    end
    if not prefix then
        for i, p in ipairs(nadmin.config.sprefixes) do
            if string.StartWith(str, string.lower(p)) then prefix = string.lower(p) break end
        end
    end

    if isstring(prefix) then
        local args = string.Explode(" ", string.Trim(str))
        local com = args[1]
        for id, cmd in pairs(nadmin.commands) do
            if not LocalPlayer():HasPerm(cmd.id) then continue end

            if string.find(string.lower(cmd.call), string.lower(string.sub(com, #prefix + 1)), 1, true) then
                table.insert(suggestions, {usage = cmd.usage, full = prefix .. cmd.call})
            end
        end
        table.sort(suggestions, function(a, b) return a.full < b.full end)
    end
end)

hook.Add("OnChatTab", "nadmin_autocomplete_tab", function()
    if #suggestions > 0 then
        return suggestions[1].full .. " "
    end
end)

hook.Add("StartChat", "nadmin_open_chat", function() open = true end)
hook.Add("FinishChat", "nadmin_close_chat", function() open = false end)
