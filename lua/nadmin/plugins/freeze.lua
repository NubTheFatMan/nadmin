local COMMAND = {}
COMMAND.title = "Freeze"
COMMAND.description = "(Un)Freeze a player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, April 17, 2020 @ 8:36 PM"
COMMAND.category = "Player Management"
COMMAND.call = "freeze"
COMMAND.usage = "<player> [1|0]"
COMMAND.defaultAccess = nadmin.access.admin
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if table.HasValue(targs, caller) then -- Remove caller from table
        for i, t in ipairs(targs) do
            if t == caller then
                table.remove(targs, i)
                break
            end
        end
    end

    if #targs > 0 then
        local froze = {}
        local unfroze = {}
        for i, ply in ipairs(targs) do
            if tonumber(args[2]) then
                local en = nadmin:IntToBool(tonumber(args[2]))
                if en then
                    table.insert(froze, ply)
                    ply:Lock()
                else
                    table.insert(unfroze, ply)
                    ply:UnLock()
                end
            else
                if ply:IsFrozen() then
                    table.insert(unfroze, ply)
                    ply:UnLock()
                else
                    table.insert(froze, ply)
                    ply:Lock()
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #froze > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has frozen "}
            table.Add(msg, nadmin:FormatPlayerList(froze, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
        if #unfroze > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has unfrozen "}
            table.Add(msg, nadmin:FormatPlayerList(unfroze, "and"))
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
        text = "Frozen"
    }
}

local freeze = Material("icon16/lock_open.png")
local unfreeze = Material("icon16/lock.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nadmin:Ternary(ply:IsFrozen(), unfreeze, freeze))
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText(ply:IsFrozen() and "Unfreeze" or "Freeze")
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " freeze " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
