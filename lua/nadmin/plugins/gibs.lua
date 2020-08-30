local COMMAND = {}
COMMAND.title = "Cleanup Gibs"
COMMAND.description = "Cleanup gibs (dead NPCs, etc)."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Wednesday, May 20, 2020 @ 11:27 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "gibs"
COMMAND.server = function(caller, args)
    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

    local msg = {myCol, caller:Nick(), nadmin.colors.white, " has removed all gibs."}
    nadmin:Notify(unpack(msg))
    net.Start("nadmin_gibs") net.Broadcast()
end

if SERVER then
    util.AddNetworkString("nadmin_gibs")
else
    function nadmin:CleanGibs()
        -- Remove sprays; bloodsplats, etc
        LocalPlayer():ConCommand("r_cleardecals;r_cleardecals")

        -- Remove ragdolls
        for i, r in pairs(ents.FindByClass("class C_ClientRagdoll")) do r:SetNoDraw(true) end
	    for i, r in pairs(ents.FindByClass("class C_BaseAnimating")) do r:SetNoDraw(true) end
    end

    timer.Create("nadmin_cleanup_gibs", 300, 0, function()
        nadmin:CleanGibs()

        notification.AddLegacy("Gibs automatically cleaned", NOTIFY_HINT, 3)
        surface.PlaySound("ambient/levels/canals/drip" .. tostring(math.random(1, 4)) .. ".wav")
    end)

    net.Receive("nadmin_gibs", function()
        nadmin:CleanGibs()
    end)
end

nadmin:RegisterCommand(COMMAND)
