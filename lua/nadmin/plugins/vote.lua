local COMMAND = {}
COMMAND.title = "Vote"
COMMAND.description = "Create a custom vote for people to decide. Arguments may be confusing, but the first argument is the description, the rest are choices. Make sure to wrap each argument in quotes to have spaces. Example: !vote \"Cleanup map?\" \"Yes\" \"No\""
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, March 25, 2021 @ 11:23 PM CST"
COMMAND.category = "Voting"
COMMAND.call = "vote"
COMMAND.usage = "{description} [{choices}]"

nadmin.votemapChange = true

COMMAND.server = function(caller, args)
    local numArgs = #args

    if numArgs > 0 then 
        if not nadmin.vote.active then 
            local desc = table.remove(args, 1)
            nadmin:CreateVote({
                title = "Vote",
                description = desc, 
                choices = args,
                showResponses = true,
                showResults = true,
                forcedResponse = false
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a vote.")
        else 
            nadmin:Notify(caller, nadmin.colors.red, "There's a vote already in progress. Please wait.")
        end
    else 
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

nadmin:RegisterCommand(COMMAND)