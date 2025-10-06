# Nadmin
Nadmin is an administration mod for the Steam game Garry's Mod. I have two inspirations for making this. One is from Evolve, it was a neat administration mod. I wanted to make my own with a few unique features, like including many mods in one. My other inspiration is that I love to develop things that way I know I can. I like to provide content that the Garry's Mod community will bennefit from, and I think this will help with managing servers. The name Nadmin comes from **N**ub's **admin**istration mod. I wanted to call it Nadmod (**N**ub's **ad**ministration **mod**), but that name is already taken by the Prop Protection addon [Nadmod](https://github.com/Nebual/NadmodPP), so I changed it.

- - - -

# Installation
Will be updated when the mod is about finished. If you know how to properly put mods in the addons folder, should be pretty straight forward.

To give yourself elevated access to the server and to manage this mod, run "`nadmin rank \[your_name_or_steamid] owner`" on the server console. This will give you full access to the server. 

- - - -

# Addon Created by NubTheFatMan
Have any questions? Concerns? Suggestions? (All related to Nadmin)

Discord: nubthefatman\
Steam: NubTheFatMan (https://steamcommunity.com/id/nubthefatman/) \
Website: https://nubstoys.xyz/

- - - -

# To Do
Here are some notable things I want to at some point, implement.

### Commands:
- Force Spawn Point: There is a command for someone to set their spawn point, but admins can't change or remove it. This would allow for that.
- Force Remove Spawn Point: Read above.

### Profiles
*This feature was cut for now*. I started on a profiles tab a long time ago and I eventually want to make it functional. Meant for server management, the profiles tool allows admins to search through all players who have ever played the server and manage information about them. They could view warning history (when implemented), change rank, set a forced name when they join again, or even just add notes about them that other staff management can see. Banning would be a thing too if the admin has permission.

### Functionality
These are things I want Nadmin to be able to do.
- Default Permissions: This is more backend functionality. A developer who's adding on to Nadmin can set the default access level of a permission. They would then be able to be overridden by rank managers.
- Warnings: A warning system where players can be warned for misbehaving, and having a record for infractions. These can be used to automatically ban based on recent infractions.
- Nadmin Config: I want to make a section in the Server Settings tab that allows you to change some of Nadmin's behavior:
    - Manage command argument restrictions.
    - Restrict commands that can be ran through the `rcon` command. Although this would fall under command argument restrictions.
    - Manage prefixs that get Nadmin's attention.
- In addition to warnings, I want to add a general logging system. This would allow admins to go back in time and view what a player has done.

### Core
- When it comes to functions in the back end, I want to change things up. Mostly for how I manage the player metatable. I define functions such as `<Player>:GetRank()`. To avoid possible conflicts, I want to change it to either `<Player>:NadminRank()` or `nadmin.getPlayerRank(ply)`.

### Known Bugs
There are some bugs that I haven't gotten around to fixing.
- Scoreboard:
    - When changing the player sort, it only updates the order of players once. If any of the values it's sorting by changes, it would appear out of order.
    - The Set Rank command throws an error.
- MOTD: 
    - Saving doesn't work.