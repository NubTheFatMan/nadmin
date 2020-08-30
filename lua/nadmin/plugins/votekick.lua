local COMMAND = {}
COMMAND.title = "Votekick"
COMMAND.description = "Start a vote to kick a player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, May 21, 2020 @ 1:00 AM CT"
COMMAND.category = "Player Management"
COMMAND.call = "votekick"
COMMAND.usage = "<player> {reason}"

COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
    if #targs == 1 then
        if not istable(nadmin.vote) or not nadmin.vote.active then
            local targ = {targs[1]:Nick(), targs[1]:SteamID()}
            local reason = table.concat(args, " ")
            if isstring(reason) and reason == "" then reason = "No reason given." end
            nadmin:CreateVote({
                title = "Kick " .. targ[1] .. "?",
                description = reason,
                choices = {"Yes", "No"},
                showResponses = false,
                showResults = false,
                forcedResponse = false,
                onComplete = function(responses, responded)
                    if #responses["Yes"] >= #responses["No"] then
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " will be kicked.")
                            targs[1]:Kick(reason)
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " would have been kicked if they stayed.")
                        end
                    else
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " will not be kicked.")
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " wouldn't have been kicked if they stayed.")
                        end
                    end
                end
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a ", nadmin.colors.blue, "votekick", nadmin.colors.white, " against ", targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, ".")
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
