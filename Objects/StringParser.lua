local StringParser = {}

--[[
	This is a generic name, idk what to think but this is supposed to check and get 
	strings easier, inspired by a lua vm
--]]

function StringParser.new(s)
	-- pre
	assert(type(s) == 'string')
	
	-- main
	local object = {}
	object.i = 1
	object.content = s
	
	function object.peek(j)
		-- pre
		j = j or 1
		assert(type(j) == 'number')
		
		-- main
		return object.content:sub(object.i, object.i + j - 1)
	end
	
	function object.pop(j)
		-- pre
		j = j or 1
		assert(type(j) == 'number')
		
		-- main
		local result = object.peek(j)
		
		object.i = object.i + j
		
		return result
	end
	
	function object.check(s, isRaw)
		-- pre
		assert(type(s) == 'string')
		
		-- main
		local a, b = object.content:find(s, object.i, isRaw)
		
		return a and object.i == a and object.peek(b - a + 1)
	end
	
	-- short for conditional pop
	function object.cPop(s, isRaw)
		-- pre
		assert(type(s) == 'string')
		
		-- main
		local result = object.check(s, isRaw)
		
		if result then
			object.pop(#result)
		end
		
		return result
	end
	
	-- the until functions returns the suceeding non pattern string, and
	-- the succeeding pattern string
	function object.peekUntil(stringPattern, isRaw)
		local a, b = object.content:find(stringPattern, object.i, isRaw)
		local resultA, resultB
		
		if a then
			resultA, resultB = 
				object.peek(a - object.i), 
				object.content:sub(a, b)
		end
		
		return resultA, resultB
	end
	
	function object.popUntil(stringPattern, isRaw)
		local resultA, resultB = object.peekUntil(stringPattern, isRaw)
		
		if resultA then
			object.pop(#resultA + #resultB)
		end
		
		return resultA, resultB
	end
	
	-- incase you want to reuse the object for some reason
	function object.reset(s)
		-- pre
		assert(type(s) == 'string')
		
		-- main
		object.content = s 
		object.i = 1
	end
	
	-- mainly for debugging
	function object.getState()
		local result = '\n%s\n%s^'
		local lines = object.content:split('\n')
		
		local i = object.i
		local j = 1
		
		while i > #lines[j] + 1 do
			i =  i-1 + #lines[j]
			j = j+ 1
			
			if not lines[j] then
				i = i - 1
				print(i, j, lines)
				break
			end
		end
		
		local arg1 = ''
		
		for i = math.max(j - 5, 1), j do
			arg1 = arg .. lines[i]
			
			if i ~= j then
				arg1 = arg1 .. '\n'
			end
		end
		
		result = result:format(
			arg1,
			(' '):rep(i - 1)
		)
		
		return result
	end
	
	function object.atEnd()
		return object.peek() == ''
	end
	
	function object.toEnd()
		return object.content:sub(object.i)
	end
	
	return object
end

function StringParser.parseString(str, args)
	--wip atm
	-- pre
	assert(type(str) == 'string')
	assert(not args or type(args) == 'table')

	local delimStart = args and args.delimStart or '"'
	local delimEnd = args and args.delimEnd or '"'

	if delimStart ~= delimEnd and delimStart ~= '"' and delimStart ~= '\'' then
		local a = #assert(delimStart:match('%[(=*)%['))
		local b = #assert(delimEnd:match('%](=*)%]'))
		assert(a == b)
	end

	-- main
	local resultContent = ''
	local parser = StringParser.new(str)
	
	while not parser.atEnd() do
		local c = parser.pop()
		
		if c:byte() < 32 or c:byte() >= 128 then
			c = '\\' .. c:byte()
		elseif c == delimStart then
			c = '\\' .. c
		elseif c == ']' 
			and parser.check(delimEnd:sub(2), true) 
			and delimEnd:match('%]') then
			local temp = parser.pop(#delimEnd)
			c = delimEnd:sub(1, -2) .. '\\]'
		end
		
		resultContent = resultContent.. c
	end

	return ('%s%s%s'):format(
		delimStart,
		resultContent,
		delimEnd
	)
end


return StringParser