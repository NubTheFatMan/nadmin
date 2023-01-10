-- Short files have been combined into this one to deflate the high file count


-- Formerly commands.lua
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


-- Formerly icon_load.lua
resource.AddFile("materials/nadmin/nadmin.png")
resource.AddFile("materials/nadmin/back_arrow.png")


-- Formerly maps.lua
nadmin.maps = nadmin.maps or {}

local maps = file.Find("maps/*.bsp", "GAME")
for i, map in ipairs(maps) do 
    local name = string.sub(map, 1, #map - 4)
    if not table.HasValue(nadmin.maps, name) then 
        table.insert(nadmin.maps, name)
    end
end