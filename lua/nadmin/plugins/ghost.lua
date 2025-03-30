local COMMAND = {}
COMMAND.title = "Ghost"
COMMAND.description = "Makes a player completely invisible."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Saturday, April 25, 2020 @ 2:54 PM"
COMMAND.category = "Fun"
COMMAND.call = "ghost"
COMMAND.usage = "<player> [1|0]"
COMMAND.defaultAccess = nadmin.access.admin
COMMAND.server = function(caller, args)
    local targs = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
    if #targs > 0 then
        local ghosted = {}
        local unghosted = {}
        local en = nil
        if tonumber(args[2]) then en = nadmin:IntToBool(tonumber(args[2])) end
        for i, ply in ipairs(targs) do
            if isbool(en) then
                if en then
                    table.insert(ghosted, ply)
                    ply.n_Ghosted = true
                    ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    ply:SetColor(nadmin:AlphaColor(ply:GetColor(), 0))

                    local weps = ply:GetWeapons()
                    for i, w in ipairs(weps) do
                        w:SetRenderMode(RENDERMODE_TRANSCOLOR)
                        w:SetColor(nadmin:AlphaColor(w:GetColor(), 0))
                    end
                else
                    table.insert(unghosted, ply)
                    ply.n_Ghosted = nil
                    ply:SetRenderMode(RENDERMODE_NORMAL)
                    ply:SetColor(nadmin:AlphaColor(ply:GetColor(), 255))

                    local weps = ply:GetWeapons()
                    for i, w in ipairs(weps) do
                        w:SetRenderMode(RENDERMODE_NORMAL)
                        w:SetColor(nadmin:AlphaColor(w:GetColor(), 255))
                    end
                end
            else
                if ply.n_Ghosted then
                    table.insert(unghosted, ply)
                    ply.n_Ghosted = nil
                    ply:SetRenderMode(RENDERMODE_NORMAL)
                    ply:SetColor(nadmin:AlphaColor(ply:GetColor(), 255))

                    local weps = ply:GetWeapons()
                    for i, w in ipairs(weps) do
                        w:SetRenderMode(RENDERMODE_NORMAL)
                        w:SetColor(nadmin:AlphaColor(w:GetColor(), 255))
                    end
                else
                    table.insert(ghosted, ply)
                    ply.n_Ghosted = true
                    ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
                    ply:SetColor(nadmin:AlphaColor(ply:GetColor(), 0))

                    local weps = ply:GetWeapons()
                    for i, w in ipairs(weps) do
                        w:SetRenderMode(RENDERMODE_TRANSCOLOR)
                        w:SetColor(nadmin:AlphaColor(w:GetColor(), 0))
                    end
                end
            end
        end

        local myCol = nadmin:GetNameColor(caller) or nadmin.colors.blue
        if #ghosted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has ghosted "}
            table.Add(msg, nadmin:FormatPlayerList(ghosted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))

        end
        if #unghosted > 0 then
            local msg = {myCol, caller:Nick(), nadmin.colors.white, " has unghosted "}
            table.Add(msg, nadmin:FormatPlayerList(unghosted, "and"))
            table.Add(msg, {nadmin.colors.white, "."})
            nadmin:Notify(unpack(msg))
        end
    else
        nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
    end
end

hook.Add("Think", "nadmin_keep_ghosted", function()
    for i, ply in ipairs(player.GetAll()) do
        if ply.n_Ghosted then
            local pc = ply:GetColor()
            if pc.a ~= 0 then
                ply:SetColor(nadmin:AlphaColor(pc, 0))
            end
            if ply:GetRenderMode() ~= RENDERMODE_TRANSCOLOR then
                ply:SetRenderMode(RENDERMODE_TRANSCOLOR)
            end

            local wep = ply:GetActiveWeapon()
            if IsValid(wep) then
                local pc = wep:GetColor()
                if pc.a ~= 0 then
                    wep:SetColor(nadmin:AlphaColor(pc, 0))
                end
                if wep:GetRenderMode() ~= RENDERMODE_TRANSCOLOR then
                    wep:SetRenderMode(RENDERMODE_TRANSCOLOR)
                end
            end
        end
    end
end)

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW
    },
    {
        type = "checkbox",
        text = "Godded"
    }
}

local user = Material("icon16/user.png")
local ungod = Material("icon16/shield.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(user)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText("Toggle Ghosted")
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " ghost " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
