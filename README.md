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

## 3/11/22
- Optimized the "Circular" HUD option. The number of faces on all circles was ridiculously high, now it shouldn't impact performance too much.
- Removed a few UI color presets because they didn't look very good.
- Some work put into `tab_ranks.lua` refactor.

## 3/12/22
- Made some optimizations to the new VGUI system. Converted the NadminCheckBox to be based off of DCheckBox instead of DButton.
- Shifted access variables in `variables.lua` to be 0-5 instead of -1-4.
- Some work put into `tab_ranks.lua` refactor.

## 3/13/22
- More work into `tab_ranks.lua` refactor. I'll finish it one of these days :^)

- - - -

# Installation
Check the releases section on the right. If you download this repository as is, you'll sort of get a beta, but anything in the process of being refactored will be broken and there will be more untested stuff.

- - - -

# Documentation
No documentation has been created yet. Please check back later.

- - - -

# Addon Created by NubTheFatMan
Have any questions? Concerns? Suggestions? (All related to Nadmin)

- - - -

Discord: NubTheFatMan#6969\
Discord Guild: https://discord.gg/P8Un9Drm8p \
Steam: NubTheFatMan (https://steamcommunity.com/id/nubthefatman/)
Website: https://nubstoys.xyz/