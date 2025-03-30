local COMMAND = {}
COMMAND.title = "Blind"
COMMAND.description = "Blind a player."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, May 2, 2020 @ 8:52 PM"
COMMAND.category = "Fun"
COMMAND.call = "blind"
COMMAND.usage = "<player> [1|0]"
COMMAND.defaultAccess = nadmin.access.admin
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local blinded = {}
        local unblinded = {}

        local en = tonumber(args[2])
        for i, ply in ipairs(targs) do
            if isnumber(en) then
                local en = nadmin:IntToBool(en)
                if en then
                    table.insert(blinded, ply)
                    ply:SetNWBool("nadmin_blinded", true)
                else
                    table.insert(unblinded, ply)
                    ply:SetNWBool("nadmin_blinded", false)
                end
            else
                if ply:GetNWBool("nadmin_blinded") then
                    table.insert(unblinded, ply)
                    ply:SetNWBool("nadmin_blinded", false)
                else
                    table.insert(blinded, ply)
                    ply:SetNWBool("nadmin_blinded", true)
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #blinded > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has blinded "}
            table.Add(msg, nadmin:FormatPlayerList(blinded, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

        end
        if #unblinded > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has unblinded "}
            table.Add(msg, nadmin:FormatPlayerList(unblinded, "and"))
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
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "checkbox",
        text = "blinded"
    }
}

local con = Material("icon16/contrast.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(con)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText(nadmin:Ternary(ply:GetNWBool("nadmin_blinded"), "Unblind", "Blind"))
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " blind " .. ply:SteamID())
end

if CLIENT then
    hook.Add("HUDPaint", "nadmin_blind_paint", function()
        if LocalPlayer():GetNWBool("nadmin_blinded") then
            surface.SetDrawColor(0, 0, 0)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end
    end)
end

nadmin:RegisterCommand(COMMAND)
