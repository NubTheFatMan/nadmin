local cmd = {}
cmd.title = "Give"
cmd.description = "Give a player a weapon."
cmd.author = "Nub"
cmd.timeCreated = "Tuesday, April 28 2020 @ 10:45 PM CST"
cmd.category = "Fun"
cmd.call = "give"
cmd.usage = "<player> {weapon}"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    if #args > 0 then
        local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_SAME)
        if #targs > 0 then
            if #args > 1 then
                if table.HasValue(nadmin.weapons, args[2]) then
                    if not caller:HasRestriction(args[2]) then
                        for i, ply in ipairs(targs) do
                            targs[i].n_Giving = true
                            targs[i]:Give(args[2])
                        end

                        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has given ", nadmin.colors.red, args[2], nadmin.colors.white, " to "}
                        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
                        table.Add(msg, {nadmin.colors.white, "."})
                        nadmin:Notify(unpack(msg))
                    else
                        nadmin:Notify(caller, nadmin.colors.red, "You can't give someone a weapon you don't have access too.")
                    end
                else
                    nadmin:Notify(caller, nadmin.colors.red, "Invalid weapon (open spawn menu, right click, and copy to clipboard).")
                end
            else
                nadmin:Notify(caller, nadmin.colors.red, "You must specify a weapon.")
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargSame)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player"
    },
    {
        type = "string",
        text = "weapon"
    }
}

nadmin:RegisterCommand(cmd)
