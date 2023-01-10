# Nadmin
Nadmin is an administration mod for the Steam game Garry's Mod. I have two inspirations for making this. One is from Evolve, it was a neat administration mod. I wanted to make my own with a few unique features, like including many mods in one. My other inspiration is that I love to develop things that way I know I can. I like to provide content that the Garry's Mod community will bennefit from, and I think this will help with managing servers. The name Nadmin comes from **N**ub's **admin**istration mod. I wanted to call it Nadmod (**N**ub's **ad**ministration **mod**), but that name is already taken by the Prop Protection addon [Nadmod](https://github.com/Nebual/NadmodPP), so I changed it.

- - - - 

# Current additions that haven't been released
The following changes will be released in 3.8 once I finish the `tab_ranks.lua` refactor.

## Previously (date isn't logged)
- Added rank access. Before, everything was based purely off immunity. Now, it first checks access, then immunity. Any owner rank will always be better than superadmin, etc. 
- Owners can change all ranks immunities. Before, owners couldn't set it above 100 or their own rank.
- On the scoreboard, avatar icon backgrounds are now the player's rank color. When you click on the name, their rank text is also colored.
- Made a new VGUI system.
- Began refactoring all of the UI to use the new UI system. For whatever reason, I made some weird VGUI library instead of using traditional methods.

## March 2022
- Optimized the "Circular" HUD option. The number of faces on all circles was ridiculously high, now it shouldn't impact performance too much.
- Removed a few UI color presets because they didn't look very good.
- Made some optimizations to the new VGUI system. Converted the NadminCheckBox to be based off of DCheckBox instead of DButton.
- Shifted access variables in `variables.lua` to be 0-5 instead of -1-4.
- Work into `tab_ranks.lua` refactor. I'll finish it eventually :^)

## July 2022
I took a long break and also moved half way across the US. Finally started getting back into programming, however am postponing working on the `tab_ranks.lua` refactor.
- New votegag command. 
- New votemute command. 

## January 2023
Progress has been real slow and I'm lazy.
- Optimized `nadmin/default_ranks.lua`. Instead of always loading the default ranks into memory, it will just cut straight to existing ranks.
- Files that had under 10 or 20 lines of code were combined. There were multiple files that were super short, inflating the file count.

- - - -

# Installation
Check the releases section on the right. If you download this repository as is, you'll sort of get a beta, but anything in the process of being refactored will be broken and there will be more untested stuff.

- - - -

# Documentation
No documentation has been created yet. Please check back later.

- - - -

# Addon Created by NubTheFatMan
Have any questions? Concerns? Suggestions? (All related to Nadmin)

Discord: NubTheFatMan#6969\
Discord Guild: https://discord.gg/P8Un9Drm8p \
Steam: NubTheFatMan (https://steamcommunity.com/id/nubthefatman/) \
Website: https://nubstoys.xyz/

- - - -

# To Do
Here are some notable things I want to at some point, implement.

### Commands:
- Force Spawn Point: There is a command for someone to set their spawn point, but admins can't change or remove it. This would allow for that.
- Force Remove Spawn Point: Read above.

### Profiles
I started on a profiles tab a long time ago and I eventually want to make it functional. Meant for server management, the profiles tool allows admins to search through all players who have every played the server and manage information about them. They could view warning history (when implemented), change rank, set a forced name when they join again, or even just add notes about them that other staff management can see. Banning would be a thing too if the admin has permission.

### Functionality
These are things I want Nadmin to be able to do.
- Default Permissions: This is more backend functionality. A developer who's adding on to Nadmin can set the default access level of a permission. They would then be able to be overridden by rank managers.
- Warnings: A warning system where players can be warned for misbehaving, and having a record for infractions. These can be used to automatically ban based on recent infractions.
- Nadmin Config: I want to make a section in the Server Settings tab that allows you to change some of Nadmin's behavior:
    - Manage command argument restrictions.
    - Manage `addons` and `discord` command link. Might just remove the commands all together, a server owner can just make adverts.
    - Restrict commands that can be ran through the `rcon` command. Although this would sort of fall under command argument restrictions.
    - Change the Asay command prefix (Starting a message with `@` instead of `!asay`).
    - Manage prefixs that get Nadmin's attention.
    - Change how often player data is saved.
    - Manage health regeneration
    - Manage plugins. I want to change plugins up a bit to where a server restart isn't necessary. Some will work without a restart, but some require a restart.
- The leveling system could use some more things. Players should be given xp for combat. Or they get a special rank for reaching a certain level. Or items can be restricted to a certain level.
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