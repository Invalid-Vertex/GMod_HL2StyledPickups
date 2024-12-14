Reworked version of my addon "HL2 Styled TF2 Health/Ammo Replacements".
I recommend switching to this addon if you liked the old version,
as I've deprecated the previous addon, so any updates will be to this version only.
Like the prevous version, they only spawn by default on Team Fortress 2 maps,
but I've overhauled the configuration system a bit to hopefully make adding them to other maps a bit less painful.
You can also spawn them through the context menu, though they'll be cleared when you clean up the map.
Upon startup/cleanup of a map, it will look for a folder named 'hl2pickups_custom' and if a .dat file matching the current map name exists and is properly configured, it will spawn the pickups.
Included is a basic config file for 'gm_construct' which will hopefully help people configure other maps for spawning.
If you want the pickups to appear on other maps, simply create a .dat file with the name of your map (minus the .bsp extention) under the hl2pickups_custom directory,
then configure it as follows;
Type, Size, X, Y, Z
(Example: healthkit,small,760,-1060,-140)

The health kits give;
Small = 20% of max health, 15 armor
Medium = 50% of max health, 45 armor
Full = 100% of max health, 100 armor

The ammo packs give;
Small = 1 clip to each weapon
Medium = 2 clips to each weapon
Full = 3 clips to each weapon
