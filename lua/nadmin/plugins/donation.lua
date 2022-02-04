local cmd = {}
cmd.title = "Donation Received"
cmd.description = "This is not meant to be used by players, only the console."
cmd.author = "Nub"
cmd.timeCreated = "July 5 2021 @ 11:28 PM CST"
cmd.category = "Utility"
cmd.call = "donationreceived"
cmd.usage = "<player>"

cmd.onCall = function(caller, args)
    if not args[1] or args[1] == "" then return end 
    local id = args[1]
    local user = nadmin:CheckData(id)

    local userRank = nadmin:FindRank(user.rank)
    local donorRank = nadmin:FindRank("donator")

    local rankDisplay = userRank
    local name = user.lastJoined.name

    if userRank.immunity < donorRank.immunity then 
        rankDisplay = donorRank
        local ply = nadmin:FindPlayer(id)
        if IsValid(ply) then 
            ply:SetRank(donorRank.id)
            ply:SaveData()
            name = ply:Nick()
        else 
            user.rank = donorRank.id
            nadmin:SaveData(id)
        end
    end

    nadmin:Notify(rankDisplay.color, name, nadmin.colors.white, " has donated to the server!")
end

nadmin:RegisterCommand(cmd)

-- local id = Prometheus.Temp.SteamID
-- local user = nadmin:CheckData(id)

-- local userRank = nadmin:FindRank(user.rank)
-- local donorRank = nadmin:FindRank("donator")

-- local rankDisplay = userRank
-- local name = user.lastJoined.name

-- if userRank.immunity < donorRank.immunity then 
--     rankDisplay = donorRank
--     local ply = nadmin:FindPlayer(id)
--     if IsValid(ply) then 
--         ply:SetRank(donorRank.id)
--         ply:SaveData()
--         name = ply:Nick()
--     else 
--         user.rank = donorRank.id
--         nadmin:SaveData(id)
--     end
-- end

-- nadmin:Notify(rankDisplay.color, name, nadmin.colors.white, " has donated ", nadmin.colors.blue, "$", Prometheus.Temp.CashSpent, nadmin.colors.white, "!")