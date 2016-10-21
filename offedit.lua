local minc_default = 1
local mrinc_default = 15
local invalidmodels
local playerobj = {}
local maxobjects = 1500
local mapinfo = {}
local minc = {}
local mrinc = {}
local objects = {}
local gridlines = {}
local resourcemaps = {}

local nyiggas = {
	'A25B7706EE8A96E9CD6F9E66AC42B343' --ishi
}

addCommandHandler('guestb',
	function (player, command, name)
		--if hasPerms(player) then
		if hasObjectPermissionTo(player, 'function.kickPlayer', true) or getElementData(player, 'staff') == true then
			local guest = getPlayerFromPartialName(name)
			if guest then
				local name = getPlayerName(guest)
				if getElementData(guest, 'builder') == false then
					outputChatBox('#0AC3F5'..name..' recieved map editor pass.', root, 255, 255, 255, true)
					setElementData(guest, 'builder' , true)
				else
					outputChatBox('#0AC3F5'..name..' map editor pass removed.', root, 255, 255, 255, true)
					setElementData(guest, 'builder' , false)
				end
			else
				outputChatBox('Can not find player "'..name..'"', player)
			end
		else 
			outputChatBox('You do not have permission to do that.', player)
		end
	end
)

addCommandHandler('mcreate',
	function (player, command, objectid, width, depth, height)
		if invalidmodels[objectid] then 
			return outputChatBox(objectid.. ' is not a valid model ID.', player) 
		end
		if hasPerms(player) then
			if not playerobj[player] then
				if objectid then
					local var = objectid
					local x, y, z = getElementPosition(player)
					local int, dim = getElementInterior(player), getElementDimension(player)
					if type(tonumber(var)) == 'number' then
						local var = tonumber(var)
						if var > 611 and var <= 20000 or (var <= 372 and var >= 321) then --objects
							playerobj[player] = createObject(var, x + 2, y + 2, z - 1)
						elseif var <= 611 and var >= 400 then --vehicles
							playerobj[player] = createVehicle(var, x + 2, y + 2, z + 1)
						elseif var <= 312 then --peds
							playerobj[player] = createPed(var, x + 2, y + 2, z + 1)
						end
					else
						if var == 'water' then
							if width and depth and height then
								playerobj[player] = createWater(x - (.5 * width), y - (.5 * depth), height, x + (.5 * width), y - (.5 * depth), height, x - (.5 * width), y + (.5 * depth), height, x + (.5 * width), y + (.5 * depth), height)
							else
								outputChatBox('SYNTAX: /mcreate water <width> <depth> <height>', player)
							end
						else
							local veh = getVehicleModelFromName(var)
							if veh then
								playerobj[player] = createVehicle(veh, x + 2, y + 2, z + 1)
							end
						end
					end
					
					if playerobj[player] then
						bindMovementKeys(player)
						setElementInterior(playerobj[player], int)
						setElementDimension(playerobj[player], dim)
						if getElementType(playerobj[player]) == 'vehicle' or getElementType(playerobj[player]) == 'ped' then
							setElementFrozen(playerobj[player], true)
						end
						updateGridlines(playerobj[player], true)
					else
						outputChatBox(var.. ' is not a valid model ID.', player)
					end
				else
					outputChatBox('SYNTAX: /mcreate objectID [width depth height]', player)
				end
			else
				outputChatBox('You are already editing an object.  Please save or delete to make another.', player)
			end
		end
	end
)

--[[addCommandHandler('createwater', 
	function (player, command, southWest_X, southWest_Y, southWest_Z, southEast_X, southEast_Y, southEast_Z, northWest_X, northWest_Y, NorthWest_Z, northEast_X, northEast_Y, northEast_Z)
		if northEast_Z then
			water = createWater(southWest_X, southWest_Y, southWest_Z, southEast_X, southEast_Y, southEast_Z, northWest_X, northWest_Y, NorthWest_Z, northEast_X, northEast_Y, northEast_Z)
			if water then
				outputChatBox('Created water', player)
			else
				outputChatBox('nyigga bs')
			end
		else
			outputChatBox('You must supply all 4 sets of values', player)
		end
	end
)]]

addCommandHandler('vehcol',
	function (player, command, ...)
		if playerobj[player] then
			local model = getElementModel(playerobj[player])
			if tonumber(model) <= 611 and tonumber(model) >= 400 then
				local colors = { getVehicleColor(playerobj[player]) }
				local args = { ... }
				for i=1,12 do
					if not args[i] then args[i] = 255 end
					colors[i] = args[i] and tonumber(args[i]) or colors[i]
				end
				setVehicleColor(playerobj[player], unpack(colors))
			else
				outputChatBox('You must be editing a vehicle to change its colour.', player)
			end
		end
	end
)

addCommandHandler('mclone',
	function (player, command, times, addx, addy, addz, addrx, addry, addrz)
		if hasPerms(player) then
			if type(tonumber(times)) == 'number' then
				local times = tonumber(times)
				if times < 50 and times >= 1 then
					if playerobj[player] then
						local model = getElementModel(playerobj[player])
						local addx, addy, addz, addrx, addry, addrz = addx or 0, addy or 0, addz or 0, addrx or 0, addry or 0, addrz or 0
						local int, dim = getElementInterior(player), getElementDimension(player)
						local type = getElementType(playerobj[player])
						for i=1,times do
							local x, y, z = getElementPosition(playerobj[player])
							local rx, ry, rz = getElementRotation(playerobj[player])
							saveObject(player)
							if type == 'object' then
								playerobj[player] = createObject(model, x + addx, y + addy, z + addz, rx + addrx, ry + addry, rz + addrz)
							elseif type == 'vehicle' then
								playerobj[player] = createVehicle(model, x + addx, y + addy, z + addz, rx + addrx, ry + addry, rz + addrz)
								setElementFrozen(playerobj[player], true)
							elseif type == 'ped' then
								playerobj[player] = createPed(model, x + addx, y + addy, z + addz, addrz, true)
								setElementFrozen(playerobj[player], true)
							end
							setElementInterior(playerobj[player], int)
							setElementDimension(playerobj[player], dim)
							updateGridlines(playerobj[player], false)
						end
					end
					if playerobj[player] then
						updateGridlines(playerobj[player], true)
					else
						outputChatBox('Failed to clone model. Make sure you have one selected.', player)
					end
				else
					outputChatBox('Failed to clone model. You can only clone between 1 and 50 items at once.', player)
				end
			else
				outputChatBox('SYNTAX: /mclone times addX [addY addZ addRX addRY addRZ]', player)
			end
		end
	end
)

addCommandHandler('mloop',
	function (player, command, pieces, radi, offset, rotaxis, loops, rota)
		if hasPerms(player) then 
			local angle
			local newi
			local loops = tonumber(loops) or 1
			if rota then 
				rota = rota*(math.pi/180)
			else 
				rota = 0
			end
			if radi and pieces and offset then
				radi = tonumber(radi)
				pieces = tonumber(pieces)
				offset = tonumber(offset)
				local spiralp = math.atan((offset/2)/(2*radi))/loops
				if playerobj[player] then
					local orx, ory, orz = getElementPosition(playerobj[player])
					local int, dim = getElementInterior(player), getElementDimension(player)
					newi = -1
					for i=0,pieces do
						local x, y, z = getElementPosition(playerobj[player])
						local rx, ry, rz = getObjectRotation(playerobj[player])
						local model = getElementModel(playerobj[player])
						saveObject(player)
						local weight = 1-(1/(pieces/2))*math.abs((pieces/2)-i)
						local radians =(i/pieces)*(2*math.pi)*loops
						local newx = orx + radi*math.sin(radians)*math.cos(rota)+(offset/2)*math.cos(radians/(2*loops))*-math.sin(rota)
						local newy = ory +(offset/2)*math.cos(radians/(2*loops))*math.cos(rota)+radi*math.sin(radians)*math.sin(rota)
						local newz = orz + radi*-math.cos(radians)
						newi = newi + 1
						angle = (((360/pieces)* loops)* newi)
						if rotaxis == 'x' then
							newrotx = angle
							newroty = ry --+((radians)-math.cos(rota)*spiralp*weight)
						elseif rotaxis == '-x' then
							newrotx = -angle
							newroty = ry --+((radians)-math.cos(rota)*spiralp*weight)
						elseif rotaxis == 'y' then
							newrotx = rx --+((radians)-math.cos(rota)*spiralp*weight)
							newroty = angle
						elseif rotaxis == '-y' then
							newrotx = rx --+((radians)-math.cos(rota)*spiralp*weight)
							newroty = -angle
						end
						newz = newz + radi
						playerobj[player] = createObject(model, newx, newy, newz, newrotx, newroty, rz)
						setElementInterior(playerobj[player], int)
						setElementDimension(playerobj[player], dim)
						updateGridlines(playerobj[player], true)
					end
				end
				if not playerobj[player] then
					outputChatBox('Failed to stack object.  Make sure you have one selected.', player)
				end
			else
				outputChatBox('SYNTAX: /mloop pieces radius offset [rotaxis loops rota]', player)
			end
		end
	end
)

addCommandHandler('mcol',
	function (player, command, col)
		if playerobj[player] then
			local colon = tonumber(col)
			if colon == 1 then
				setElementCollisionsEnabled(playerobj[player], true)
				outputChatBox('Collisions on', player)
			elseif colon == 0 then
				setElementCollisionsEnabled(playerobj[player], false)
				outputChatBox('Collisions off', player)
			end
		end
	end
)

local movementkeys = {
	num_4 = {axis = 'ox', direction = 1},
	num_6 = {axis = 'ox', direction = -1},
	num_8 = {axis = 'oy', direction = 1},
	num_2 = {axis = 'oy', direction = -1},
	num_add = {axis = 'oz', direction = 1},
	num_sub = {axis = 'oz', direction = -1},
	num_7 = {axis = 'rx', direction = 1},
	num_9 = {axis = 'rx', direction = -1},
	num_1 = {axis = 'ry', direction = 1},
	num_3 = {axis = 'ry', direction = -1},
	num_div = {axis = 'rz', direction = 1},
	num_mul = {axis = 'rz', direction = -1}
}

function bindMovementKeys(player)
	for k,_ in pairs (movementkeys) do
		bindKey(player, k, 'down', movementkeys[k].axis, 'false '..movementkeys[k].direction)
	end
	toggleControl(player, "special_control_left", false)
	toggleControl(player, "special_control_right", false)
	toggleControl(player, "look_behind", false)
	bindKey(player, 'num_5', 'down',  changeInc)
end

function unbindMovementKeys(player)
	for k,_ in pairs (movementkeys) do
		unbindKey(player, k, 'down', movementkeys[k].axis)
	end
	toggleControl(player, "special_control_left", true)
	toggleControl(player, "special_control_right", true)
	toggleControl(player, "look_behind", true)
	unbindKey(player, 'num_5', 'down',  changeInc)
end

function _moveObject(player, command, value, direction)
	if playerobj[player] then
		if value == 'false' then
			local startswith = command:sub(1,1)
			if startswith:lower() == 'o' then
				value = minc[player] * direction
			else
				value = mrinc[player] * direction
			end
		end
		
		local value = tonumber(value)
		if type(value) ~= 'number' then
			outputChatBox('SYNTAX: /'..command..' float', player)
		end
		
		local x, y, z = getElementPosition(playerobj[player])
		local orx, ory, orz = getElementRotation(playerobj[player])
		local rx, ry, rz = 0, 0, 0
		local type = getElementType(playerobj[player])
		if command == 'ox' then
			x = x + value
		elseif command == 'oy' then
			y = y + value
		elseif command == 'oz' then
			z = z + value
		elseif command == 'rx' then
			rx = value
		elseif command == 'ry' then
			ry = value
		elseif command == 'rz' then
			rz = value
		end
		
		if command == 'ox' or command == 'oy' or command == 'oz' then
			if type == 'object' then
				moveObject(playerobj[player], 200, x, y, z)
			elseif type == 'ped' or type == 'vehicle' then
				setElementPosition(playerobj[player], x, y, z)
				setElementFrozen(playerobj[player], true)
			else
				setElementPosition(playerobj[player], x, y, z)
			end
		elseif command == 'rx' or command == 'ry' or command == 'rz' then
			if type == 'object' then
				moveObject(playerobj[player], 200, x, y, z, rx, ry, rz)
			elseif type == 'ped' or type == 'vehicle' then
				setElementRotation(playerobj[player], rx + orx, ry + ory, rz + orz)
				setElementFrozen(playerobj[player], true)
			else
				setElementRotation(playerobj[player], rx + orx, ry + ory, rz + orz)
			end
		end
	end
end

local movementcommands = {'ox', 'oy', 'oz', 'rx', 'ry', 'rz'}
for _,v in pairs (movementcommands) do
	addCommandHandler(v, _moveObject)
end

function setInc(player, command, value)
	minc[player] = tonumber(value)
	outputChatBox('Movement incriments set to ' ..value.. '', player)
end
addCommandHandler('minc', setInc)

function setRInc(player, command, value)
	mrinc[player] = tonumber(value)
	outputChatBox('Rotational incriments set to ' ..value.. '', player)
end
addCommandHandler('mrinc', setRInc)

function changeInc(player)
	if minc[player] == 1 then
		minc[player] = 0.1
		outputChatBox('Incriments set to 0.1', player)
	elseif minc[player] == 0.1 then
		minc[player] = 0.01
		outputChatBox('Incriments set to 0.01', player)
	elseif minc[player] == 0.01 then
		minc[player] = 0.005
		outputChatBox('Incriments set to 0.005', player)
	elseif minc[player] == 0.005 then 
		minc[player] = 1
		outputChatBox('Incriments set to 1', player)
	else
		minc[player] = 1
		outputChatBox('Incriments set to 1', player)
	end
end

addCommandHandler('mscale',
	function (player, command, scalex, scaley, scalez)
		if tonumber(scalex) then
			if not scalez then 
				scaley = scalex
				scalez = scalex
			end
			if playerobj[player] then
				if getElementType(playerobj[player]) == 'object' then
					local model = getElementModel(playerobj[player])
					if model then
						setObjectScale(playerobj[player], scalex, scaley, scalez)
					end
				else
					outputChatBox('Only objects can be scaled.', player)
				end
			else
				outputChatBox('You must select an object.', player)
			end
		else
			outputChatBox('SYNTAX: /mscale scale or /mscale scaleX scaleY scaleZ', player)
		end
	end
)

function destroyObject(player, command, id)
	if hasPerms(player) then
		local element
		local num = false
		if id then
			if type(tonumber(id)) == 'number' then
				id = tonumber(id)
				num = id
				if objects[id] then
					element = objects[id]
				end
			else
				outputChatBox('Invalid object ID: '..id, player)
			end
		else
			if playerobj[player] then
				element = playerobj[player]
				unbindMovementKeys(player)
				for k in pairs (objects) do
					if objects[k] == playerobj[player] then
						num = k
						break
					end
				end
			else
				outputChatBox('You must be either editing an object or supply a valid object ID', player)
			end
		end
		if element then
			if num then
				outputChatBox('Object ID deleted: ' ..num, player)
				objects[num] = false
			else
				outputChatBox('Current object deleted.', player)
			end
			
			local editing = getPlayersEditingObject(element)
			for _,v in pairs (editing) do
				playerobj[v] = false
			end
			updateGridlines(element, false)
			destroyElement(element)
		end
	end
end
addCommandHandler('mdestroy', destroyObject)

function saveObject(player, command)
	if hasPerms(player) then 
		if playerobj[player] then
			local model = getElementModel(playerobj[player])
			local first = true
			local id
			for i=0,maxobjects+1 do
				if objects[i] == playerobj[player] then
					id = i
					break
				elseif not objects[i] then
					if first then
						first = false
						id = i
					else
						break
					end
				end
			end
			if id > maxobjects then return outputChatBox('You have reached the limit of objects.', player) end
			
			if getElementType(playerobj[player]) == 'vehicle' or getElementType(playerobj[player]) == 'ped' then 
				setElementFrozen(playerobj[player], false) 
			end
			objects[id] = playerobj[player]
			outputChatBox('Object saved as ID: ' ..id, player)
			unbindMovementKeys(player)
			local editing = getPlayersEditingObject(playerobj[player])
			if not (#editing > 1) then
				updateGridlines(playerobj[player], false)
			end
			playerobj[player] = false
		end
	end
end
addCommandHandler('msave', saveObject)

addCommandHandler('msel',
	function (player, command, id)
		if hasPerms(player) then 
			id = tonumber(id)
			if playerobj[player] then
				saveObject(player)
			end
			if objects[id] then 
				playerobj[player] = objects[id]
				bindMovementKeys(player)
				updateGridlines(playerobj[player], true)
				outputChatBox('Object ID selected: ' ..id.. '', player)
			end
		end
	end
)

addCommandHandler('minfo',
	function (player, command, id)
		if hasPerms(player) then 
			local element
			if id then
				local id = tonumber(id)
				if objects[id] then
					element = objects[id]
				else
					outputChatBox('Invalid object ID: '..id, player)
				end
			else
				if playerobj[player] then
					element = playerobj[player]
				else
					outputChatBox('You must be editing an object or supply a valid ID.', player)
				end
			end
			
			if element then
				local model = getElementModel(element)
				if not model then return end
				local x, y, z = getElementPosition(element)
				local rx, ry, rz = getElementRotation(element)
				local scalex, scaley, scalez = getObjectScale(element)
				outputChatBox('Object Info - Object Model ID: ' .. model, player)
				outputChatBox('Pos X: ' .. x .. ' Pos Y: ' .. y .. ' Pos Z: ' .. z, player)
				outputChatBox('Rot X: ' .. rx .. ' Rot Y: ' .. ry .. ' Rot Z: ' .. rz, player)
				outputChatBox('Scale X: '..scalex..' Scale Y: '..scaley..' Scale Z: '..scalez, player)
			end
		end
	end
)

addCommandHandler('saveasmap',
	function (player, command, mapname)
		if hasPerms(player) then 
			if mapname then
				local file = xmlCreateFile('maps/'..mapname..'.map', 'map')
				xmlMetaBranch = xmlCreateChild(file, 'meta')
				xmlInfoChild = xmlCreateChild(xmlMetaBranch, 'info')
				xmlNodeSetAttribute(xmlInfoChild, 'name', 'In-game map editor')
				xmlNodeSetAttribute(xmlInfoChild, 'author', 'JohnFlower')
				xmlNodeSetAttribute(xmlInfoChild, 'description', 'File Generated with offedit')
					for i=0,#objects do
						if objects[i] then
							local model = getElementModel(objects[i])
							if model then
								local x, y, z = getElementPosition(objects[i])
								local rx, ry, rz = getElementRotation(objects[i])
								if tonumber(model) <= 611 and tonumber(model) >= 400 then
									local col1, col2, col3, col4 = getVehicleColor(objects[i])
									xmlVehiclesBranch = xmlCreateChild(file, 'vehicle')
									xmlNodeSetAttribute(xmlVehiclesBranch, 'id', i)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'posX', x)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'posY', y)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'posZ', z)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'rotX', rx)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'rotY', ry)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'rotZ', rz)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'model', model)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'col1', col1)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'col2', col2)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'col3', col3)
									xmlNodeSetAttribute(xmlVehiclesBranch, 'col4', col4)
								elseif tonumber(model) <= 312 then
									xmlPedBranch = xmlCreateChild(file, 'ped')
									xmlNodeSetAttribute(xmlPedBranch, 'id', i)
									xmlNodeSetAttribute(xmlPedBranch, 'posX', x)
									xmlNodeSetAttribute(xmlPedBranch, 'posY', y)
									xmlNodeSetAttribute(xmlPedBranch, 'posZ', z)
									xmlNodeSetAttribute(xmlPedBranch, 'rotX', rx)
									xmlNodeSetAttribute(xmlPedBranch, 'rotY', ry)
									xmlNodeSetAttribute(xmlPedBranch, 'rotZ', rz)
									xmlNodeSetAttribute(xmlPedBranch, 'model', model)
								else
									xmlObjectsBranch = xmlCreateChild(file, 'object')
									xmlNodeSetAttribute(xmlObjectsBranch, 'id', i)
									xmlNodeSetAttribute(xmlObjectsBranch, 'posX', x)
									xmlNodeSetAttribute(xmlObjectsBranch, 'posY', y)
									xmlNodeSetAttribute(xmlObjectsBranch, 'posZ', z)
									xmlNodeSetAttribute(xmlObjectsBranch, 'rotX', rx)
									xmlNodeSetAttribute(xmlObjectsBranch, 'rotY', ry)
									xmlNodeSetAttribute(xmlObjectsBranch, 'rotZ', rz)
									xmlNodeSetAttribute(xmlObjectsBranch, 'model', model)
								end
							end
						end
					end
				xmlSaveFile(file)
				xmlUnloadFile(file)
				outputChatBox('You saved ' .. mapname, player)
			end
		end
	end
)

addCommandHandler('mapinfo',
	function(player, command, mapname)
		if hasPerms(player) then
			local info = false
			if mapname then
				if fileExists('maps/' ..mapname..'.json') then
					local file = fileOpen('maps/'..mapname..'.json')
					local size = fileGetSize(file)
					local buffer = fileRead(file, size)
					local tempdata = fromJSON(buffer)
					fileClose(file)
					info = tempdata.info
					tempdata = {}
				else
					outputChatBox(mapname..' does not exist', player)
				end
			else
				info = mapinfo
			end
			
			if info then
				outputChatBox('Creator: '..info.creator..' - Serial: '..info.serial..' - IP: '..info.ip..' - Time: '..info.time, player)
			end
		else
			return outputChatBox ('#FA1464Only administrators can use this command', player, 255, 255, 255, true)
		end
	end
)

function clearPlayerObjects(player)
	if hasPerms(player) then 
		for i=0,maxobjects do
			if isElement(objects[i]) then
				destroyElement(objects[i])
			end
		end
		objects = {}
		for k,v in ipairs (getElementsByType('player')) do
			if playerobj[v] then
				updateGridlines(playerobj[v], false)
				destroyElement(playerobj[v])
			end
			playerobj[v] = false
			unbindMovementKeys(v)
		end
		outputChatBox('Map cleared.')
	end
end
addCommandHandler('mclear', clearPlayerObjects)

addCommandHandler('delmap', 
	function (player, command, type, string)
		if hasPerms(player) then
			if type and string then
				if type == 'file' then
					if fileExists('maps/' ..string..'.json') then
						fileDelete('maps/' ..string..'.json')
						outputChatBox('Deleted '..string, player)
						outputDebugString('(ADMIN.offedit) '..getPlayerName(player)..' deleted map '..string)
					else
						outputChatBox(string..' does not exist', player)
					end
				--[[else
					local files = {}
					local fsys = createFilesystemInterface()
					local dir = fsys.createTranslator('/home/server/mta_ramdisk/mods/deathmatch/resources/flowerattach/attachments/')
					
					local function dirIterator(dirPath)
						return
					end
					
					local function fileIterator(filePath)
						local name = dir.relPathRoot(filePath)
						
						table.insert(files, name)
					end
					
					dir.scanDirEx('@', '*', dirIterator, fileIterator, false)
					
					for k,v in ipairs (files) do
						outputChatBox(tostring(v))
						break
					end
					if type == 'serial' then
				
					elseif type == 'name' then
				
					elseif type == 'ip' then
				
					else 
						outputChatBox('SYNTAX: /delattach [id|file|serial|name|ip] <string>', player)
					end]]
				end
			else
				outputChatBox('SYNTAX: /delmap [id|file|serial|name|ip] <string>', player)
			end
		else
			outputChatBox ('#FA1464Only administrators can use this command.', player, 255, 255, 255, true)
		end
	end
)

function updateGridlines(element, state)
	if state == true then
		gridlines[element] = true
	else
		gridlines[element] = nil
	end
	triggerClientEvent('updateGridlines', root, gridlines)
end

function getPlayerFromPartialName(name)
	local matches = {}
	for i,player in ipairs (getElementsByType('player')) do
		if getPlayerName(player) == name then
			return player
		end
		if string.find(string.lower(getPlayerName(player)),string.lower(name),0,false) then
			table.insert(matches,player)
		end
	end
	if #matches == 1 then
		return matches[1]
	else
		return false
	end
end

addCommandHandler('convertmap',
	function (player, command, mapname)
		if hasPerms(player) then 
			loadMapLua(player, mapname)
			saveMap(player, mapname)
		else 
			outputChatBox('You do not have permission to build.')
		end
	end
)

addCommandHandler('savemap', 
	function (player, command, mapname)
		if hasPerms(player) then
			saveMap(player, mapname)
		end
	end
)

addCommandHandler('loadmap', 
	function (player, command, mapname, int, dim)
		if hasPerms(player) then
			if fileExists('maps/'..mapname..'.json') then
				clearPlayerObjects(player)
				loadMap(mapname, objects, int or 0, dim or 0)
				outputChatBox('Map loaded: ' ..mapname)
				outputDebugString('(ADMIN.offedit) player '..getPlayerName(player)..' loaded map '..mapname)
			else
				outputChatBox(mapname.. " doesn't exist", player)
			end
		end
	end
)

function saveMap(player, mapname)
	if mapname then
		if not string.find(mapname, '%W') then
			local tempdata = {} 
			tempdata['info'] = {}
			tempdata['info']['creator'] = getPlayerName(player)
			tempdata['info']['serial'] = getPlayerSerial(player)
			tempdata['info']['ip'] = getPlayerIP(player)
			tempdata['info']['time'] = getTimeStamp()
			for i=0,#objects do
				if objects[i] then
					tempdata[i] = {}
					tempdata[i]['model'] = getElementModel(objects[i])
					tempdata[i]['col'] = getElementCollisionsEnabled(objects[i])
					tempdata[i]['int'] = getElementInterior(objects[i])
					tempdata[i]['dim'] = getElementDimension(objects[i])
					local x, y, z = getElementPosition(objects[i])
					local rx, ry, rz = getElementRotation(objects[i])
					tempdata[i]['pos'] = {x, y, z, rx, ry, rz}
					
					local elementtype = getElementType(objects[i])
					if elementtype == 'vehicle' then
						tempdata[i]['type'] = 'vehicle'
						local colours = {getVehicleColor(objects[i], true)}
						for k=1,12 do
							if not colours[k] then colours[k] = 255 end
						end
						tempdata[i]['colour'] = colours
					elseif elementtype == 'ped' then
						tempdata[i]['type'] = 'ped'
					elseif elementtype == 'water' then
						tempdata[i]['vertices'] = {}
						for j=1,4 do
							local x, y, z = getWaterVertexPosition(objects[i], j)
							table.insert(tempdata[i]['vertices'], j, {['x'] = x, ['y'] = y, ['z'] = z})
						end
						tempdata[i]['type'] = 'water'
					else
						local scalex, scaley, scalez = getObjectScale(objects[i])
						tempdata[i]['scale'] = {scalex, scaley, scalez}
						tempdata[i]['type'] = 'object'
					end
				end
			end
			local file = fileCreate('maps/'..mapname.. '.json')
			fileWrite(file, toJSON(tempdata))
			fileClose(file)  
			tempdata = {}
			outputChatBox('Saved map as ' .. mapname, player)
		else
			outputChatBox('Invalid map name.', player)
		end
	else
		outputChatBox('SYNTAX: /savemap mapname', player)
	end
end
	
function loadMap(mapname, tbl, int, dim)
	local file = fileOpen('maps/'..mapname..'.json')
	local size = fileGetSize(file)
	local buffer = fileRead(file, size)
	local tempdata = fromJSON(buffer)
	fileClose(file)
	for k in pairs (tempdata) do
		if k ~= 'info' then
			local id = tonumber(k)
			local ids = tostring(k)
			local x, y, z, rx, ry, rz = unpack(tempdata[ids]['pos'])
			if tempdata[ids]['type'] == 'vehicle' then
				tbl[id] = createVehicle(tempdata[ids]['model'], x, y, z, rx, ry, rz)
				setVehicleColor(tbl[id], unpack(tempdata[ids]['colour']))
			elseif tempdata[ids]['type'] == 'ped' then
				tbl[id] = createPed(tempdata[ids]['model'], x, y, z, rz, true)
			elseif tempdata[ids]['type'] == 'water' then
				vertices = tempdata[ids]['vertices']
				tbl[id] = createWater(vertices[1].x, vertices[1].y, vertices[1].z, vertices[2].x, vertices[2].y, vertices[2].z, vertices[3].x, vertices[3].y, vertices[3].z, vertices[4].x, vertices[4].y, vertices[4].z)
			else
				tbl[id] = createObject(tempdata[ids]['model'], x, y, z, rx, ry, rz)
				scalex, scaley, scalez = unpack(tempdata[ids]['scale'])
				setObjectScale(tbl[id], scalex, scaley, scalez)
			end
			setElementCollisionsEnabled(tbl[id], tempdata[ids]['col'])
			if tempdata[ids]['int'] and tempdata[ids]['dim'] and not (int and dim) then
				setElementInterior(tbl[id], tempdata[ids]['int'])
				setElementDimension(tbl[id], tempdata[ids]['dim'])
			elseif int and dim then
				setElementInterior(tbl[id], int)
				setElementDimension(tbl[id], dim)
			end
		end
	end
	mapinfo = deepcopy(tempdata.info)
	tempdata = {}
end

function loadMapLua(player, mapname)
	if mapname then
		if fileExists('maps/'..mapname..'.o23') then
			clearPlayerObjects(player)
			local file = fileOpen('maps/'..mapname..'.o23')   
			local size = fileGetSize(file)
			local buffer = fileRead(file, size)
			objectid = {}
			assert(loadstring(buffer))()
			objects = objectid
			fileClose(file)
			outputChatBox('Map loaded: ' ..mapname)
		else
			outputChatBox(mapname.. " doesn't exist", player)
		end 
	else
		outputChatBox('No map name specified.  Please use /loadmap <name>', player)
	end
end

function loadResourceMap(mapname, int, dim, resource)
	if sourceResource then
		resource = getResourceName(sourceResource)
	end
	if not resourcemaps[resource] then
		resourcemaps[resource] = {}
	end
	
	if resourcemaps[resource][mapname] then
		unloadResourceMap(mapname, resource)
	end
	
	if fileExists('maps/'..mapname..'.json') then
		resourcemaps[resource][mapname] = {}
		loadMap(mapname, resourcemaps[resource][mapname], int, dim)
		outputDebugString('(ADMIN.offedit) resource '..resource..' loaded map '..mapname)
	else
		outputDebugString('(ADMIN.offedit) resource '..source..' failed to load '..mapname, 2)
	end
end

function unloadResourceMap(mapname, resource)
	if not resource then
		resource = getResourceName(sourceResource)
	end
	if resourcemaps[resource][mapname] then
		for i=1,#resourcemaps[resource][mapname] do
			local element = resourcemaps[resource][mapname][i]
			if isElement(element) then
				destroyElement(element)
			end
		end
		resourcemaps[resource][mapname] = nil
		outputDebugString('(ADMIN.offedit) resource '..resource..' unloaded map '..mapname)
	end
end

function getPlayersEditingObject(element)
	local editing = {}
	for k in pairs (playerobj) do
		if element == playerobj[k] then
			table.insert(editing, k)
		end
	end
	return editing
end

function getTimeStamp ()
	local time = getRealTime()
	return (time.year + 1900)..'-'..(time.month+1)..'-'..time.monthday..' '..time.hour..':'..time.minute..':'..time.second
end

function hasPerms(player)
	local value = false
	if hasObjectPermissionTo(player, 'function.kickPlayer', true) or getElementData(player, 'builder') == true or getElementData(player, 'staff') == true then
		value = true
	end
	if value == false then
		outputChatBox('You do not have permission to build.', player)
	end
	return value
end

-- http://lua-users.org/wiki/CopyTable
function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

addEventHandler('onResourceStart', resourceRoot,
	function ()
		local players = getElementsByType('player')
		for k,v in ipairs (players) do
			setElementData(v, 'builder', false)
			local serial = getPlayerSerial(v)
			for i, b in ipairs (nyiggas) do
				if serial == b then
					setElementData(v, 'builder', true)
				end
			end
		end
		
		local file = fileOpen('invalidmodels.json')
		local size = fileGetSize(file)
		local buffer = fileRead(file, size)
		invalidmodels = fromJSON(buffer)
		fileClose(file)
		
		for k,v in ipairs(getElementsByType('player')) do
			mrinc[v] = mrinc_default
			minc[v] = minc_default
		end
		outputChatBox('offedit increments set: minc = '..minc_default..'  mrinc = '..mrinc_default)
		
		local file = fileOpen('resourcemaps.json')
		local size = fileGetSize(file)
		local buffer = fileRead(file, size)
		local maps = fromJSON(buffer)
		fileClose(file)
		for k,_ in pairs (maps) do
			local state = getResourceState(getResourceFromName(k))
			if state == 'starting' or state == 'running' then
				for _,v in pairs (maps[k]) do
					loadResourceMap(v, 0, 0, k)
				end
			end
		end
	end
)

addEventHandler('onResourceStop', root,
	function (resource)
		local resource = getResourceName(resource)
		if resourcemaps[resource] then
			for k in pairs (resourcemaps[resource]) do
				for i=1,#resourcemaps[resource][k] do
					local element = resourcemaps[resource][k][i]
					if isElement(element) then
						destroyElement(element)
					end
				end
				outputDebugString('(ADMIN.offedit) resource '..resource..' unloaded map '..k)
			end
		end
	end
)

addEventHandler('onResourceStop', resourceRoot,
	function (resource)
		local maps = {}
		for k in pairs (resourcemaps) do
			maps[k] = {}
			for k2 in pairs (resourcemaps[k]) do
				table.insert(maps[k], k2)
			end
		end
		local file = fileCreate('resourcemaps.json')
		fileWrite(file, toJSON(maps))
		fileClose(file) 
	end
)

addEventHandler('onPlayerJoin', root,
	function ()
		setElementData(source, 'builder', false)
		local serial = getPlayerSerial(source)
		for k,v in ipairs (nyiggas) do
			if serial == v then
				setElementData(source, 'builder', true)
			end
		end
		mrinc[source] = mrinc_default
		minc[source] = minc_default
		outputChatBox('offedit increments set: minc = '..minc[source]..'  mrinc = '..mrinc[source], source)
	end
)

addEventHandler('onPlayerQuit', root,
	function ()
		saveObject(source)
		setElementData(source, 'builder', false)
	end
)
