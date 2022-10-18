--[[spec]]
---@class Vector3
---@field new fun(x: number?, y:number?, z:number?):Vector3.object

---@class Vector3.object
---@field x number
---@field y number
---@field z number
---@field div fun(a: number): Vector3.object
---@field mult fun(a: number): Vector3.object
---@field sub fun(a: Vector3.object): Vector3.object
---@field add fun(a: Vector3.object): Vector3.object
---@field inverse fun(): Vector3.object
---@field getMagnitude fun(): number
---@field getUnit fun(): Vector3.object
---@field getCrossProduct fun(a: Vector3.object): Vector3.object
---@field toString fun(): string

--[[code]]
---@type Vector3
local Vector3 = {}

---returns vector3 object
---@param x number?
---@param y number?
---@param z number?
---@return Vector3.object
Vector3.new = function (x, y, z)
	-- pre
	x = x or 0
	y = y or 0
	z = z or 0

	---@type Vector3.object
	local object = {}
	object.x = x
	object.y = y
	object.z = z

	---@param a Vector3.object
	---@return Vector3.object
	object.add = function(a)return Vector3.new(object.x + a.x,object.y + a.y,object.z + a.z)end

	---@return Vector3.object
	object.inverse = function()return Vector3.new(-object.x,-object.y,-object.z)end

	---@param a Vector3.object
	---@return Vector3.object
	object.sub = function (a)return object.add(a.inverse())end

	---@param a number
	---@return Vector3.object
	object.mult = function (a)return Vector3.new(object.x*a,object.y*a,object.z*a)end

	---@param a number
	---@return Vector3.object
	object.div = function(a)return Vector3.new(object.x/a,object.y/a,object.z/a)end

	---@return number
	object.getMagnitude = function()return(object.x^2+object.y^2+object.z^2)^.5;end

	---@return Vector3.object
	object.getUnit = function()return object.div(object.getMagnitude())end

	---@param a Vector3.object
	object.getCrossProduct = function (a)
		return Vector3.new(
			  object.y * a.z - a.y * object.z,
			-(object.x * a.z - a.x * object.z),
			  object.x * a.y - a.x * object.y
		)
	end

	object.toString = function()
		return ('(%s,%s,%s)'):format(''.. object.x, '' .. object.y, '' .. object.z)
	end

	return object
end

return Vector3