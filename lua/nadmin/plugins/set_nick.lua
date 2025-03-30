local cmd = {}
cmd.title = "Set Nick"
cmd.description = "Set the display name of a player."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 26 2019 @ 10:16 PM CST"
cmd.category = "Player Management"
cmd.call = "nick"
cmd.usage = "<player> {nick}"
cmd.defaultAccess = nadmin.access.superadmin
cmd.server = function(caller, args)
    if #args > 0 then
        local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
        if #targ == 1 then
            table.remove(args, 1)

            local newNick = string.Trim(table.concat(args, " "))
            if #newNick > 0 then
                local oldNick = targ[1]:Nick()
                targ[1]:SetNick(newNick)

                local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
                local tCol = targ[1]:GetRank().color

                nadmin:Notify(myCol, (targ[1] == caller and oldNick or caller:Nick()), nadmin.colors.white, " has set the name of ", tCol, oldNick, nadmin.colors.white, " to ", tCol, newNick, nadmin.colors.white, ".")
            else
                nadmin:Notify(caller, nadmin.colors.red, "New nickname can't be blank.")
            end
        elseif #targ > 1 then
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, "You must specify at least one argument.")
    end
end

local card = Material("icon16/vcard.png")

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        text = "New Nickname",
        type = "string"
    }
}

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(card)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    nadmin.scoreboard.cmd = cmd.advUsage
    nadmin.scoreboard.call = cmd.call
    nadmin.scoreboard:Hide()
    nadmin.scoreboard:Show()
end

nadmin:RegisterCommand(cmd)
