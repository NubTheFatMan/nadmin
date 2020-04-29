local COMMAND = {}
COMMAND.title = "Spectate"
COMMAND.description = "Spectate a player. Press your crouch key to switch between 3rd and 1rst person."
COMMAND.author = "Nub"
COMMAND.timeCreated = "Friday, April 17, 2020 @ 11:04 PM"
COMMAND.category = "Utility"
COMMAND.call = "spectate"
COMMAND.usage = "<player>"
COMMAND.server = function(caller, args)
    if #args > 0 then
        local targ = nadmin:FindPlayer(args[1], caller, nadmin.MODE_BELOW)
        if #targ == 1 then
            if targ[1] ~= caller then
                if caller:GetNWBool("nadmin_spectating") and caller:GetObserverTarget() == targ[1] then
                    caller:SetNWBool("nadmin_spectating", false)
                    caller:Spectate(OBS_MODE_NONE)
                    caller:UnSpectate()
                    caller:SetMoveType(MOVETYPE_WALK)
                    caller:Spawn()
                    timer.Simple(0.05, function()
                        if isvector(caller.nadmin_specStart) then
                            caller:SetPos(caller.nadmin_specStart)
                            caller.nadmin_specStart = nil
                        end
                    end)

                    return
                end

                if not targ[1]:GetNWBool("nadmin_spectating") then
                    if not caller:GetNWBool("nadmin_spectating") then
                        caller.nadmin_specStart = caller:GetPos()
                    end

                    caller:SetNWBool("nadmin_spectating", true)
                    caller:Spectate(OBS_MODE_CHASE)
                    caller:SpectateEntity(targ[1])
                    caller:SetMoveType(MOVETYPE_OBSERVER)
                    caller:StripWeapons()
                else
                    nadmin:Notify(caller, nadmin.colors.red, targ[1]:Nick() .. " is spectating " .. targ[1]:GetObserverTarget() .. ".")
                end
            else
                nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargSelf)
            end
        elseif #targ > 1 then
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.TooManyTargs)
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.noTargLess)
        end
    else
        if caller:GetNWBool("nadmin_spectating") then
            caller:SetNWBool("nadmin_spectating", false)
            caller:Spectate(OBS_MODE_NONE)
            caller:UnSpectate()
            caller:SetMoveType(MOVETYPE_WALK)
            caller:Spawn()
            timer.Simple(0.05, function()
                if isvector(caller.nadmin_specStart) then
                    caller:SetPos(caller.nadmin_specStart)
                    caller.nadmin_specStart = nil
                end
            end)
        else
            nadmin:Notify(caller, nadmin.colors.red, nadmin.errors.notEnoughArgs)
        end
    end
end

if SERVER then
    util.AddNetworkString("nadmin_switch_spec")
    hook.Remove("Think", "nadmin_switch_spectate_cam")
    hook.Add("Think", "nadmin_stop_spectate", function()
        for i, ply in ipairs(player.GetAll()) do
            if ply:GetNWBool("nadmin_spectating") then
                if not IsValid(ply:GetObserverTarget()) then
                    ply:SetNWBool("nadmin_spectating", false)
                    ply:Spectate(OBS_MODE_NONE)
                    ply:UnSpectate()
                    ply:SetMoveType(MOVETYPE_WALK)
                    ply:Spawn()
                    timer.Simple(0.05, function()
                        if isvector(ply.nadmin_specStart) then
                            ply:SetPos(ply.nadmin_specStart)
                            ply.nadmin_specStart = nil
                        end
                    end)

                    continue
                end
            end
        end
    end)

    net.Receive("nadmin_switch_spec", function(len, ply)
        if ply:GetNWBool("nadmin_spectating") then
            if ply:GetObserverMode() == OBS_MODE_CHASE then
                ply:SetObserverMode(OBS_MODE_IN_EYE)
            else
                ply:SetObserverMode(OBS_MODE_CHASE)
            end
        end
    end)
else
    local ctrl = false
    local toggle = KEY_LCONTROL
    hook.Add("Think", "nadmin_switch_spectate_cam", function()
        if LocalPlayer():GetNWBool("nadmin_spectating") then
            if input.IsKeyDown(toggle) and not ctrl then
                ctrl = true
                net.Start("nadmin_switch_spec") net.SendToServer()
            elseif not input.IsKeyDown(toggle) and ctrl then
                ctrl = false
            end
        end
    end)
end

COMMAND.advUsage = {
    {
        type = "player",
        text = "Player",
        targetMode = nadmin.MODE_BELOW,
        canTargetSelf = false
    }
}

local cam = Material("icon16/camera.png")

COMMAND.scoreboard = {}
COMMAND.scoreboard.targetMode = nadmin.MODE_BELOW
COMMAND.scoreboard.canTargetSelf = false
COMMAND.scoreboard.iconRender = function(panel, w, h, ply)
    surface.SetDrawColor(255, 255, 255)
    surface.SetMaterial(cam)
    surface.DrawTexturedRect(w/2 - 10, 4, 20, 20)

    panel:SetText("Spectate")
end
COMMAND.scoreboard.OnClick = function(ply, rmb)
    LocalPlayer():ConCommand("nadmin" .. nadmin:Ternary(rmb, "s", "") .. " spectate " .. ply:SteamID())
end

nadmin:RegisterCommand(COMMAND)
