--[[
	Lua replication of a byte stream
	Note: 
	
	Most sigificant bit
	 v
	+--------+
	|12345678| <- this box represents a collection of 8 bits or one byte
	+--------+
	        ^
	Least Sigificant bit
	
	 * numbers indicate bit position not an actual possible bit value
--]]
local ByteStream = {}
local Stream = require('Objects.Stream')
local Static = require('Objects.Static')
local StringRadix = require('Objects.StringRadix')

function ByteStream.valueToFuncHelper(value)
	-- pre
	assert(type(value) == 'string' or type(value) == 'table')
	
	return function(i)
		return 
			type(value) == 'string' and 
				value:sub(i, i):byte() or
			type(value) == 'table' and 
				value[i]
	end,function(...)
		for _, v in next, {...} do
			if type(value) == 'string' then
				value = value.. string.char(v)
			elseif type(value) == 'table' then
				table.insert(value, v)
			end
		end
	end
end


function ByteStream.new(v, app)
	-- pre
	local objectStream = Stream.new(
		unpack(
			not app 
				and {ByteStream.valueToFuncHelper(v)}
				or {v, app}
		)
	)

	-- main
	local object
	
	object = {
		-- getting
		bitPointer = 1;
		bytePointer = 1;
		
		increment = function(dir)
			object.bitPointer = object.bitPointer+ 1

			if object.bitPointer >= 9 then
				object.bitPointer =object.bitPointer% 8
				object.bytePointer =object.bytePointer% (dir or 1)
			end
		end;
		
		getBits = function(n)
			-- pre
			n = n or 1
			assert(type(n) == 'number', 'not number')
			assert(n >= 1, 'n < 1')
			assert(n % 1 == 0, 'non integer: ' .. n)

			-- main
			local result = 0

			for i = 1, n do
				local byte = objectStream:get(object.bytePointer)
				assert(byte, 'missing byte: reached end of stream')

				result =result+ 
					Static.math.getDigit(byte, 2, 8 - object.bitPointer) * 
					2 ^ (n - i)

				object.increment()
			end

			return result
		end;
		
		getBytes = function(n)
			-- pre
			n = n or 1
			assert(type(n) == 'number' and n ~= 0 and n % 1 == 0, tostring(n))

			-- main
			local result

			if n >= 1 then
				-- big endian
				result = object.getBits(n * 8)
			else
				-- little endian
				result = 0

				for byte = 1, -n do
					result =result+ object.getBytes() * 256 ^ (byte - 1)
				end
			end

			return result
		end;
		
		getString = function (len)
			-- pre
			len = len or 1
			assert(len % 1 == 0, type(len) .. '|' .. tostring(len))

			-- main
			local result = ''

			for i = 1, math.abs(len) do
				local byte = object.getBytes()
			
				result = result .. string.char(byte)
			end

			if len < 0 then
				result = result:reverse()
			end

			return result
		end;
		
		isBitOne = function ()
			return object.getBits() == 1
		end;
		
		-- checking
		checkBytes = function(...)
			-- main
			local resultA = true
			local resultB
			
			for i = 1, select('#', ...) do
				local byte = object.getBytes()
				if select(i, ...) ~= byte then
---@diagnostic disable-next-line: cast-local-type
					resultA = i
					resultB = byte
					break
				end
			end
			
			return resultA, resultB
		end,
		
		assertBytes = function(e, ...)
			-- pre
			e = e or 'byte check fail:'
			
			-- main
			local a, b = object.checkBytes(...)
			
			if a ~= true then
				e =e .. '\n'
				local f = ''
				for i = 1, select('#', ...) do
					local expByte = select(i, ...)
					e =e.. expByte .. ' '
					
					if i == a then
						f = f..('%s\n%s^'):format(b, (' '):rep(#f))
						break
					else
						f =f.. expByte .. ' '
					end
				end
				
				error(e ..'\n' .. f)
			end
		end,
		
		getFloat = function(isLilEnd)
			local temp = ByteStream['temp']
			local tempA = {}
			
			for _ = 1, 4 do
				local b = object.getBytes()
				table.insert(tempA, isLilEnd and 1 or #tempA, b)
			end
			
			for _ = 1, 4 do
				temp.appendBytes(table.remove(tempA, 1))
			end
			
			local a, b, c = temp.isBitOne(), temp.getBytes(), temp.getBits(23)
			
			local sign = a and -1 or 1
			local exponent = b - (2 ^ 7 - 1)
			local mantissa = c / (2 ^ 23) + 1
			
			
			return mantissa * (2 ^ exponent) * sign
		end,
		
		-- peeking
		peekByte = function(n)
			n = n or 1
			return objectStream:get(object.bytePointer + n - 1)
		end,
		
		-- appending
		appendingBitPosition = 1;
		appendingByte = 0;
		
		appendBits = function (...)
			for i = 1, select('#', ...) do
				-- pre
				local n = select(i, ...)
				assert(n == 1 or n == 0)

				-- main
				object.appendingByte =object.appendingByte+ n * 2 ^ (8 - object.appendingBitPosition)
				object.appendingBitPosition = object.appendingBitPosition+ 1
				
				if object.appendingBitPosition >= 9 then
					object.appendingBitPosition =object.appendingBitPosition% 8
					objectStream:append(object.appendingByte)
					object.appendingByte = 0
				end
			end
			
			return object
		end;
		
		appendBytes = function (...)
			for i = 1, select('#', ...) do
				-- pre
				local n = select(i, ...)
				assert(
					n % 1 == 0 and n >= 0,
					('non natural number: %s\n' ..
					'traceback: %s'):format(
						n,
						debug.traceback()
					)
					
				)
				
				
				-- main
				local a = ''
				for i = 7, 0, -1 do
					local b = Static.math.getDigit(n, 2, i)
					object.appendBits(
						b
					)
					a =a..b
				end
			end
			return object
		end;
		
		appendInt = function(n, isLilend)
			-- pre
			assert(n % 1 == 0)
			
			-- main
			for i = 1, 4 do
				local j =isLilend and i - 1 or 4 - i
				local k = 
					Static.math.getDigit(n, 256, j)

				
				object.appendBytes(k)
			end
			
			return object
		end,
		
		appendFloat = function(n, isLilEnd)
			local m, e = math.frexp(n)
			local sign = m < 0 and 1 or 0
			
			m = math.ceil(
				math.max(
					math.abs(m) - .5,
					0
				)
				* 2 ^ 24
			)
			e =e+ 126
			
			local temp = {
				sign * 2 ^ 7 +
				math.floor(e / 2),
				
				(e % 2) * (2 ^ 7) + 
				math.floor(m / 2 ^ 16),
				
				math.floor(m / 2 ^ 8) % 2 ^ 8,
				
				m % 2 ^ 8
			}
			
			--[[
			local temp = ByteStream.temp

			temp.appendBits(sign)
			temp.appendBytes(e)
			
			for i = 22, 0, -1 do
				temp.appendBits(
					Static.math.getDigit(m, 2, i)
				)
			end
			--]]
			
			if isLilEnd then
				local a, b = unpack(temp, 1, 2)
				
				temp[1], temp[2] = temp[4], temp[3]
				temp[4], temp[3] = a, b
				
				--[[
				local a, b, c = temp.getBytes(),
					temp.getBytes(),
					temp.getBytes()
				
				temp.appendBytes(
					temp.getBytes(),
					c, b, a
				)
				--]]
			end

			for i = 1, 4 do
				object.appendBytes(temp[i])
			end
			
			return object
		end,
		
		-- end checking
		atEnd = function()
			return not objectStream:get(object.bytePointer)
		end,
	}
	
	return object
end

local temp = ByteStream.new{}
ByteStream.temp = temp

return ByteStream
