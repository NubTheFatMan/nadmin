local cmd = {}
cmd.title = "Slap"
cmd.description = "Slap a player."
cmd.author = "Nub"
cmd.timeCreated = "Friday, May 22 2020 @ 11:03 PM CST"
cmd.category = "Fun"
cmd.call = "slap"
cmd.usage = "<player> [damage=0]"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local dmg = tonumber(args[2] or "")
        if not isnumber(dmg) then dmg = 0 end

        for i, targ in ipairs(targs) do
            targ:SetHealth(targ:Health() - dmg)
            targ:ViewPunch(Angle(-10, 0, 0))
            if targ:Health() < 0 then
                targ:Kill()
                targ:SetFrags(targ:Frags() + 1) -- Kill will subtract from kills, we don't want that
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has slapped "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, " with ", nadmin.colors.red, tostring(dmg), nadmin.colors.white, " damage."})
        nadmin:Notify(unpack(msg))
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

cmd.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "number",
        text = "Damage"
    }
}

local del = Material("icon16/brick_delete.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.canTargetSelf = false
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " slap " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
