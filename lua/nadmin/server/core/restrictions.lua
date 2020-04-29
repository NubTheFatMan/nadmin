--Find registered tools, entities, and weapons when the server is ready.
hook.Add("Initialize", "nadmin.find.registered.shit", function()
    -- Find all vehicles
    for spawnname, v in pairs(list.Get("Vehicles")) do
        table.insert(nadmin.vehicles, spawnname)
    end
    -- Simfphys support
    for spawnname, v in pairs(list.Get("simfphys_vehicles")) do
        table.insert(nadmin.vehicles, spawnname)
    end
    table.sort(nadmin.vehicles, function(a, b) return a < b end)

    -- Find all NPCs
    for i, npc in pairs(list.Get("NPC")) do
        table.insert(nadmin.npcs, npc.Class)
    end
    table.sort(nadmin.npcs, function(a, b) return a < b end)

    --Find all the weapons (so they can be restriced in menu)
    for i, wep in pairs(weapons.GetList()) do
        table.insert(nadmin.weapons, wep.ClassName)
    end
    table.Add(nadmin.weapons, {
        "weapon_crowbar",
        "weapon_physcannon",
        "weapon_physgun",
        "weapon_pistol",
        "weapon_357",
        "weapon_smg1",
        "weapon_ar2",
        "weapon_shotgun",
        "weapon_crossbow",
        "weapon_frag",
        "weapon_rpg",
        "weapon_annabelle",
        "weapon_stunstick",
        "weapon_slam"
    })
    --Sort in alphabetical order
    table.sort(nadmin.weapons, function(a, b) return a < b end)

    --Find all entities (so they can be restricted in menu)
    for class, ent in pairs(scripted_ents.GetList()) do
        if ent.t.Spawnable or ent.t.AdminSpawnable then
            table.insert(nadmin.entities, ent.t.ClassName or class)
        end
    end
    --Sort them in alphabetical order
    table.sort(nadmin.entities, function(a, b) return a < b end)

    --Tools
    if GAMEMODE.IsSandboxDerived then
        local tools, _ = file.Find("weapons/gmod_tool/stools/*.lua", "LUA")
        for _, val in ipairs(tools) do
            local _, __, class = string.find(val, "([%w_]*)%.lua")
            table.insert(nadmin.tools, class)
        end

        --Wiremod
        local tools, _ = file.Find("wire/stools/*.lua", "LUA")
        for _, val in ipairs(tools) do
            local _, __, class = string.find(val, "([%w_]*)%.lua")
            table.insert(nadmin.tools, class)
        end
    end
    table.sort(nadmin.tools, function(a, b) return a < b end)
end)
