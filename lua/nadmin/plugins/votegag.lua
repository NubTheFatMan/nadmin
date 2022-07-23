local COMMAND = {}
COMMAND.title = "Votegag"
COMMAND.description = "Start a vote to gag a player (mute their voice chat)."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, July 22, 2022 @ 8:22 PM PT"
COMMAND.category = "Voting"
COMMAND.call = "votegag"
COMMAND.usage = "<player> {reason}"

COMMAND.gagTime = 1800 -- 30 minutes

COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
    if #targs == 1 then
        if not istable(nadmin.vote) or not nadmin.vote.active then
            local targ = {targs[1]:Nick(), targs[1]:SteamID()}
            local reason = table.concat(args, " ")
            if isstring(reason) and reason == "" then reason = "No reason given." end
            nadmin:CreateVote({
                title = "Gag " .. targ[1] .. "?",
                description = reason,
                choices = {"Yes", "No"},
                showResponses = false,
                showResults = false,
                forcedResponse = false,
                onComplete = function(responses, responded)
                    if #responses["Yes"] >= #responses["No"] then
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " was gagged.")
                            targs[1].n_Gagged = true
                            targs[1].n_GagTime = SysTime() + COMMAND.gagTime
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " would have been gagged if they stayed.")
                        end
                    else
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " will not be gagged.")
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " wouldn't have been gagged if they stayed.")
                        end
                    end
                end
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a ", nadmin.colors.blue, "votegag", nadmin.colors.white, " against ", targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "There is already a vote active!")
        end
    elseif #targs > 1 then
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

if SERVER then 
    hook.Add("Think", "autoUngag", function()
        for _, ply in ipairs(player.GetAll()) do
            if ply.n_Gagged and ply.n_GagTime and ply.n_GagTime <= SysTime() then
                ply.n_Gagged = false
                ply.n_GagTime = nil
                nadmin:Notify(nadmin:GetNameColor(ply:SteamID()) or nadmin.colors.blue, ply:Nick(), nadmin.colors.white, " has been ungagged.")
            end
        end
    end)
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "string",
        text = "Reason"
    }
}

nadmin:RegisterCommand(COMMAND)
