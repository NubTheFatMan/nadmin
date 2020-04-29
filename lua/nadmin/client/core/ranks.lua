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
