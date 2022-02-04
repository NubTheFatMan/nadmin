hook.Add("PlayerSpawnedProp", "nadmin_spawn_log", function(ply, model, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned prop \"" .. model .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedSENT", "nadmin_spawn_log", function(ply, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned scripted entity \"" .. ent:GetClass() .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedNPC", "nadmin_spawn_log", function(ply, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned NPC \"" .. ent:GetClass() .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedVehicle", "nadmin_spawn_log", function(ply, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned vehicle \"" .. ent:GetClass() .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedEffect", "nadmin_spawn_log", function(ply, model, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned effect \"" .. model .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedRagdoll", "nadmin_spawn_log", function(ply, model, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned ragdoll \"" .. model .. "\"")
    ent.nadmin_owner = ply
end)
hook.Add("PlayerSpawnedSWEP", "nadmin_spawn_log", function(ply, ent)
    nadmin:Log("entity_spawns", ply:PlayerToString("nick (steamid)<ipaddress>") .. " spawned weapon \"" .. ent:GetClass() .. "\"")
    ent.nadmin_owner = ply
end)

hook.Add("PlayerSay", "nadmin_chat_log", function(ply, txt, isTeam)
    nadmin:Log("messages", ply:PlayerToString("nick (steamid)") .. nadmin:Ternary(isTeam, " (TEAM)", "") .. ": " .. txt, true)
end)
