local MESH = {}
local obj = require('a.OBJ')
local ByteStream = require('a.ByteStream')
local StringRadix = require('a.StringRadix')
local Static = require('a.Static')

local function debugStream(d)
	local e = {StringRadix.hexdecimal.getDigitSequence(unpack(d))}

	for a, b in next, e do
		e[a] = ('0'):rep(2-#b) .. b
	end

	print(('(%s)'):format(table.concat(e, ' ')))
end

function MESH.convertOBJToMESH(a)
	local subResult = {('version 2.00'):byte(1, 12)}
	
	local stream = ByteStream.new(subResult)
	
	--debugStream(subResult)

	-- 5 unknown bytes
	stream.appendBytes(0x0A, 0x0C, 0x00, 0x28, 0x0C)
	--debugStream(subResult)

	-- vert and vn amount
	stream.appendInt(#a.faces * 3, true)
	
	-- face amount
	stream.appendInt(#a.faces, true)
	
	-- per vertice and vn
	for A, b in next, a.faces do
		local mid, v, w = 
			a.vertexes[b[1]],
			a.vertexes[b[2]],
			a.vertexes[b[3]]
		
		-- cross product
		local vVect = mid - v
		local wVect = mid - w
		
		local cross = vVect:Cross(wVect).Unit()
		
		-- append per vertice struct: vertice, vn and constant
		for c = 1, 3 do
			local d = a.vertexes[b[c]]
			
			stream.appendFloat(d.X, true)
				.appendFloat(d.Y, true)
				.appendFloat(d.Z, true)
				.appendFloat(cross.X, true)
				.appendFloat(cross.Y, true)
				.appendFloat(cross.Z, true)
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
