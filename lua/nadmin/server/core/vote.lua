nadmin.vote = nadmin.vote or {}

function nadmin:CreateVote(tbl)
    nadmin.vote.active = false
    if nadmin.vote.active then return end

    nadmin.vote = table.Copy(tbl)

    nadmin.vote.title          = nadmin:Ternary(isstring(tbl.title),        tbl.title,          "Vote")
    nadmin.vote.description    = nadmin:Ternary(isstring(tbl.description),  tbl.description,    "")
    nadmin.vote.choices        = nadmin:Ternary(istable(tbl.choices),       tbl.choices,        {"Yes", "No"})
    nadmin.vote.timeout        = nadmin:Ternary(isnumber(tbl.timeout),      tbl.timeout,        30) - 2
    nadmin.vote.forcedResponse = nadmin:Ternary(isbool(tbl.forcedResponse), tbl.forcedResponse, false)
    nadmin.vote.showResponses  = nadmin:Ternary(isbool(tbl.showResponses),  tbl.showResponses,  true)
    nadmin.vote.showResults    = nadmin:Ternary(isbool(tbl.showResults),    tbl.showResults,    true)

    if #nadmin.vote.choices == 0 then return end --No need sending a vote with no choices

    nadmin.vote.active = true
    nadmin.vote.players = player.GetHumans() -- We don't want bots included

    nadmin.vote.responses = {}
    for i, v in ipairs(nadmin.vote.choices) do
        nadmin.vote.responses[v] = {}
    end
    nadmin.vote.totalResponses = 0
    nadmin.vote.responded = {} -- We are also using this to prevent duplicate votes from the same person

    -- We want to do this last so the execution time is after everything is set
    nadmin.vote.start = os.time()

    local vote = {}
    for i, v in pairs(nadmin.vote) do
        if type(v) ~= "function" then vote[i] = v end
    end

    net.Start("nadmin_cast_vote")
        net.WriteTable(vote)
    net.Broadcast()
end

net.Receive("nadmin_cast_vote", function()
    local ply = net.ReadEntity()
    local choice = net.ReadString()

    if not nadmin.vote.active then return end --No current vote running

    if not table.HasValue(nadmin.vote.responded, ply) then --Ignore the response if they already voted
        if istable(nadmin.vote.responses[choice]) then --Ignore the response if they gave an invalid choice (if they were injecting code)
            table.insert(nadmin.vote.responded, ply)
            table.insert(nadmin.vote.responses[choice], ply)

            if nadmin.vote.showResponses then
                nadmin:Notify(nadmin.colors.blue, ply:Nick(), nadmin.colors.white, " has voted ", nadmin.colors.red, choice, nadmin.colors.white, ".")
            end

            if #nadmin.vote.responded == #nadmin.vote.players then --Everyone voted
                if nadmin.vote.showResults then
                    local msg = {nadmin.colors.white, "Vote completed! Results:"}
                    for choice, plys in pairs(nadmin.vote.responses) do
                        table.insert(msg, " " .. choice)
                        table.insert(msg, " (")
                        table.insert(msg, nadmin.colors.blue)
                        table.insert(msg, tostring(math.Round((#plys/#nadmin.vote.responded)*100)) .. "%")
                        table.insert(msg, nadmin.colors.white)
                        table.insert(msg, ")")
                    end
                    table.insert(msg, ".")

                    nadmin:Notify(unpack(msg))
                end

                if isfunction(nadmin.vote.onComplete) then
                    local success, err = pcall(nadmin.vote.onComplete, nadmin.vote.responses, nadmin.vote.responded)
                    if not success then
                        nadmin:Notify(nadmin.colors.red, "Error in vote onComplete function: ")
                        nadmin:Notify(nadmin.colors.red, err)

                        nadmin:Log("Error in vote onComplete function: ")
                        nadmin:Log(err)
                    end
                end
                nadmin.vote.active = false
            end
        end
    end
end)

hook.Add("Think", "nadmin_vote_timeout", function()
    if not (istable(nadmin.vote) and nadmin.vote.active) then return end
    if not (isnumber(nadmin.vote.start) and isnumber(nadmin.vote.timeout)) then return end

    local now = os.time()
    if now - nadmin.vote.start >= nadmin.vote.timeout then
        if nadmin.vote.showResults then
            local msg = {nadmin.colors.white, "Vote timed out! Results:"}
            for choice, plys in pairs(nadmin.vote.responses) do
                table.insert(msg, " " .. choice)
                table.insert(msg, " (")
                table.insert(msg, nadmin.colors.blue)
                table.insert(msg, tostring(math.Round((#plys/#nadmin.vote.responded)*100)) .. "%")
                table.insert(msg, nadmin.colors.white)
                table.insert(msg, ")")
            end
            table.insert(msg, ".")

            nadmin:Notify(unpack(msg))
        end

        if isfunction(nadmin.vote.onComplete) then
            local success, err = pcall(nadmin.vote.onComplete, nadmin.vote.responses, nadmin.vote.responded)
            if not success then
                nadmin:Notify(nadmin.colors.red, "Error in vote onComplete function: ")
                nadmin:Notify(nadmin.colors.red, err)

                nadmin:Log("Error in vote onComplete function: ")
                nadmin:Log(err)
            end
        end
        nadmin.vote.active = false
    end
end)
