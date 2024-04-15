--[[
  Please don't change most of these, these are default values! Change them in game please
]]--
--Big tables, no touchy
nadmin               = nadmin               or {}
nadmin.access        = nadmin.access        or {}
nadmin.bans          = nadmin.bans          or {}
nadmin.colors        = nadmin.colors        or {}
nadmin.colors.chat   = nadmin.colors.chat   or {}
nadmin.colors.gui    = nadmin.colors.gui    or {}
nadmin.commands      = nadmin.commands      or {}
nadmin.config        = nadmin.config        or {}
nadmin.config.chat   = nadmin.config.chat   or {}
nadmin.connecting    = nadmin.connecting    or {}
nadmin.entities      = nadmin.entities      or {}
nadmin.errors        = nadmin.errors        or {}
nadmin.features      = nadmin.features      or {}
nadmin.forcedPrivs   = nadmin.forcedPrivs   or {}
nadmin.icons         = nadmin.icons         or {}
nadmin.immunity      = nadmin.immunity      or {}
nadmin.menu          = nadmin.menu          or {}
nadmin.npcs          = nadmin.npcs          or {}
nadmin.plugins       = nadmin.plugins       or {}
nadmin.plyReturns    = nadmin.plyReturns    or {}
nadmin.pm            = nadmin.pm            or {}
nadmin.profile       = nadmin.profile       or {}
nadmin.ranks         = nadmin.ranks         or {}
nadmin.time          = nadmin.time          or {}
nadmin.perms         = nadmin.perms         or {}
nadmin.plyToSave     = nadmin.plyToSave     or {}
nadmin.tools         = nadmin.tools         or {}
nadmin.userdata      = nadmin.userdata      or {}
nadmin.vehicles      = nadmin.vehicles      or {}
nadmin.weapons       = nadmin.weapons       or {}
nadmin.xp            = nadmin.xp            or {}
nadmin.xp.cache      = nadmin.xp.cache      or {}

nadmin.colors.blue  = Color(98, 176, 255)  --The color of people who call commands in chat.
nadmin.colors.red   = Color(255, 62, 62)   --The color of targets in chat.
nadmin.colors.white = Color(255, 255, 255) --The color of general chat text.

nadmin.colors.chat.dead = Color(255, 62, 62)   --The color of *DEAD* in chat.
nadmin.colors.chat.team = Color(127, 255, 127) --The color of (TEAM) in chat.
nadmin.colors.chat.tag  = Color(255, 255, 255) --The color of peoples ranks in chat.

nadmin.colors.gui.green   = Color(62, 255, 62)
nadmin.colors.gui.blue    = Color(0, 150, 255)  -- The color of buttons on the gui.
nadmin.colors.gui.red     = Color(255, 62, 62)  -- The color of buttons like "Are you sure" or something is invalid
nadmin.colors.gui.warning = Color(230, 230, 62) -- The color of warnings in text entries
nadmin.colors.gui.theme   = Color(75, 75, 75)   -- The main color of the gui. Uses `nadmin:DarkenColor` and `nadmin:BrightenColor` to add variance

nadmin.colors.gui.health = Color(255, 62, 62)  --The color of your health.
nadmin.colors.gui.armor  = Color(98, 176, 255) --The color of your armor.
nadmin.colors.gui.xp     = Color(205, 175, 0)  --The color of the XP bar
nadmin.colors.gui.ammo   = Color(200, 200, 0)  --The color of your ammo counter.

nadmin.config.prefixes  = {"!", "/", "n!", "n/", "~"} --What to type in chat to call a command.
nadmin.config.sprefixes = {"n@", "n?"}           --What to type in chat to call a command silently.

nadmin.config.chat.tagLeft  = "(" --What goes before the player's rank in chat.
nadmin.config.chat.tagRight = ")" --What goes after the player's rank in chat.

nadmin.config.saveInterval = 30 --How often to save player data

nadmin.config.steamIDMatch = "STEAM_[0-5]:[0-9]:[0-9]+" --SteamID pattern

nadmin.config.banPerPage = 10
nadmin.config.banMessage = [[
----==[Banned]==----
For: {{REASON}}
--------------------
By: {{BANNED_BY}} ({{STEAMID}})
Until: {{UNBAN_DATE}}

Banned on: {{BAN_DATE}}]]

nadmin.errors.accessDenied    = "You do not have access to use this."
nadmin.errors.noTargets       = "No players were found."
nadmin.errors.noTargLess      = "No players were found with a lower immunity than you."
nadmin.errors.noTargSame      = "No players were found with an equal or lower immunity than you."
nadmin.errors.noTargSelf      = "You cannot target yourself."
nadmin.errors.TooManyTargs    = "Too many targets found, please be more specific."
nadmin.errors.notEnoughArgs   = "You need more arguments."
nadmin.errors.disabledPlug    = "This plugin is disabled by the server."
nadmin.errors.noAccess        = "You do not have access to spawn this."
nadmin.errors.noAccessEnt     = "You do not have access to spawn this entity."
nadmin.errors.noAccessNPC     = "You do not have access to spawn this NPC."
nadmin.errors.noAccessTool    = "You do not have access to use this tool."
nadmin.errors.noAccessVehicle = "You do not have access to spawn this vehicle."
nadmin.errors.noAccessSWEP    = "You do not have access to this weapon."
nadmin.errors.noAccessProp    = "You do not have access to this prop."

--Feel free to define your own immunities, either here or elsewhere!
-- Deprecated. Most of the default ranks will just have 0 for immunity. Instead they are based off of access
nadmin.immunity.everyone   = 0   --Default immunity of players.
nadmin.immunity.regular    = 20  --Immunity of regulars.
nadmin.immunity.respected  = 40  --Immunity of respected players.
nadmin.immunity.admin      = 60  --Immunity of administrators.
nadmin.immunity.superadmin = 80  --Immunity of superadministrators.
nadmin.immunity.owner      = 100 --Immunity of owners.

-- Access levels, like immunity but less precise. These actual tell if the player is admin or superadmin while immunity is who can target who
-- WARNING: If you add your own access variables, they must be in sequential order with no gaps and start from 0, otherwise you will encounter errors!
--          Any access variables you add won't show up in the ranks tab. The buttons are hard coded. Really this should be all you need.
nadmin.access.restricted = 0 -- This access level restricts everything, and the restrictions acts as a whitelist. Like a psuedo ban
nadmin.access.default    = 1  -- This signifies that a rank is the default rank. Only one rank can have this
nadmin.access.user       = 2  -- This signifies that they're just a regular user with no special access
nadmin.access.admin      = 3  -- This rank has administration access on the server
nadmin.access.superadmin = 4  -- This rank has super admin access on the server
nadmin.access.owner      = 5  -- This rank has owner access. They have access to everything and nothing can be restricted from them

nadmin.plugins.afk          = true  -- Enables AFK system that stops players from gaining playtime.
nadmin.plugins.joinMessages = true  -- Enables join and leave messages.
nadmin.plugins.logs         = true  -- Makes `nadmin:Log()` save to a file.
nadmin.plugins.scoreboard   = true  -- Enables the custom scoreboard.
nadmin.plugins.loadouts     = false -- Enables loadouts per rank.

--These are using when parsing time (4d2h, for example. It does (4 * nadmin.time.d) + (2 * nadmin.time.h))
nadmin.time.s = 1
nadmin.time.m = 60
nadmin.time.h = 3600
nadmin.time.d = 3600*24
nadmin.time.w = (3600*24)*7
nadmin.time.mo = (3600*24)*30
nadmin.time.y = (3600*24)*365

nadmin.MODE_BELOW = 0 --Used in nadmin:FindPlayer(), argument 3
nadmin.MODE_SAME  = 1 --Used in nadmin:FindPlayer(), argument 3
nadmin.MODE_ALL   = 2 --Used in nadmin:FindPlayer(), argument 3

-- Used in checkbox styles
nadmin.STYLE_BOX    = 0  
nadmin.STYLE_SWITCH = 1

nadmin.version = "v3.7"

nadmin.defaults = nadmin.defaults or table.Copy(nadmin)

nadmin.defaults.userdata = { --Userdata structure for a player
    rank = "",
    forcedName = "",
    playtime = 0,
    lastJoined = {
        name = "",
        when = 0
    },
    ppFriends = {},
    money = 0
}
