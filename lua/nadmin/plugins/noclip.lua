local cmd = {}
cmd.title = "Noclip"
cmd.description = "Toggle noclip of a player."
cmd.author = "Nub"
cmd.timeCreated = "Oct. 26 2019 @ 9:42 PM CST"
cmd.category = "Utility"
cmd.call = "noclip"
cmd.usage = "<player> [1|0]"
cmd.defaultAccess = nadmin.access.admin
cmd.server = function(caller, args)
    local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue

    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local granted = {}
        local revoked = {}
        for i, ply in ipairs(targs) do
            if tonumber(args[2]) then
                local en = nadmin:IntToBool(tonumber(args[2]))
                if en then
                    table.insert(granted, ply)
                    ply:SetMoveType(MOVETYPE_NOCLIP)
                else
                    table.insert(revoked, ply)
                    ply:SetMoveType(MOVETYPE_WALK)
                end
            else
                if ply:GetMoveType() == MOVETYPE_NOCLIP then
                    table.insert(revoked, ply)
                    ply:SetMoveType(MOVETYPE_WALK)
                else
                    table.insert(granted, ply)
                    ply:SetMoveType(MOVETYPE_NOCLIP)
                end
            end
        end

        -- if #granted > 0 then
        --     local msg = {myCol, caller:Nick(), nadmin.colors.white, " has noclipped "}
        --     table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        --     table.Add(msg, {nadmin.colors.white, "."})
        --     nadmin:Notify(unpack(msg))
        -- end
        -- if #revoked > 0 then
        --     local msg = {myCol, caller:Nick(), nadmin.colors.white, " has removed noclip from "}
        --     table.Add(msg, nadmin:FormatPlayerList(targs, "and"))
        --     table.Add(msg, {nadmin.colors.white, "."})
        --     nadmin:Notify(unpack(msg))
        -- end
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
        type = "checkbox",
        text = "Noclipped"
    }
}

local unnoclip = Material("icon16/status_online.png")
local noclip = Material("icon16/status_offline.png")

cmd.scoreboard = {}
cmd.scoreboard.targetMode = nadmin.MODE_BELOW
cmd.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(nadmin:Ternary(ply:GetMoveType() == MOVETYPE_WALK, noclip, unnoclip))
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText(nadmin:Ternary(ply:GetMoveType() == MOVETYPE_WALK, "Noclip", "Un-Noclip"))
end
cmd.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " noclip " .. ply:SteamID())
end


nadmin:RegisterCommand(cmd)
