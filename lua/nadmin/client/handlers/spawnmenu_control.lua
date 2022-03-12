hook.Add("Initialize", "nadmin_add_right_click_perms", function()
    -- This way of adding right click spawn menu functionality could be considered hacky
    local oldDermaMenu = DermaMenu
    function DermaMenu(parentmenu, parent)
        nadmin.prevPrevSpawnMenuRightClick = nadmin.prevSpawnMenuRightClick
        nadmin.prevSpawnMenuRightClick = nadmin.spawnMenuRightClick
        nadmin.spawnMenuRightClick = oldDermaMenu(parentmenu, parent)
        return nadmin.spawnMenuRightClick
    end

    local icon = vgui.GetControlTable("ContentIcon")
    icon.nadmin_oldInit = icon.Init
    function icon:Init()
        self:nadmin_oldInit()
        function self:DoRightClick()
            if isfunction(self.OpenMenu) then
                self:OpenMenu(self)
            end
            if IsValid(nadmin.spawnMenuRightClick) then
                if not LocalPlayer():HasPerm("manage_ranks") then return end

                local name
                if self.GetSpawnName then name = self:GetSpawnName() 
                elseif self.GetModelName then name = self:GetModelName() end
                
                if table.HasValue(nadmin.entities, name) or table.HasValue(nadmin.npcs, name) or table.HasValue(nadmin.vehicles, name) or table.HasValue(nadmin.weapons, name) or string.StartWith(name, "models/") then 
                    local ranks = {}
                    local call_rank = LocalPlayer():GetRank()
                    for id, rank in pairs(nadmin.ranks) do
                        if rank.ownerRank or rank.immunity >= nadmin.immunity.owner then continue end
                        if rank.immunity >= call_rank.immunity then continue end
                        table.insert(ranks, {title = rank.title, id = rank.id, immunity = rank.immunity, restrictions = rank.restrictions, loadout = rank.loadout})
                    end
                    table.sort(ranks, function(a, b) return a.immunity < b.immunity end)

                    local menu = nadmin.spawnMenuRightClick
                    if self.GetModelName then menu = nadmin.prevPrevSpawnMenuRightClick end

                    local sub = menu:AddSubMenu("Restrict from rank")
                    for i, rank in ipairs(ranks) do
                        local line = sub:AddOption(rank.title, function()
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

                    if table.HasValue(nadmin.weapons, name) and nadmin.plugins.loadouts then
                        local ranks = {}
                        local call_rank = LocalPlayer():GetRank()
                        for id, rank in pairs(nadmin.ranks) do
                            if not call_rank.ownerRank or call_rank.immunity < nadmin.immunity.owner then
                                if rank.immunity >= call_rank.immunity then continue end
                            end
                            table.insert(ranks, {title = rank.title, id = rank.id, immunity = rank.immunity, restrictions = rank.restrictions, loadout = rank.loadout})
                        end
                        table.sort(ranks, function(a, b) return a.immunity < b.immunity end)

                        local sub = menu:AddSubMenu("Add to loadout")
                        for i, rank in ipairs(ranks) do
                            local line = sub:AddOption(rank.title, function()
                                net.Start("nadmin_restrict_perm")
                                    net.WriteString("Loadout")
                                    net.WriteString(rank.id)
                                    net.WriteString(name)
                                net.SendToServer()
                            end)
                            if table.HasValue(rank.loadout, name) then
                                line:SetIcon("icon16/accept.png")
                            end
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