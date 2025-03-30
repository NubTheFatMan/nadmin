local COMMAND = {}
COMMAND.title = "FPS Booster"
COMMAND.description = "Get some extra frames by enabling multicore rendering and also lower your ping."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, June 25, 2021 @ 5:56 PM"
COMMAND.category = "Utility"
COMMAND.call = "fpsboost"
COMMAND.forcedPriv = true

COMMAND.client = function(caller, args)
    LocalPlayer():ConCommand("gmod_mcore_test 1;r_queued_ropes 1;cl_threaded_bone_setup 1;mat_queue_mode -1;r_threaded_renderables 1;r_threaded_particles 1;cl_cmdrate 10")
    nadmin:Notify(nadmin.colors.blue, "Your FPS has increased and your ping has lowered!")
end

nadmin:RegisterCommand(COMMAND)
