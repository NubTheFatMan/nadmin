nadmin.menu.tabs = nadmin.menu.tabs or {}
function nadmin.menu:RegisterTab(tbl)
    local tab = table.Copy(tbl)
    tab.title = nadmin:Ternary(isstring(tbl.title), tbl.title, "Undefined")
    tab.id = nadmin:Ternary(isstring(tbl.id), tbl.id, string.lower(string.Replace(tab.title, " ", "_")))
    tab.sort = nadmin:Ternary(isnumber(tbl.sort), tbl.sort, 0)
    tab.forcedPriv = nadmin:Ternary(isbool(tbl.forcedPriv), tbl.forcedPriv, false)
    tab.content = tbl.content
    for i, tb in ipairs(nadmin.menu.tabs) do
        if tb.id == tab.id then table.remove(nadmin.menu.tabs, i) end
    end
    tab.forcedPriv = nadmin:Ternary(isbool(tbl.forcedPriv), tbl.forcedPriv, false)
    if tab.forcedPriv then
        nadmin.forcedPrivs[tab.id] = true
    end
    table.insert(nadmin.menu.tabs, table.Copy(tab))
    return tab
end

function nadmin.menu:Open(tab, data)
    if IsValid(nadmin.menu.panel) then nadmin.menu.panel:Remove() end 

    nadmin.menu.panel = vgui.Create("NadminFrame")
    local panel = nadmin.menu.panel
    panel:SetSize(ScrW() * 0.66, ScrH() * 0.66)
    panel:Center()
    panel:SetSizable(false)
    panel:SetDraggable(false)
    panel:SetTitle("Nadmin [" .. nadmin.version .. "]")
    panel:MakePopup()

    local tabMenu = vgui.Create("NadminTabMenu", panel)
    tabMenu:Dock(FILL)
    tabMenu:DockMargin(4, 4, 4, 4)

    local canSee = {}
    for i, tab in ipairs(nadmin.menu.tabs) do
        if LocalPlayer():HasPerm(tab.id) then
            table.insert(canSee, tab)
        end
    end
    table.sort(canSee, function(a, b) return a.sort < b.sort end)
    for i, tab in ipairs(canSee) do 
        tabMenu:AddTab(tab.title, tab.content, i == 1, data)
    end
end

function nadmin.menu:Close()
    if IsValid(nadmin.menu.panel) then nadmin.menu.panel:Remove() end
end
