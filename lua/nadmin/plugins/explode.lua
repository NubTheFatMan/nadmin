local cmd = {}
cmd.title = "Explode"
cmd.description = "Explode a player."
cmd.author = "Nub"
cmd.timeCreated = "Wednesday, May 20 2020 @ 10:47 PM CST"
cmd.category = "Fun"
cmd.call = "explode"
cmd.usage = "<player>"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        for i, targ in ipairs(targs) do
            local bomb = ents.Create("env_explosion")
            bomb:SetPos(targ:GetPos())
            bomb:SetOwner(targ)
            bomb:Spawn()
            bomb:SetKeyValue("iMagnitude", "1")
            bomb:Fire("Explode", 0, 0)
            bomb:EmitSound("ambient/explosions/explode_4.wav", 500, 500)
            if targ:Alive() then targ:Kill() targ:SetFrags(targ:Frags() + 1) end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

        local msg = {myCol, caller:Nick(), nadmin.colors.white, " has exploded "}
        table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        table.Add(msg, {nadmin.colors.white, "."})
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
    }
}

local del = Material("icon16/bomb.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(del)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " explode " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
