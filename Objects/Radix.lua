local Radix = {}
local Static = require('Objects.Static')

function Radix.new(hashMap, decimal)
	-- pre
	decimal = decimal or '.'
	
	assert(type(hashMap) == 'table' and hashMap[0])
	
	for i, v in next, hashMap do
		assert(type(i) == 'number')
		assert(decimal ~= v)
	end
	
	local flipped = Static.table.flip(hashMap)
	local base = #hashMap + 1
	
	-- main
	local object = {}
	object.mantissaLimit = 64
	
	function object.getNumericalValue(...)
		local result = {}
		
		for _, a in next, {...} do
			-- pre
			assert(type(a) == 'table')
			
			-- main
			local subResult = 0
			
			local decimalPoint = table.find(a, decimal)
			
			for i = 1, #a do
				local v = a[i]
				
				-- to do
				local exponent = 
					decimalPoint 
						and decimalPoint ~= i and (
							decimalPoint - i - 
							(decimalPoint > i and 1 or 0)
						) 
						or #a - i
					
					
				if v ~= decimal then
					subResult =subResult+ flipped[v] * base ^ exponent
				end
			end
			
			table.insert(result, subResult)
		end
		
		
		return unpack(result)
	end
	
	function object.getDigitSequence(...)
		local result = {}
		
		for _, n in next, {...} do
			-- pre
			assert(type(n) == 'number' and n >= 0)
			
			-- main
			local subResult = {}
			
			local digitPosition = Static.math.getDigits(math.floor(n), base) - 1
			
			repeat
				local digit = Static.math.getDigit(n, base, digitPosition)
				
				n =n -digit * base ^ digitPosition
				
				table.insert(subResult, hashMap[digit])
				
				if digitPosition == 0 and n ~= 0 then
					table.insert(subResult, decimal)
				end
				
				digitPosition =digitPosition- 1
			until 
				(n == 0 and digitPosition <= -1) or 
				object.mantissaLimit > 0 and -object.mantissaLimit >= digitPosition
			
			table.insert(result, subResult)
		end
		return unpack(result)
	end
	
	return object
end

return Radix