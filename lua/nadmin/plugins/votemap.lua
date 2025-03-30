local COMMAND = {}
COMMAND.title = "Votemap"
COMMAND.description = "Vote to change to a different map. List no argument to open a menu."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Wednesday, March 24, 2021 @ 10:56 PM CST"
COMMAND.category = "Voting"
COMMAND.call = "votemap"
COMMAND.usage = "[map name/index]"
COMMAND.defaultAccess = nadmin.access.default

nadmin.votemapChange = true

COMMAND.server = function(caller, args)
    if not args[1] then return end

    if timer.Exists("nadmin_votemap") then 
        nadmin:Notify(caller, nadmin.colors.red, "Map is about to change to a new level.")
        return
    end

    local index = tonumber(args[1])
    local map
    if isnumber(index) and index > 0 and index <= #nadmin.maps then 
        map = nadmin.maps[index]
    elseif table.HasValue(nadmin.maps, string.lower(args[1])) then 
        for i, m in ipairs(nadmin.maps) do
            if m == args[1] then map = m break end
        end
    end

    if map then 
        if not nadmin.vote.active then 
            local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
            nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has started a vote to change the map to ", nadmin.colors.red, map, nadmin.colors.white, ".")
            nadmin:CreateVote({
                title = "Votemap",
                description = "Change map to " .. map .. "?", 
                choices = {"Yes", "No"},
                showResponses = true,
                showResults = false,
                forcedResponse = false,
                onComplete = function(responses, responded)
                    -- Do nothing if it's a 50/50
                    if #responses["Yes"] == #responses["No"] then 
                        nadmin:Notify(nadmin.colors.blue, "Tie", nadmin.colors.white, "! Map will not change.")
                        return
                    end

                    if #responses["Yes"] > #responses["No"] then 
                        local wanted = math.Round((#responses["Yes"]/#responded) * 100)
                        nadmin:Notify(nadmin.colors.white, "Majority voted ", nadmin.colors.blue, "yes", nadmin.colors.white, " (", nadmin.colors.blue, tostring(wanted) .. "%", nadmin.colors.white, ")! Map will change to ", nadmin.colors.red, map, nadmin.colors.white, " in ", nadmin.colors.red, "60 seconds", nadmin.colors.white, ".")

                        nadmin:Announce("Map changing to " .. map, 58)
                        timer.Create("nadmin_votemap", 60, 1, function()
                            if not nadmin.votemapChange then nadmin.votemapChange = true return end 
                            game.ConsoleCommand("changelevel " .. map .. "\n")
                        end)
                    else 
                        local wanted = math.Round((#responses["No"]/#responded) * 100)
                        nadmin:Notify(nadmin.colors.white, "Majority voted ", nadmin.colors.red, "no", nadmin.colors.white, " (", nadmin.colors.red, tostring(wanted) .. "%", nadmin.colors.white, ")! Map will not change.")
                    end
                end
            })
        else 
            nadmin:Notify(caller, nadmin.colors.red, "There's already an ongoing vote.")
        end
    else 
        nadmin:Notify(caller, nadmin.colors.red, "Invalid map specified.")
    end
end

COMMAND.client = function(caller, args)
    if #args == 0 then 
        local menu = nadmin.vgui:DFrame(nil, {ScrW()/5, ScrH()/2})
        menu:Center()
        menu:SetTitle("Votemap")
        menu:MakePopup()

        local list = vgui.Create("DListView", menu)
        list:SetPos(4, 34)
        list:SetSize(menu:GetWide() - 8, menu:GetTall() - 38)
        list:AddColumn("Click a map to vote")
        list:SetMultiSelect(false)

        for i, map in ipairs(nadmin.maps) do
            list:AddLine(map)
        end

        function list:OnRowSelected(index, row)
            LocalPlayer():ConCommand("nadmin votemap " .. row:GetValue(1))
            menu:Remove()
        end

        function menu.close_button:DoClick()
            menu:Remove()
        end
    end
end

nadmin:RegisterCommand(COMMAND)