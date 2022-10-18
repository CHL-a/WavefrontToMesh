local MESH = {}
local obj = require('Objects.OBJ')
local ByteStream = require('Objects.ByteStream')
local StringRadix = require('Objects.StringRadix')
local Static = require('Objects.Static')

local function debugStream(d)
	local e = {StringRadix.hexdecimal.getDigitSequence(unpack(d))}

	for a, b in next, e do
		e[a] = ('0'):rep(2-#b) .. b
	end

	print(('(%s)'):format(table.concat(e, ' ')))
end

---@param a OBJ.object
---@return string
function MESH.convertOBJToMESH1_01(a)
	local result = 'version 1.01\n' .. (#a.faces) .. '\n'

	for _, b in next, a.faces do
		local mid, c, d = a.vertexes[b[1]], a.vertexes[b[2]], a.vertexes[b[3]]
	
		local e, f = mid.sub(c), mid.sub(d)
		local cross = e.getCrossProduct(f).getUnit()

		for g = 1, 3 do
			local h = a.vertexes[b[g]]

			result = result .. ('[%s,%s,%s][%s,%s,%s][0,1,0]'):format(
				h.x,h.y,h.z,
				cross.x,cross.y,cross.z
			)
		end
	end

	return result
end

---@deprecated
---Note the bug that miscolored faces may appear
function MESH.convertOBJToMESH(a)
	local subResult = {('version 2.00'):byte(1, 12)}
	
	local stream = ByteStream.new(subResult)
	-- 5 unknown bytes
	stream.appendBytes(
		0x0A, 
		0x0C, 0x00, 
		0x28, 
		0x0C
	)
	--debugStream(subResult)

	-- vert and vn amount
	stream.appendInt(#a.faces * 3, true)
	
	-- face amount
	stream.appendInt(#a.faces, true)
	
	-- per vertice and vn
	for _, b in next, a.faces do
		---@type Vector3.object
		local mid, v, w = 
			a.vertexes[b[1]],
			a.vertexes[b[2]],
			a.vertexes[b[3]]

		--local isMutated = tostring(mid.x):sub(1, 6) == '13.276'

		--[[
		if isMutated then
			print(mid.toString()..'\n  '..v.toString()..'\n  '..w.toString())
		end
		--]]
		
		-- cross product
		local vVect = mid.sub(v)
		local wVect = mid.sub(w)
		
		local cross = vVect.getCrossProduct(wVect).getUnit()

		--[[
		if isMutated then
			print(vVect.getCrossProduct(wVect).getMagnitude(), cross.toString())
		end
		--]]
		
		-- append per vertice struct: vertice, vn and constant
		for c = 1, 3 do
			local d = a.vertexes[b[c]]
			
			stream.appendFloat(d.x, true)
				.appendFloat(d.y, true)
				.appendFloat(d.z, true)
				.appendFloat(cross.x, true)
				.appendFloat(cross.y, true)
				.appendFloat(cross.z, true)
				.appendInt(0, true)
				.appendFloat(1, true)
				.appendInt(0, true)
				.appendBytes(0xFF, 0xFF, 0xFF, 0xFF)
		end
	end

	-- facecollectio
	for i = 0, (#a.faces * 3) - 1 do
		stream.appendInt(i, true)
	end
	
	local result = ''
	
	for i, v in next, subResult do
		result = result.. string.char(v)
	end
	
	return result
end

return MESH
