--Notifications
nadmin.SilentNotify = false --If true, the the notification isn't sent. Gets set false on a new message, unless it starts with a silent prefix
function nadmin:Notify(...) --Function copied from Evolve
    local ply --Who we send the print to
    local arg = {...} --All the arguments passed into the function
    local strArg = {} --We are gonna use this to log in console

    if type(arg[1]) == "Player" or arg[1] == NULL then ply = arg[1] end --If the first argument is a player or INVALID  entity then the player is that thing
    if ply != NULL then --Are they a player?
        net.Start("nadmin_notification")
        net.WriteUInt(#arg, 16)
        for _, a in ipairs(arg) do
            if isstring(a) then
                net.WriteBit(false)
                net.WriteString(a)
                table.insert(strArg, a)
            elseif istable(a) then
                net.WriteBit(true)
                net.WriteUInt(a.r, 8)
                net.WriteUInt(a.g, 8)
                net.WriteUInt(a.b, 8)
                net.WriteUInt(a.a, 8)
            elseif isnumber(a) then
                net.WriteBit(false)
                net.WriteString(tostring(a))
                table.insert(strArg, tostring(a))
            end
        end
        if ply ~= nil then --Is the player valid?
            net.Send(ply)
        else
            if nadmin.SilentNotify then
                local plys = {}
                for i, ply in ipairs(player.GetAll()) do
                    if ply:HasPerm("see_silent_commands") then
                        table.insert(plys, ply)
                    end
                end
                net.WriteBool(true)
                net.Send(plys)
            else
                net.WriteBool(false)
                net.Broadcast()
            end
        end
    else --If it's an INVALID entity, it must be console, so we print it in console instead.
        local str = ""
        for i, a in ipairs(arg) do --Loop through arguments
            if isstring(a) or isnumber(a) then --If the argument is a number or string
                str = str .. tostring(a)
            end
        end
        MsgN("[Nadmin]" .. str) --Log the function
    end

    if nadmin.SilentNotify then
        nadmin.SilentNotify = false --Make silent notify false it it was true.
    end
end

--Logging
function nadmin:Log(typ, str, noPrint)
    if not isstring(str) then return end
    if #string.Trim(str) == 0 then return end

    if not noPrint then MsgN("[Nadmin]" .. str) end
    if nadmin.plugins.logs then
        if not isstring(typ) then typ = "other" end
        local dir = "nadmin/logs/" .. typ
        if not file.Exists(dir, "DATA") then
            file.CreateDir(dir)
        end

        local hour = os.date("%H:%M:%S", os.time())
        local date = os.date("%Y-%m-%d", os.time())
        if not file.Exists(dir .. "/" .. date .. ".txt", "DATA") then
            file.Write(dir .. "/" .. date .. ".txt", "[" .. hour .. "]" .. tostring(str))
        else
            file.Append(dir .. "/" .. date .. ".txt", "\n[" .. hour .. "]" .. tostring(str))
        end
    end
end

-- Announcements
function nadmin:Announce(str, len)
    if not isstring(str) then return end
    if #string.Trim(str) == 0 then return end
    if not isnumber(len) then return end

    if len < 1 then return end

    net.Start("nadmin_announcement")
        net.WriteString(str)
        net.WriteFloat(len)
    net.Broadcast()
end
