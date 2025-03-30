local COMMAND = {}
COMMAND.title = "Veto Vote"
COMMAND.description = "Cancel the currently active vote or votemap change."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Wednesday, March 24, 2021 @ 11:44 PM CST"
COMMAND.category = "Voting"
COMMAND.call = "veto"
COMMAND.defaultAccess = nadmin.access.admin

COMMAND.server = function(caller, args)
    if nadmin.vote.active then 
        nadmin.vote.active = false 
        nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " vetoed the vote, voting stopped and nothing will change.")
    elseif timer.Exists("nadmin_votemap") then 
        timer.Remove("nadmin_votemap")
        nadmin:Notify(nadmin:GetNameColor(caller) or nadmin.colors.blue, caller:Nick(), nadmin.colors.white, " vetoed the votemap, map will no longer change.")
    else 
        nadmin:Notify(nadmin.colors.red, "No voting or map changing in progress.")
    end
end

nadmin:RegisterCommand(COMMAND)