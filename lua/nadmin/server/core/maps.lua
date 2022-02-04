-- This file gets all maps for voting
nadmin.maps = nadmin.maps or {}

local maps = file.Find("maps/*.bsp", "GAME")
for i, map in ipairs(maps) do 
    local name = string.sub(map, 1, #map - 4)
    if not table.HasValue(nadmin.maps, name) then 
        table.insert(nadmin.maps, name)
    end
end