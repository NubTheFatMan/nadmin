net.Receive("nadmin_clientRun", function()
    local cmd = nadmin.commands[net.ReadString()]
    if istable(cmd) then
        if isfunction(cmd.client) then
            local success, err = pcall(cmd.client, LocalPlayer(), net.ReadTable(), net.ReadTable())
            if not success then
                nadmin:Notify(nadmin.colors.red, "Error in command \"" .. cmd.title .. "\":\n" .. err)
            end
        end
    end
end)

concommand.Add("nadmin", function(ply, comm, argList, argStr)
    local advArgs, args = nadmin:ParseArgs(argStr)
    net.Start("nadmin_command")
        net.WriteTable(args)
        net.WriteTable(advArgs)
        net.WriteBool(false)
    net.SendToServer()
end)
concommand.Add("nadmins", function(ply, comm, argList, argStr)
    local advArgs, args = nadmin:ParseArgs(argStr)
    net.Start("nadmin_command")
        net.WriteTable(args)
        net.WriteTable(advArgs)
        net.WriteBool(true)
    net.SendToServer()
end)
