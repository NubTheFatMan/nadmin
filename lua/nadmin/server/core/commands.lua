function nadmin:ReloadCommand(cmd)
    if isstring(cmd) then
        local f = "nadmin/plugins/" .. cmd .. ".lua"
        if file.Exists(f, "LUA") then
            include(f)
            net.Start("nadmin_update_cmds")
                net.WriteString(file.Read(f, "LUA"))
            net.Broadcast()
            return true
        end
    end
    return false
end
