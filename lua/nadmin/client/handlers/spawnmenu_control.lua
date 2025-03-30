hook.Add("Initialize", "nadmin_add_right_click_perms", function()
    -- This way of adding right click spawn menu functionality could be considered hacky
    if not isfunction(nadmin.oldDermaMenu) then nadmin.oldDermaMenu = DermaMenu end
    function DermaMenu(parentmenu, parent)
        nadmin.prevPrevSpawnMenuRightClick = nadmin.prevSpawnMenuRightClick -- For base game props
        nadmin.prevSpawnMenuRightClick = nadmin.spawnMenuRightClick -- For SProps
        nadmin.spawnMenuRightClick = nadmin.oldDermaMenu(parentmenu, parent) -- For weapons, ents, vehicles, etc
        return nadmin.spawnMenuRightClick
    end

    local icon = vgui.GetControlTable("ContentIcon")
    if not isfunction(icon.nadmin_oldInit) then icon.nadmin_oldInit = icon.Init end
    function icon:Init()
        self:nadmin_oldInit()
        function self:DoRightClick()
            if isfunction(self.OpenMenu) then
                self:OpenMenu(self)
            end
            if not LocalPlayer():HasPerm("manage_ranks") then return end
            if IsValid(nadmin.spawnMenuRightClick) then
                local name
                if self.GetSpawnName then name = self:GetSpawnName() 
                elseif self.GetModelName then name = self:GetModelName() end
                
                if table.HasValue(nadmin.entities, name) or table.HasValue(nadmin.npcs, name) or table.HasValue(nadmin.vehicles, name) or table.HasValue(nadmin.weapons, name) or string.StartWith(name, "models/") then 
                    local ranks = {}
                    local call_rank = LocalPlayer():GetRank()
                    for id, rank in pairs(nadmin.ranks) do
                        if rank.access >= nadmin.access.owner then continue end
                        if rank.access > call_rank.access or (rank.access == call_rank.access and rank.immunity >= call_rank.immunity) then continue end
                        table.insert(ranks, rank)
                    end
                    table.sort(ranks, function(a, b) 
                        if a.access == b.access then 
                            return a.immunity < b.immunity 
                        else 
                            return a.access < b.access 
                        end
                    end)

                    local menu = nadmin.spawnMenuRightClick -- weapons, ents, vehicles, etc
                    if self.GetModelName then
                        if IsValid(nadmin.prevPrevSpawnMenuRightClick) then 
                            menu = nadmin.prevPrevSpawnMenuRightClick -- For base game props
                        elseif IsValid(nadmin.prevSpawnMenuRightClick) then 
                            menu = nadmin.prevSpawnMenuRightClick -- For SProps (no idea why)
                        end
                    end
                    
                    if not menu then return end
                    if not isfunction(menu.AddSubMenu) then return end

                    local sub = menu:AddSubMenu("Restrict from rank")
                    for i, rank in ipairs(ranks) do
                        local line = sub:AddOption(rank.title, function()
                            MsgN("Toggling restriction for \"" .. name .. "\" for rank " .. rank.title)
                            net.Start("nadmin_restrict_perm")
                                net.WriteString("Restrict")
                                net.WriteString(rank.id)
                                net.WriteString(name)
                            net.SendToServer()
                        end)
                        if table.HasValue(rank.restrictions, name) then
                            line:SetIcon("icon16/lock.png")
                        else
                            line:SetIcon("icon16/lock_open.png")
                        end
                    end
                end
            end
        end
    end

    local spawn = vgui.GetControlTable("SpawnIcon")
    spawn.nadmin_oldInit = spawn.Init
    spawn.Init = icon.Init
end)