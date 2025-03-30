local COMMAND = {}
COMMAND.title = "Imitate"
COMMAND.description = "Makes a player say something in chat."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, April 25, 2020 @ 12:22 AM CST"
COMMAND.category = "Fun"
COMMAND.call = "im"
COMMAND.usage = "<player> {action}"
COMMAND.defaultAccess = nadmin.access.admin
COMMAND.server = function(caller, args)
    if #args > 0 then
        local targ = nadmin:FindPlayer(table.remove(args, 1), caller, nadmin.MODE_BELOW)
        if table.HasValue(targ, caller) then
            for i, ply in ipairs(targ) do
                if ply == caller then table.remove(targ, i) end
            end
        end

        if #targ == 1 then
            if #args > 0 then
                nadmin.SilentNotify = true
                local mc = nadmin:GetNameColor(caller) or nadmin.colors.blue
                local tc = nadmin:GetNameColor(targ[1])
                nadmin:Notify(mc, caller:Nick(), nadmin.colors.white, " has imitated ", tc, targ[1]:Nick(), nadmin.colors.white, ".")

                net.Start("nadmin_imitate")
                    net.WriteEntity(targ[1])
                    net.WriteString(table.concat(args, " "))
                net.Broadcast()
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
            end
        elseif #targ > 1 then
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
    end
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    },
    {
        type = "string",
        text = "Message"
    }
}

local say = Material("icon16/user_comment.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(say)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(COMMAND)

if SERVER then 
    util.AddNetworkString("nadmin_imitate")
else 
    net.Receive("nadmin_imitate", function()
        local ply = net.ReadEntity()
        local msg = net.ReadString()

        -- ply, msg, isTeam, isDead
        hook.Run("OnPlayerChat", ply, msg, false, not ply:Alive())
    end)
end