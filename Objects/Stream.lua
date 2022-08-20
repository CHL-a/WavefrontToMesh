--[[See stream in computer programming]]

local Stream = {}

function Stream.new(getFunc, appendFunc)
	-- pre
	assert(
		(
			getFunc == nil or 
			type(getFunc) == 'function'
		) and (
			appendFunc == nil or
			type(appendFunc) == 'function'
		)
	)
	
	-- main
	local object = {}
	
	function object:get(...)
		if getFunc then
			return getFunc(...)
		end
	end
	
	function object:append(...)
		if appendFunc then
			appendFunc(...)
		end
	end
	
	return object
end

return Stream