nadmin.motd = nadmin.motd or {}

function nadmin.motd:Open(data)
    if IsValid(nadmin.motd.panel) then nadmin.motd.panel:Remove() end

    nadmin.motd.panel = nadmin.vgui:DFrame(nil, {ScrW() * 0.9, ScrH() * 0.9})
    local motd = nadmin.motd.panel

    motd:Center()
    motd:SetTitle("Message Of The Day")
    motd:ShowCloseButton(false)
    motd:MakePopup()

    motd.close = nadmin.vgui:DButton(nil, {motd:GetWide() - 8, 48}, motd)
    motd.close:Dock(BOTTOM)
    motd.close:DockMargin(4, 0, 4, 4)
    motd.close:SetText("Close")

    function motd.close:DoClick()
        motd:Remove()
    end

    if isstring(data) then
        motd.html = vgui.Create("DHTML", motd)
        motd.html:Dock(FILL)
        motd.html:DockMargin(4, 0, 4, 4)
        if string.StartWith(data, "http") then
            motd.html:OpenURL(data)
            local open = nadmin.vgui:DButton(nil, {motd:GetWide() - 8, 48}, motd)
            open:Dock(BOTTOM)
            open:DockMargin(4, 0, 4, 4)
            open:SetText("MOTD page not loading? Click here!")
            function open:DoClick()
                gui.OpenURL(data)
            end
        else
            motd.html:SetHTML(data)
        end

        function motd.html:Paint(w, h)
            local tc = nadmin:TextColor(nadmin.colors.gui.theme)

            draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

            draw.Circle(w/2, h/2, 16, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 50))
            draw.Circle(w/2, h/2, 16, 360, 270, (SysTime() % 360) * 180, tc)
            draw.Circle(w/2, h/2, 14, 360, 360, 0, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
        end

        function motd.html:OnFinishLoadingDocument()
            function self:Paint(w, h)
                draw.RoundedBox(0, 0, 0, w, h, nadmin:DarkenColor(nadmin.colors.gui.theme, 25))
            end
        end
    elseif istable(data) then
        -- Time to generate some HTML :^)
        local bg = data.title.bgcol
        local tx = data.title.txcol

        local bgOv = nadmin:DarkenColor(data.title.bgcol, 25)
        local bgBtn = nadmin:BrightenColor(data.title.bgcol, 25)
        local bgBtnH = nadmin:BrightenColor(data.title.bgcol, 50)

        local txOv = nadmin:DarkenColor(data.title.txcol, 25)

        local style = [[
            body {
                position: absolute;
                top: 0;
                left: 0;
                right: 0;
                bottom: 0;
                padding: 0;
                margin: 0;
                background: rgb(]] .. bgOv.r .. "," .. bgOv.g .. "," .. bgOv.b ..  [[);
                font-family: 'Arial', sans-serif;
                color: rgb(]] .. txOv.r .. "," .. txOv.g .. "," .. txOv.b .. [[);
            }
            h1 {
                color: rgb(]] .. tx.r .. "," .. tx.g .. "," .. tx.b .. [[);
            }
            
            #content {
                width: 1024px;
                max-width: 90%;
                min-width: 486px;
                margin: 0;
                margin-left: auto;
                margin-right: auto;
                padding-bottom: 18px;
            }
            
            .last {
                border-radius: 0 0 16px 0;
            }
            
            .title {
                border-radius: 16px 0 0 0;
                border-bottom: solid 6px rgb(]] .. tx.r .. "," .. tx.g .. "," .. tx.b .. [[);
                font-weight: bolder;
            }
            .title, .info {
                text-align: center;
                background-color: rgb(]] .. bg.r .. "," .. bg.g .. "," .. bg.b .. [[);
                padding: 16px;
                margin-top: 18px;
            }
            .title h1, h4, p {
                margin: 0;
                padding: 0;
            }
            .title img {
                width: 256px;
                height: 256px;
            }
            
            .info h1, h3 {
                margin: 0;
                padding: 0;
            }
            .info p, ul, ol {
                text-align: left;
                font-size: 1em;
                padding: 0;
                padding-left: 16px;
                padding-right: 16px;
                margin: 0;
            }
            .info a {
                text-decoration: underline;
            }
            
            a {
                background: rgb(]] .. bgBtn.r .. "," .. bgBtn.g .. "," .. bgBtn.b .. [[);
                padding: 2px;
                border-radius: 4px;
                color: white;
                text-decoration: none;
                transition: .3s;
            }
            a:hover {
                background: rgb(]] .. bgBtnH.r .. "," .. bgBtnH.g .. "," .. bgBtnH.b .. [[);
                transition: .3s;
            }

            ::-webkit-scrollbar {
                width: 8px;
            }
            
            ::-webkit-scrollbar-track {
                background: #424242;
            }
            
            ::-webkit-scrollbar-thumb {
                background: #757575;
                transition: .3s;
            }
            
            ::-webkit-scrollbar-thumb:hover {
                background: #868686;
                transition: .3s;
            }
        ]]

        local html = [[<div id="content">
        <div class="title">
            <h1>]] .. string.Replace(data.title.text, "%HostName%", GetHostName()) .. [[</h1>
            <h4>]] .. data.title.subtext .. [[</h4>
        </div>]]

        for i, content in ipairs(data.contents) do 
            local section = '<div class="info'
            if i == #data.contents then 
                section = section .. " last"
            end
            section = section .. '"><h1>' .. content.title .. '</h1>'

            local tag = 'p'
            if content.type == "ulist" or content.type == "members" then tag = 'ul'
            elseif content.type == "olist" then tag = 'ol' end
            
            section = section .. '<' .. tag .. '>'
            local split = string.Explode("\n", content.value)
            if tag == 'p' then 
                section = section .. table.concat(split, '<br>')
            else 
                section = section .. '<li>' .. table.concat(split, '</li><li>') .. '</li>'
            end
            section = section .. '</' .. tag .. '>'


            html = html .. section .. '</div>'
        end

        local temp = [[<div class="info" id="information">
            <h1>Information</h1>
            <ul>
                <li>A grand REOPENING of Apocalypse Build And Kill.</li>
                <li>Want to build? Type <strong style="color: #0096ff;">!build</strong>. It'll give you godmode and won't let you hurt players in PVP.<br>Want to PvP instead? Type <strong style="color: #0096ff;">!pvp</strong>. To prevent cheating, you will be respawned.</li>
                <li>Lagging? Type <strong style="color: #0096ff;">!fpsboost</strong> to not only increase your framerate, but also lower your ping to the server!</li>
                <li>The administration mod used on this server is custom made by Nub. It's heavily inspired by Evolve and a little bit of ULX, however is quite different with an easy to use interface.</li>
                <li>Want to join the Discord? Click <a href="https://discord.gg/jgWx4m4pKH">here</a>.</li>
                <li>Here are the <a href="https://steamcommunity.com/sharedfiles/filedetails/?id=2550108414">addons</a>. You must subscribe to them all if you don't want any errors.</li>
            </ul>
        </div>

        <div class="info" id="information">
            <h1>Reporting Rulebreakers</h1>
            <ul>
                <li>Contact an available admin on the server.</li>
                <li>Use @ before typing a chat message to send it to all online admins.</li>
                <li>If no admin is available, note the player's name and the current time, then let an admin know as soon as they're available.</li>
            </ul>
        </div>
        
        <div class="info" id="rules">
            <h1>Rules</h1>
            <p>
                <ol>
                    <li>
                        <strong>Use common sense.</strong>
                        <ul>
                            <li>There are far too many rules to list them all.</li>
                            <li>This includes not trying to find loopholes in the rules.</li>
                        </ul>
                    </li>
                    <li>
                        Listen to staff.
                        <ul>
                            <li>Staff have the final verdict. You must comply with them; if you feel what they are asking is wrong, report it to a higher ranking staff member.</li>
                        </ul>
                    </li>
                    <li>
                        Don't prop minge.
                        <ul>
                            <li>Prop minge includes, but is not limited to: surfing, blocking, pushing.</li>
                        </ul>
                    </li>
                    <li>Don't spam in any way (mic, chat, prop, etc).</li>
                    <li>Don't kill a person if they do not want to pvp.</li>
                    <li>Don't LFS/Simphfys heal, unless you are out of the vehicle.</li>
                    <li>Don't delete your LFS/Simphfys vehicle when it is being engaged.</li>
                    <li>Don't eject from LFS while being engaged.</li>
                    <li>Don't mess with builders if you're in PvP.</li>
                    <li>Don't abuse explosives.</li>
                    <li>If someone is breaking the rules, you must gather sufficient evidence and/or get two people to validate the report.</li>
                    <li>Don't advertise other servers in attempt to take members.</li>
                    <li>
                        Don't attempt to Dos attack or Dox another player.
                        <ul>
                            <li>This includes sharing personal information without consent.</li>
                        </ul>
                    </li>
                    <li>Don't use IDMs (Indestructible Death Machines). The machine must have a reasonable amount of health. Either the machine can be completely destroyed, or if the pilot is killed, it cannot be controlled.</li>
                    <li>Machines must be balanced; an opponent must have a fair chance.</li>
                    <li>Don't be a dick.</li>
                    <li>Don't set your spawn in another's base.</li>
                    <li>
                        Don't lag the server.
                        <ul>
                            <li>If you spawned something you believed starting creating lag, remove it immediately.</li>
                        </ul>
                    </li>
                </ol>
            </p>
        </div>

        <div class="info" id="agreements">
            <h1>Agreements</h1>
            <ul>
                <li>
                    By spawning an Expression 2 or StarFall chip, you agree for it to be inspected by a staff member at their own discretion.
                    <ul>
                        <li>If said staff member in question saves, redistributes, or used your chip without your consent, they are subject to termination from the staff team. They are to delete it after inspection.</li>
                    </ul>
                </li>
                <li>By playing on the server, you have read, understood, and accepted the rules declared above.</li>
            </ul>
        </div>

        <div class="info last" id="ranks">
            <h1>Ranks</h1>
            <ul>
                <li><strong style="color: rgb(180, 0, 0);">Owner</strong> - The server is primarily owned by Jeskov with the assistance of Nub (co-owner).</li>
                <li><strong style="color: rgb(0, 34, 146);">Management</strong> - These people assist the owners in maintaining the server, they have the final say unless the owner says otherwise. They primarily manage the community and do most of the work. Currently the Manager of the server is G4RP1ays.</li>
                <li><strong style="color: rgb(180, 114, 0);">Super Admin</strong> - Admins, but super, they have the final say if no one of higher ranking is on.</li>
                <li><strong style="color: rgb(180, 180, 0);">Admin</strong> - Main rule enforcers of the community. It's their primary focus to make sure everyone is playing fairly.</li>
                <li><strong style="color: rgb(0, 159, 117);">Helper</strong> - These people help the community with any questions about the server or just playing gmod.</li>
                <li><strong style="color: rgb(100, 65, 255);">Respected</strong> - Given to members who have 2 weeks, 3 days, and 12 hours of playtime on the server. Has access to teleportation commands.</li>
                <li><strong style="color: rgb(185, 34, 255);">Known</strong> - Given to members who have 5 days of playtime on the server.</li>
                <li><strong style="color: rgb(226, 226, 0);">Donator</strong> - Given to members who have donated at least $5 to the server.</li>
                <li><strong style="color: rgb(62, 255, 62);">Regular</strong> - Given to members who have spent 4 hours of playtime on the server.</li>
                <li><strong style="color: rgb(0, 92, 86);">Survivor</strong> - Given to members who have played 2 hours on the server and have not been banned.</li>
                <li><strong style="color: rgb(0, 255, 255);">Guest</strong> - The default rank given to newcomers of the server.</li>
            </ul>
        </div>
    </div>]]
        motd.html = vgui.Create("DHTML", motd)
        motd.html:Dock(FILL)
        motd.html:DockMargin(4, 0, 4, 4)
        motd.html:SetHTML("<head><style>" .. style ..  "</style></head><body>" .. html .. "</body>")

        -- local content = nadmin.vgui:DScrollPanel(nil, {motd:GetWide()-8, motd:GetTall()-80}, motd)
        -- content:Dock(FILL)
        -- content:DockMargin(4, 0, 4, 4)
        -- content:SetColor(nadmin:DarkenColor(nadmin.colors.gui.theme, 25))

        -- local title = nadmin.vgui:DPanel(nil, {content:GetWide(), content:GetTall()/8}, content)
        -- title:Dock(TOP)
        -- title:SetColor(data.title.bgcol)
        -- title.oldPaint = title.Paint
        -- function title:Paint(w, h)
        --     self:oldPaint(w, h)
        --     if (data.title.underline) then 
        --         draw.RoundedBox(0, 0, h-3, w, 3, data.title.txcol)
        --     end

        --     draw.SimpleText(string.Replace(data.title.text, "%HostName%", GetHostName()), "nadmin_derma_large_b", w/2, h/2, data.title.txcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM)
        --     draw.SimpleText(data.title.subtext, "nadmin_derma_large", w/2, h/2, data.title.txcol, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP)
        -- end
    end
end

net.Receive("nadmin_open_motd", function()
    local using = net.ReadString()

    if using == "Generator" then
        nadmin.motd:Open(net.ReadTable())
    elseif using == "Local File" or using == "URL" then
        nadmin.motd:Open(net.ReadString())
    end
end)

function nadmin.motd:OpenGeneratorEditor(data)
    if IsValid(nadmin.motd.genPanel) then nadmin.motd.genPanel:Remove() end

    nadmin.motd.genPanel = nadmin.vgui:DFrame(nil, {ScrW() * 0.9, ScrH() * 0.9})
    local motd = nadmin.motd.Panel

    motd:Center()
    motd:SetTitle("Message Of The Day - Generator")
    -- motd:ShowCloseButton(true)
    motd:MakePopup()
end