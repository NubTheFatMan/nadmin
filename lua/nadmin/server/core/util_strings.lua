util.AddNetworkString("nadmin_rank")               -- Assigned to a player; their rank ID
util.AddNetworkString("nadmin_playtime")           -- Their playtime on the server.
util.AddNetworkString("nadmin_nickname")           -- A player's nickname
util.AddNetworkString("nadmin_IsNicknamed")        -- Is a player nicknamed (bool string)
util.AddNetworkString("nadmin_clientRun")          -- Used to make the server run commands on a client.
util.AddNetworkString("nadmin_notification")       -- Used by nadmin:Notify to message clients
util.AddNetworkString("nadmin_command")            -- Used by client console commands `nadmin` and `nadmins`
util.AddNetworkString("nadmin_send_register")      -- Used to send entities, tools, and weapons to the client.
util.AddNetworkString("nadmin_send_updated_ranks") -- Used to send ranks to client when they are updated on the server.
util.AddNetworkString("nadmin_message_send")       -- Used when a player sends a message.
util.AddNetworkString("nadmin_private_message")    -- Used to send private messages between players
util.AddNetworkString("nadmin_updateRank")         -- Used when a role is updated in !menu
util.AddNetworkString("nadmin_update_cmds")        -- Used when reloading a command
util.AddNetworkString("nadmin_god")                -- Used in the Player:HasGodMode bug fix
util.AddNetworkString("nadmin_motd_request")       -- Used when the player calls the motd command
util.AddNetworkString("nadmin_xp")                 -- Player's xp
util.AddNetworkString("nadmin_cast_vote")          -- Used for votes. Server broadcast details to everyone, clients send a response back on this string
util.AddNetworkString("nadmin_request_members")    -- Used on the ranks tab
util.AddNetworkString("nadmin_manage_member")      -- Used in the rank tab when managing a member
util.AddNetworkString("nadmin_restrict_perm")      -- Used when restricting via spawn menu right click
util.AddNetworkString("nadmin_announcement")       -- Used in announcements.
util.AddNetworkString("nadmin_request_bans")       -- Used in the bans tab
util.AddNetworkString("nadmin_edit_ban")           -- Used in the bans tab
util.AddNetworkString("nadmin_freeze_ban")         -- Used to freeze ban a player from the bans tab
