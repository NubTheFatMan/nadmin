local COMMAND = {}
COMMAND.title = "Set Display Rank"
COMMAND.description = "Set the display rank of a player without changing their permissions. Resets upon leaving."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Feb. 5 2024 @ 6:52 PM PST"
COMMAND.category = "Player Management"
COMMAND.call = "displayrank"
COMMAND.usage = "<player> {rank}"
COMMAND.defaultAccess = nadmin.access.superadmin

if SERVER then 
    util.AddNetworkString("nadmin_client_rank")
else
    net.Receive("nadmin_client_rank", function()
        local realRank = net.ReadString()
        if realRank == "" then 
            nadmin.realRank = nil
        else 
            nadmin.realRank = realRank
        end
    end)
end

COMMAND.server = function(caller, args)
    local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targ == 1 then
        if args[2] then
            local rank = nadmin:FindRank(args[2])
            if istable(rank) then
                if IsValid(caller) and rank.immunity >= caller:GetRank().immunity then
                    nadmin:Notify(caller, nadmin.colors.red, "This rank is greater than or equal to yours. It must be lower")
                    return
                end
                targ[1]:SetNWString("nadmin_rank", rank.id)

                net.Start("nadmin_client_rank")
                    net.WriteString(nadmin.userdata[targ[1]:SteamID()].rank)
                net.Send(targ[1])

                local myCol = nadmin:GetNameColor(caller, true) or nadmin.colors.blue
                local tCol = nadmin:GetNameColor(targ[1]) or nadmin.colors.red

                nadmin.SilentNotify = true
                nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " set the display rank of ", tCol, targ[1]:Nick(), nadmin.colors.white, " to ", tCol, rank.title, nadmin.colors.white, ".")

                -- nadmin:Notify(myCol, caller:Nick(), nadmin.colors.white, " has granted ", tCol, targ[1]:Nick(), nadmin.colors.white, " the rank ", tCol, rank.title, nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "Invalid rank. Are you sure you typed it correctly?")
            end
        else
            nadmin:Notify(caller, nadmin.colors.red, "You are missing the rank argument.")
        end
    elseif #targ > 1 then
        nadmin:Notify(caller, nadmin.colors.red, "Did you mean ", nadmin.colors.white, nadmin:FormatPlayerList(targ), nadmin.colors.red, "?")
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
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
        text = "Display Rank",
        options = "ranks_below",
        type = "dropdown"
    }
}

local edit = Material("icon16/user_edit.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(edit)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = COMMAND.advUsage
    nadmin.scoreboard.call = COMMAND.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(COMMAND)