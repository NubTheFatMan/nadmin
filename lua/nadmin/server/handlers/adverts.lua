nadmin.config.adverts = nadmin.config.adverts or {}
local adverts = nadmin.config.adverts

util.AddNetworkString("nadmin_add_advert")
util.AddNetworkString("nadmin_req_adverts")
util.AddNetworkString("nadmin_resend_advert")

net.Receive("nadmin_resend_advert", function(len, ply)
    if not ply:HasPerm("manage_server_settings") then
        nadmin:Notify(ply, nadmin.colors.red, "You aren't allowed to manage server settings.")
        return
    end

    local ind = net.ReadInt(32)

    if istable(adverts[ind]) then
        adverts[ind].lastRan = 0
    end
end)

net.Receive("nadmin_add_advert", function(len, ply)
    local msg = net.ReadString()
    local rep = net.ReadInt(32)
    local col = net.ReadTable()
    local ind = net.ReadInt(32)

    if not ply:HasPerm("manage_server_settings") then
        nadmin:Notify(ply, nadmin.colors.red, "You aren't allowed to manage server settings.")
        return
    end

    if msg == "" then
        if istable(adverts[ind]) then
            table.remove(adverts, ind)
        end
    else
        if istable(adverts[ind]) then
            adverts[ind] = {
                text = msg,
                repeatAfter = rep,
                color = Color(col[1], col[2], col[3]),
                lastRan = adverts[ind].lastRan
            }
        else
            table.insert(adverts, {
                text = msg,
                repeatAfter = rep,
                color = Color(col[1], col[2], col[3]),
                lastRan = 0
            })
        end
    end

    net.Start("nadmin_req_adverts")
        net.WriteTable(adverts)
    net.Send(ply)

    file.Write("nadmin/config/adverts.txt", util.TableToJSON(adverts))
end)

local loaded = file.Read("nadmin/config/adverts.txt", "DATA")
if isstring(loaded) then
    loaded = util.JSONToTable(loaded)
    table.Merge(adverts, loaded)
    for i = 1, #adverts do
        local adv = adverts[i]
        if not IsColor(adv.color) and istable(adv.color) then
            local col = adv.color
            adv.color = Color(col.r, col.g, col.b)
        end
    end
end

net.Receive("nadmin_req_adverts", function(len, ply)
    net.Start("nadmin_req_adverts")
        net.WriteTable(adverts)
    net.Send(ply)
end)

hook.Add("Think", "nadmin_adverts", function()
    local now = os.time()

    for i = 1, #adverts do
        local adv = adverts[i]

        -- Validate the advert is setup correctly
        if not isstring(adv.text) then continue end
        if not isnumber(adv.repeatAfter) then continue end
        if not IsColor(adv.color) then continue end
        if not isnumber(adv.lastRan) then adv.lastRan = 0 end

        if now - adv.lastRan >= (adv.repeatAfter * nadmin.time.m) then
            nadmin:Notify(adv.color, adv.text)
            adv.lastRan = now
        end
    end
end)
