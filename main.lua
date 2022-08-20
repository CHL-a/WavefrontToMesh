local settings = {
	clearInput = false;
	clearOutput = false
}

-- get input text
local i = io.open('./in.txt', 'r+b')
assert(i)

-- get obj struct
local obj = require('Objects.OBJ')
	.new(i:read('*a'))

i:close()

-- get mesh content string
local meshContent = require('Objects.MESH').convertOBJToMESH(obj)

-- put it into output file
local out = io.open('./out.mesh', 'w+b')
assert(out)
out:write(meshContent)
out:close()

if settings.clearInput then
	local temp = io.open('./in.txt', 'w+')
	assert(temp)
	temp:write''
	temp:close()
end

if settings.clearOutput then
	local temp = io.open('./out.mesh','w+')
	assert(temp)
	temp:write('')
	temp:close()
end

print('done')