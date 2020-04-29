nadmin.website = "http://nubstoys.xyz/gmod/mods/nadmin/version.txt"

hook.Add("PlayerConnect", "nadmin_check_updates", function()
    if isstring(nadmin.needs_update) and nadmin.needs_update ~= "" then return end
    MsgN("[Nadmin]Checking for updates...")
    http.Fetch(nadmin.website,
        function(body, size, headers, code) -- Successful retrieval
            body = string.Trim(body)
            if nadmin.version ~= body then
                nadmin.needs_update = body -- This string is to send the version to the client; otherwise it'd be a bool
                MsgN("[Nadmin]Update available!")
                MsgN("[Nadmin]Running " .. nadmin.version)
                MsgN("[Nadmin]Latest: " .. body)
            end
        end,
        function(err) -- Invalid retrieval (website deleted?)
            MsgN("[Nadmin]Unable to retrieve Nadmin version.")
        end
    )
end)
