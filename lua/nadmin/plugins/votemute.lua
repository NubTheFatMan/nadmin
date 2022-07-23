local COMMAND = {}
COMMAND.title = "Votemute"
COMMAND.description = "Start a vote to mute a player (hide their text chat)."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, July 22, 2022 @ 8:30 PM PT"
COMMAND.category = "Voting"
COMMAND.call = "votemute"
COMMAND.usage = "<player> {reason}"

COMMAND.muteTime = 1800 -- 30 minutes

COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
    if #targs == 1 then
        if not istable(nadmin.vote) or not nadmin.vote.active then
            local targ = {targs[1]:Nick(), targs[1]:SteamID()}
            local reason = table.concat(args, " ")
            if isstring(reason) and reason == "" then reason = "No reason given." end
            nadmin:CreateVote({
                title = "Mute " .. targ[1] .. "?",
                description = reason,
                choices = {"Yes", "No"},
                showResponses = false,
                showResults = false,
                forcedResponse = false,
                onComplete = function(responses, responded)
                    if #responses["Yes"] >= #responses["No"] then
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " was muted.")
                            targs[1].n_Muted = true
                            targs[1].n_MuteTime = SysTime() + COMMAND.muteTime
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " would have been muted if they stayed.")
                        end
                    else
                        if IsValid(targs[1]) then
                            nadmin:Notify(targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, " will not be muted.")
                        else
                            nadmin:Notify(nadmin:GetNameColor(targ[2]) or nadmin.colors.blue, targ[1], nadmin.colors.white, " wouldn't have been muted if they stayed.")
                        end
                    end
                end
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a ", nadmin.colors.blue, "votemute", nadmin.colors.white, " against ", targs[1]:GetRank().color, targs[1]:Nick(), nadmin.colors.white, ".")
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
    hook.Add("Think", "autoUnmute", function()
        for _, ply in pairs(player.GetAll()) do
            if ply.n_Muted and ply.n_MuteTime and ply.n_MuteTime <= SysTime() then
                ply.n_Muted = false
                ply.n_MuteTime = nil
                nadmin:Notify(nadmin:GetNameColor(ply:SteamID()) or nadmin.colors.blue, ply:Nick(), nadmin.colors.white, " has been unmuted.")
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
