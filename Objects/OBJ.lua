local OBJ = {}

local StringParser = require('Objects.StringParser')
Vector3 = {new=function(a,b,c)
	local result 
	result = setmetatable({
			X=a or 0,
			Y=b or 0,
	Z = c or 0;
			m = function()
				return (a^2+b^2+c^2)^.5
			end;
			Unit = function ()
				return result / result.m()
			end;
			Cross=function(_,d)
				return Vector3.new(
					  b * d.Z - c   * d.Y,
					-(a * d.Z - d.X * c),
					  a * d.Y - d.X * b
				)
			end;
		
		},{
			__div = function (_, d)
				return Vector3.new(a/d,b/d,c/d)
				
			end;
			__mul = function (_, d)
				return Vector3.new(d *a,d*b,d*c)
			end;
			__add = function(_, d)
				return Vector3.new(a+d.X,d.Y+b,d.Z+c)
			end;
			__sub = function(_, d)
				return Vector3.new(a-d.X,b-d.Y,c-d.Z)
			end;
	})

	return result

end}
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