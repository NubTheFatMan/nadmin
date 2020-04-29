function nadmin:RegisterCommand(tbl)
    local cmd = table.Copy(tbl) -- Copy the input table to keep any custom values on the table.

    cmd.title       = isstring(tbl.title)       and tbl.title       or "Undefined"
    cmd.id          = isstring(tbl.id)          and tbl.id          or string.lower(string.Replace(cmd.title, " ", "_"))
    cmd.description = isstring(tbl.description) and tbl.description or ""
    cmd.author      = isstring(tbl.author)      and tbl.author      or "Anonymous author"
    cmd.timeCreated = isstring(tbl.timeCreated) and tbl.timeCreated or "Unknown date"
    cmd.category    = isstring(tbl.category)    and tbl.category    or "Other"
    cmd.forcedPriv  = isbool(tbl.forcedPriv)    and tbl.forcedPriv  or false

    self.commands[cmd.id] = table.Copy(cmd)

    if cmd.forcedPriv then
        self.forcedPrivs[cmd.id] = true
    end

    -- MsgN("Registered Command: " .. cmd.title)

    -- Here are some extra valid (used) variables for a command
    -- cmd.advUsage = tbl.advUsage
    -- cmd.call = tbl.call
    -- cmd.usage = tbl.usage
    -- cmd.server = tbl.server
    -- cmd.client = tbl.client
    -- cmd.scoreboard = tbl.scoreboard

    return cmd
end

function nadmin:FindCommand(id)
    if istable(nadmin.commands[id]) then return nadmin.commands[id] end
    for i, cmd in pairs(nadmin.commands) do
        if string.lower(cmd.title) == string.lower(id) then
            return cmd
        end
    end
end
