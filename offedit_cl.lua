local MAX_THICKNESS = 1.2
local RENDER = true
local thickness
local drawLine
local colour = tocolor(255, 255, 255, 120)
local attachedToElements = {}

addEvent("updateGridlines", true)
addEventHandler("updateGridlines", root, 
	function(element, player)
		if element and player then
			local inTable = false
			for k,v in ipairs (attachedToElements) do
				if element == v.elem and player == v.user then
					table.remove(attachedToElements, k)
					inTable = true
				end
			end
			if inTable == false then
				table.insert(attachedToElements, {['elem'] = element, ['user'] = player})
			end
		else
			for k,v in ipairs (attachedToElements) do
				if not isElement(v.elem) then
					table.remove(attachedToElements, k)
				end
			end
		end
	end
)

addCommandHandler('togglelines',
	function ()
		if RENDER then
			RENDER = false
		else
			RENDER = true
		end
	end
)

function renderGridlines()
	if RENDER then
		for k,v in ipairs (attachedToElements) do
			if not isElement(v.elem) then return end
			if getElementDimension(v.elem) ~= getElementDimension(localPlayer) then return end
			
			local x, y, z = getElementPosition(v.elem)
			if not x then return end

			local minX, minY, minZ, maxX, maxY, maxZ = getElementBoundingBox(v.elem)
			if not minX then
				local radius = getElementRadius(v.elem)
				if radius then
					minX, minY, minZ, maxX, maxY, maxZ = -radius, -radius, -radius, radius, radius, radius
				end
			end
			
			if not minX or not minY or not minZ or not maxX or not maxY or not maxZ then return end
			local camX,camY,camZ = getCameraMatrix()
			--Work out our line thickness
			thickness = (100/getDistanceBetweenPoints3D(camX,camY,camZ,x,y,z)) * MAX_THICKNESS
			--
			local elementMatrix = (getElementMatrix(v.elem) ) 
									and matrix(getElementMatrix(v.elem))
			if not elementMatrix then
				--Make them into absolute coords
				minX, minY, minZ = minX + x,minY + y,minZ + z
				maxX, maxY, maxZ = maxX + x,maxY + y,maxZ + z
			end
			--
			local face1 = matrix{
					{minX, maxY, minZ,1}, 
					{minX, maxY, maxZ,1}, 
					{maxX, maxY, maxZ,1}, 
					{maxX, maxY, minZ,1},
				}
			local face2 = matrix{
					{minX, minY, minZ,1},
					{minX, minY, maxZ,1}, 
					{maxX, minY, maxZ,1}, 
					{maxX, minY, minZ,1},
				}
			if elementMatrix then
				face1 = face1 * elementMatrix
				face2 = face2 * elementMatrix
			end
			
			local faces = {face1,face2}
			local drawLines, furthestNode, furthestDistance = {},{},0
			--Draw rectangular faces
			for k,face in ipairs (faces) do
				for i,coord3d in ipairs (face) do
					if not getScreenFromWorldPosition(coord3d[1], coord3d[2], coord3d[3], 10) then return end
					local nextIndex = i + 1
					if not face[nextIndex] then nextIndex = 1 end
					local targetCoord3d  = face[nextIndex]
					table.insert(drawLines, {coord3d, targetCoord3d})
					local camDistance = getDistanceBetweenPoints3D(camX, camY, camZ, unpack(coord3d))
					if camDistance > furthestDistance then
						furthestDistance = camDistance
						furthestNode = faces[k][i]
					end
				end
			end
			--Connect these faces together with four lines
			for i=1,4 do
				table.insert(drawLines, {faces[1][i], faces[2][i]})
			end
			--
			for i,draw in ipairs (drawLines) do
				if(not vectorCompare(draw[1], furthestNode)) and(not vectorCompare(draw[2], furthestNode)) then
					drawLine(unpack(draw))
				end
			end
		end
	end
end
addEventHandler("onClientRender", root, renderGridlines)

function drawLine(vecOrigin, vecTarget)
	local startX, startY = getScreenFromWorldPosition(vecOrigin[1], vecOrigin[2], vecOrigin[3],10)
	local endX,endY = getScreenFromWorldPosition(vecTarget[1], vecTarget[2], vecTarget[3], 10)
	if not startX or not startY or not endX or not endY then 
		return false
	end
	return dxDrawLine(startX, startY, endX, endY, colour, thickness, false)
end

function vectorCompare(vec1,vec2)
	if vec1[1] == vec2[1] and vec1[2] == vec2[2] and vec1[3] == vec2[3] then return true end
end

function getOffsetRelativeToElement(element, x, y, z)
	--Convert this into a lua matrix
	local elementMatrix = matrix{getElementMatrix(element)}
	elementMatrix = matrix{x, y, z} * elementMatrix
	return elementMatrix
end