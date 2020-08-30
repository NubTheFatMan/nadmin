local COMMAND = {}
COMMAND.title = "Votemode"
COMMAND.description = "Initializes a votemode to switch the server from build to war or vice versa."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, March 22, 2020 @ 2:08 AM"
COMMAND.category = "Utility"
COMMAND.call = "votemode"

nadmin:RegisterPerm({
    title = "Bypass Votemode Cooldown",
    id = "bypass_vm_cooldown"
})

local lastVote = 0
COMMAND.server = function(caller, args)
    if os.time() - lastVote >= 600 or caller:HasPerm("bypass_vm_cooldown") then
        if not istable(nadmin.vote) or not nadmin.vote.active then
            lastVote = os.time()
            nadmin:CreateVote({
                title = "Votemode",
                description = "Vote to change the gamemode (build/war)",
                choices = {"Build", "War"},
                showResponses = false,
                showResults = false,
                forcedResponse = true,
                onComplete = function(responses, responded)
                     -- We don't want to do anything in a 50/50
                    if #responses["Build"] == #responses["War"] then
                        nadmin:Notify(nadmin.colors.blue, "Tie", nadmin.colors.white, "! Gamemode will ", nadmin.colors.red, "not", nadmin.colors.white, " change.")
                        return
                    end

                    if #responses["Build"] > #responses["War"] then
                        local wanted = math.Round((#responses["Build"]/#responded) * 100)
                        nadmin:Notify(nadmin.colors.blue, "Build", nadmin.colors.white, " won (", nadmin.colors.blue, tostring(wanted) .. "%", nadmin.colors.white, ")! Gamemode will change.")

                        RunConsoleCommand("sbox_godmode", "1")
                        RunConsoleCommand("sbox_noclip", "1")
                    else
                        local wanted = math.Round((#responses["War"]/#responded) * 100)
                        nadmin:Notify(nadmin.colors.blue, "War", nadmin.colors.white, " won (", nadmin.colors.blue, tostring(wanted) .. "%", nadmin.colors.white, ")! Gamemode will change.")

                        RunConsoleCommand("sbox_godmode", "0")
                        RunConsoleCommand("sbox_noclip", "0")

                        for i, ply in ipairs(player.GetAll()) do --Take everyone out of noclip
                            if ply:GetMoveType() == MOVETYPE_NOCLIP and not ply:HasPerm("always_allow_noclip") then
                                ply:SetMoveType(MOVETYPE_WALK)
                            end
                        end
                    end
                end
            })

            nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " has started a ", nadmin.colors.red, "votemode", nadmin.colors.white, ".")
        else
            nadmin:Notify(caller, nadmin.colors.red, "There is already a vote active!")
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, "You must wait ", nadmin.colors.white, nadmin:TimeToString(lastVote + 600 - os.time(), true), nadmin.colors.red, " before another votemode!")
    end
end

nadmin:RegisterCommand(COMMAND)
