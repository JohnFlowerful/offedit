Script inspired by Mabakos SA-MP 0.2 medit script
Made by OffRoader23

Changelog
1.0.1 - Fixed some console warnings/errors
1.1 - Fixed for Windows servers
1.2 - Added /mclone /mstack, changed code to make it run a bit more smoothly, updated objects limit to 500 (this can be changed through the offedit.lua)
1.3 - Added /minfo to get the map info of the item your currently editing
1.4 - Added /mloop and /guestb
1.5 - Fixed all OffRoader23's bullshit. Changed names to serials for guestb.
1.6 - Added new gridlines
1.7 - Added multiple model types (vehicles, peds weapons). Added /vehcol col1 col2 col3 col4
1.8 - Added createwater
2.0 - Re-factored all the code. Maps are now JSON. Fixed gridlines. Added /mapinfo, /mscale, /mcol and /delmap


In-Game Map Editor - Commands
/mcreate [obj model number] - Creates model with specified umber
/msave - Saves model into script, and gives you that objects script ID
/mdestroy - Destroy currently selected model
/msel ID - Select model saved into script by objects script ID
/mclear - Clear all objects made with the map editor
/ox value - Move model on X axis
/oy value - Move model on Y axis
/oz value - Move model on Z axis
/rx value - Rotate model on X axis
/ry value - Rotate model on Y axis
/rz value - Rotate model on Z axis
/savemap mapname - Save all current items into script folder with specified name
/loadmap mapname - Load map from script folder with specified name

New in 1.2

/mclone num x y z rx ry rz - Clones currently selected model with the distance you specify (offsets not required)

New in 1.3

/minfo to get the map info of the item your currently editing, give you model number, position, and rotation.

New in 1.4

/mloop radius pieces offset [rotaxis loops rota] - Makes a loop with currently selected piece.  Example:  /mloop 30 50 20 -y 1 0 If you use this with an model ID of 18450 (flat road) it makes a loop out of 50 pieces, the loops radius is 30, diameter 60, and from the first piece to the last there is a gap of 20 units, the object rotation axis for a 18450 is -y, if it is not set as that the loop will not be made right.  This is a more advanced command, and takes a lot of trial and error to get correct.
/guestb name - Guest someone with a building pass.  Gives them the ability to build, but not to loadmap, mclear, and savemap.  To do that put their name in offedit.lua.

New in 1.8

/createwater southWest_X southWest_Y southWest_Z southEast_X southEast_Y southEast_Z northWest_X northWest_Y NorthWest_Z northEast_X northEast_Y northEast_Z

New in 2.0

/mapinfo mapname - Returns the players name, serial, IP and the date the map was saved
/mscale x y z - Scales an object. Does not scale the collision
/mcol 0 or 1 - Toggles a models collisions
/delmap id|file|serial|name|ip string - Deletes maps based on type (whether it contains an id, the users serial, name, etc). Currently only works when supplying a file (i.e. mapname)