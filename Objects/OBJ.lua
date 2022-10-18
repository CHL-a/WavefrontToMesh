local OBJ = {}

local StringParser = require('Objects.StringParser')
local Vector3 = require('Objects.Vector3')


---@class OBJ.object
---@field faces integer[][]
---@field vertexes Vector3.object[]

function OBJ.new(content)
	local parser = StringParser.new(content)
	
	local object = {
		vertexes = {};
		faces = {}
	}
	
	while not parser.atEnd() do
		local prefix = parser.peek(2)
		
		if prefix == 'v ' then
			parser.pop(2)
			
			local x = parser.popUntil(' ')
			local y = parser.popUntil(' ')
			local z = parser.popUntil('\n')
			
			x, y, z = 
				tonumber(x),
				tonumber(y),
				tonumber(z)

			local temp = x and y and z
			if not temp then
			assert(temp, parser.getState())
			end
			table.insert(object.vertexes,Vector3.new(x,y,z))
		elseif prefix == 'f ' then
			parser.pop(2)
			
			local vertA = parser.popUntil(' ')
			local vertB = parser.popUntil(' ')
			local vertC = parser.popUntil('\n') or parser.toEnd()
			
			vertA, vertB, vertC = 
				tonumber(vertA),
				tonumber(vertB),
				tonumber(vertC)
			
			assert(vertA and vertB and vertC)
			
			table.insert(object.faces, {vertA, vertB, vertC})
		elseif not parser.popUntil('\n') then
			break
		end
	end
	
	return object
end

return OBJ