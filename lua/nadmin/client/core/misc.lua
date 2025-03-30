-- Short files have been combined into this one to deflate the high file count


-- Formerly commands.lua
net.Receive("nadmin_update_cmds", function()
    RunString(net.ReadString())
end)


-- Formerly fonts.lua
nadmin.createdFonts = nadmin.createdFonts or false 
if not nadmin.createdFonts then 
    nadmin.createdFonts = true
    surface.CreateFont("nadmin_derma_xs", {
        size = 12
    })
    surface.CreateFont("nadmin_derma_small", {
        size = 15
    })
    surface.CreateFont("nadmin_derma_small_b", {
        size = 15,
        weight = 800
    })
    surface.CreateFont("nadmin_derma_small_i", {
        size = 15,
        italic = true
    })
    surface.CreateFont("nadmin_derma_small_bi", {
        size = 15,
        weight = 800,
        italic = true
    })
    surface.CreateFont("nadmin_derma", {
        size = 20
    })
    surface.CreateFont("nadmin_derma_b", {
        size = 20,
        weight = 800
    })
    surface.CreateFont("nadmin_derma_bigger", {
        size = 24
    })
    surface.CreateFont("nadmin_derma_large", {
        size = 32
    })
    surface.CreateFont("nadmin_derma_large_b", {
        size = 32,
        weight = 800
    })
    surface.CreateFont("nadmin_derma_xl", {
        size = 40,
        weight = 800
    })
end


-- Formerly ranks.lua
net.Receive("nadmin_send_updated_ranks", function()
    nadmin.ranks = {}
    nadmin.ranks = net.ReadTable()
end)

function nadmin:RegisterPermList(tbl)
    local list = tbl
    if not istable(list) then return end

    list.title = nadmin:Ternary(isstring(tbl.title), tbl.title, "Undefined")

    nadmin.list[list.title] = table.Copy(list)
end