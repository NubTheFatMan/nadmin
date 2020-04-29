local COMMAND = {}
COMMAND.title = "Private Message"
COMMAND.description = "Send a private message to another player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Tuesday, March 31, 2020 @ 11:36 PM"
COMMAND.category = "Utility"
COMMAND.usage = "<player> {message}"
COMMAND.call = "pm"

COMMAND.client = function(caller, args)
    if #args == 0 then
        -- nadmin.pm:Open()
    else
        if #args > 1 then
            local targ = nadmin:FindPlayer(table.remove(args, 1))
            if #targ == 1 then
                if targ[1] ~= LocalPlayer() then
                    nadmin.pm:Send(targ[1], table.concat(args, " "))
                else
                    nadmin:Notify(nadmin.colors.red, nadmin.errors.noTargSelf)
                end
            elseif #targ > 1 then
                nadmin:Notify(nadmin.colors.red, nadmin.errors.TooManyTargs)
            else
                nadmin:Notify(nadmin.colors.red, nadmin.errors.noTargets)
            end
        else
            nadmin:Notify(nadmin.colors.red, "You need at least 2 arguments.")
        end
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
