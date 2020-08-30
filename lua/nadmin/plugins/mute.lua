local COMMAND = {}
COMMAND.title = "Mute"
COMMAND.description = "Mute a player in text chat."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Thursday, April 30, 2020 @ 10:37 PM CST"
COMMAND.category = "Utility"
COMMAND.call = "mute"
COMMAND.usage = "<player> [1|0]"
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if table.HasValue(targs, caller) then
        for i, ply in ipairs(targs) do
            if ply == caller then table.remove(targs, i) end
        end
    end

    if #targs > 0 then
        local muted = {}
        local unmuted = {}
        for i, ply in ipairs(targs) do
            if tonumber(args[2]) then
                local en = nadmin:IntToBool(tonumber(args[2]))
                if en then
                    table.insert(muted, ply)
                    ply.n_Muted = true
                else
                    table.insert(unmuted, ply)
                    ply.n_Muted = nil
                end
            else
                if ply.n_Muted then
                    table.insert(unmuted, ply)
                    ply.n_Muted = nil
                else
                    table.insert(muted, ply)
                    ply.n_Muted = true
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #muted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has muted "}
            table.Add(msg, nadmin:FormatPlayerList(muted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

        end
        if #unmuted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has unmuted "}
            table.Add(msg, nadmin:FormatPlayerList(unmuted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
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
        type = "checkbox",
        text = "Muted"
    }
}

local say = Material("icon16/comment_delete.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(say)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " mute " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
