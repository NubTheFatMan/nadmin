local COMMAND = {}
COMMAND.title = "Voteban"
COMMAND.description = "Start a vote to ban a player for 30 minutes."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, May 21, 2020 @ 1:22 AM CT"
COMMAND.category = "Voting"
COMMAND.call = "voteban"
COMMAND.usage = "<player> {reason}"
COMMAND.defaultAccess = nadmin.access.default

nadmin.voteBans = {}

COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
    if #targs == 1 then
        if not istable(nadmin.vote) or not nadmin.vote.active then
            nadmin.voteBans[targs[1]:SteamID()] = {caller:Nick(), caller:SteamID()}
            local reason = table.concat(args, " ")
            if isstring(reason) and reason == "" then reason = "No reason given." end
            nadmin:CreateVote({
                title = "Ban " .. targs[1]:Nick() .. " for 30 minutes?",
                description = reason,
                choices = {"Yes", "No"},
                showResponses = false,
                showResults = false,
                forcedResponse = false,
                onComplete = function(responses, responded)
                    if #responses["Yes"] >= #responses["No"] then
                        if IsValid(targs[1]) then
                            nadmin.voteBans[targs[1]:SteamID()] = nil
                            nadmin.SilentNotify = true
                            nadmin:Ban(targs[1]:Nick(), targs[1]:SteamID(), caller, "Votebanned: " .. reason, 1800)
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " has been banned for 30 minutes.")
                        end
                    else
                        if IsValid(targs[1]) then
                            nadmin.voteBans[targs[1]:SteamID()] = nil
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " will not be banned.")
                        end
                    end
                end
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a ", nadmin.colors.blue, "voteban", nadmin.colors.white, " against ", targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "There is already a vote active!")
        end
    elseif #targs > 1 then
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
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
