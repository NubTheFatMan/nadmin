local COMMAND = {}
COMMAND.title = "Private Message"
COMMAND.description = "Send a private message to another player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, March 31, 2020 @ 11:36 PM"
COMMAND.category = "Utility"
COMMAND.usage = "<player> {message}"
COMMAND.call = "pm"

COMMAND.server = function(caller, args)
    if #args < 2 then 
        nadmin:Notify(caller, nadmin.colors.red, "You need at least 2 arguments.")
        return
    end

    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_ALL)
    if #targs == 1 then 
        local targ = targs[1]
        if targ ~= caller then 
            local targCol = nadmin:GetNameColor(targ) or nadmin.colors.red
            local callCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

            local msg = table.concat(args, " ", 2)

            nadmin.SilentNotify = false
            nadmin:Notify(caller, nadmin.colors.white, '[', callCol, 'You', nadmin.colors.white, ' to ', targCol, targ:Nick(), nadmin.colors.white, '] ' .. msg)
            nadmin.SilentNotify = false
            nadmin:Notify(targ, nadmin.colors.white, '[', callCol, caller:Nick(), nadmin.colors.white, ' to ', targCol, "You", nadmin.colors.white, '] ' .. msg)
        else 
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargSelf)
        end
    elseif #targs > 1 then 
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
    else 
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargets)
    end
end

local com = Material("icon16/comment.png")

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    },
    {
        text = "Message",
        type = "string"
    }
}

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_ALL
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(com)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = COMMAND.advUsage
    nadmin.scoreboard.call = COMMAND.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(COMMAND)
