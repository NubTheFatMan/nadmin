-- To prevent spammers/exploiters from crashing the server by spamming cmds,
-- we need to have a cooldown to block commands
nadmin.buffer = {}
hook.Add("Think", "nadmin_cooldown_buffer", function()
    local now = os.time()
    for i, ply in ipairs(player.GetAll()) do
        if not nadmin.buffer[ply:SteamID()] then nadmin.buffer[ply:SteamID()] = {left = 5, last = 0} end
        local buf = nadmin.buffer[ply:SteamID()]
        if buf.left < 5 and now - buf.last >= 1 then
            buf.left = math.min(buf.last + 5, 5)
            buf.last = now
        end
    end
end)

hook.Add("PlayerSay", "nadmin_chat", function(ply, msg, isTeam)
    if ply.n_Imitated then
        ply.n_Imitated = nil
        return
    end

    if nadmin.SilentNotify then nadmin.SilentNotify = false end

    local advArgs, args = nadmin:ParseArgs(msg)
    local cmd = string.lower(table.remove(args, 1))

    local prefix = ""
    for i, p in ipairs(nadmin.config.prefixes) do
        if string.StartWith(string.lower(cmd), string.lower(p)) then
            prefix = p
        end
    end
    if prefix == "" then
        for i, p in ipairs(nadmin.config.sprefixes) do
            if string.StartWith(string.lower(cmd), string.lower(p)) then
                prefix = p
                nadmin.SilentNotify = true
            end
        end
    end

    cmd = string.sub(cmd, #prefix + 1)

    if #prefix > 0 then
        -- Buffer to stop spam
        if istable(nadmin.buffer[ply:SteamID()]) then
            local buf = nadmin.buffer[ply:SteamID()]
            if buf.left < 1 then
                nadmin:Notify(ply, nadmin.colors.red, "You have reached your cooldown limit!")
                return
            else
                buf.left = buf.left - 1
                buf.last = os.time()
            end
        end

        local ran = false
        local found = false

        for i, command in pairs(nadmin.commands) do
            if cmd == string.lower(command.call) then --Does their command match the command call?
                found = true
                if ply:HasPerm(command.id) then -- Does the player have permission?
                    ran = true
                    nadmin:Log("messages", ply:PlayerToString("nick (steamid)<ipaddress>") .. " has ran command \"" .. command.title .. "\" with arguments \"" .. table.concat(args, " ") .. "\"")
                    if isfunction(command.server) then
                        lastRan = os.time()
                        local success, err = pcall(command.server, ply, args, advArgs)
                        if not success then
                            nadmin:Notify(ply, nadmin.colors.red, "Error in command \"" .. command.title .. "\":\n" .. err)
                            nadmin:Log("messages", "Error in command \"" .. command.title .. "\":\n" .. err)
                        end
                    end
                    if isfunction(command.client) then
                        net.Start("nadmin_clientRun")
                            net.WriteString(command.id)
                            net.WriteTable(args)
                            net.WriteTable(advArgs)
                        net.Send(ply)
                    end
                end
            end
        end

        if not ran and found then
            nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
            return ""
        elseif found then
            return ""
        end
    end
end)

concommand.Add("nadmin", function(ply, comm, argList, argStr)
    local advArgs, args = nadmin:ParseArgs(argStr)
    local com = table.remove(args, 1)

    local ran = false
    for i, cmd in pairs(nadmin.commands) do
        if com == string.lower(cmd.call) then
            ran = true
            if isfunction(cmd.server) then
                nadmin:Log("messages", NULL:Nick() .. " has ran command \"" .. cmd.title .. "\" with arguments \"" .. table.concat(args, "  ") .. "\"")
                -- cmd.server(NULL, args, advArgs) -- Debugging (errors have a stack trace)
                local success, err = pcall(cmd.server, NULL, args, advArgs)
                if not success then
                    nadmin:Log("messages", "Error in command \"" .. cmd.title .. "\":\n" .. err)
                end
            end
            if isfunction(cmd.client) then
                MsgN("Unable to run client function, as you're the console. You must do this in game.")
            end
        end
    end

    if not ran then
        MsgN("No command was found.")
    end
end)

net.Receive("nadmin_command", function(len, ply)
    local args = net.ReadTable()
    local advArgs = net.ReadTable()

    -- Buffer to stop spam
    if istable(nadmin.buffer[ply:SteamID()]) then
        local buf = nadmin.buffer[ply:SteamID()]
        if buf.left < 1 then
            nadmin:Notify(ply, nadmin.colors.red, "You have reached your cooldown limit!")
            return
        else
            buf.left = buf.left - 1
            buf.last = os.time()
        end
    end

    nadmin.SilentNotify = net.ReadBool()

    local cmd = string.lower(table.remove(args, 1))
    local ran = false
    for i, command in pairs(nadmin.commands) do
        if cmd == string.lower(command.call) then --Does their command match the command call?
            if ply:HasPerm(command.id) then
                ran = true
                if isfunction(command.server) then
                    nadmin:Log("messages", ply:PlayerToString("nick (steamid)<ipaddress>") .. " has ran command \"" .. command.title .. "\" with arguments \"" .. table.concat(args, " ") .. "\"")
                    local success, err = pcall(command.server, ply, args, advArgs)
                    if not success then
                        nadmin:Notify(ply, nadmin.colors.red, "Error in command \"" .. command.title .. "\":\n" .. err)
                        nadmin:Log("messages", "Error in command \"" .. command.title .. "\":\n" .. err)
                    end
                end
                if isfunction(command.client) then
                    net.Start("nadmin_clientRun")
                        net.WriteString(command.id)
                        net.WriteTable(args)
                        net.WriteTable(advArgs)
                    net.Send(ply)
                end
            end
        end
    end

    if not ran then
        nadmin:Notify(ply, nadmin.colors.red, nadmin.errors.accessDenied)
    end
end)
