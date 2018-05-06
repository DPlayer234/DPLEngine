--[[
4D-Vector (using C-FFI Struct)
]]
local math = math
local type = type
local ffi = require "ffi"

local TYPE_NAME = "Vector4" --#const

-- Define the C structs
ffi.cdef [[
struct Heartbeat_Vector4 {
	double x, y, z, w;
};
]]

-- Get the type in Lua (also used for construction)
local Vector4 = ffi.typeof("struct Heartbeat_Vector4")

-- Constants
local const = {
	zero  = function() return Vector4( 0, 0, 0, 0) end,
	one   = function() return Vector4( 1, 1, 1, 1) end,
	left  = function() return Vector4(-1, 0, 0, 0) end,
	right = function() return Vector4( 1, 0, 0, 0) end,
	up    = function() return Vector4( 0,-1, 0, 0) end,
	down  = function() return Vector4( 0, 1, 0, 0) end,
	back  = function() return Vector4( 0, 0,-1, 0) end,
	front = function() return Vector4( 0, 0, 1, 0) end,
}

-- Explicit methods
local methods = {
	-- Copy the current vector
	copy = function(self)
		return Vector4(self.x, self.y, self.z, self.w)
	end,
	-- Get the squared magnitude/length
	getMagnitudeSqr = function(self)
		return self.x * self.x + self.y * self.y + self.z * self.z + self.w * self.w
	end,
	-- Get the magnitude
	getMagnitude = function(self)
		return self:getMagnitudeSqr() ^ 0.5
	end,
	-- Gets the squared distance between two vectors
	getDistanceSqr = function(a, b)
		return (a - b):getMagnitudeSqr()
	end,
	-- Gets the distance between two vectors
	getDistance = function(a, b)
		return (a - b):getMagnitude()
	end,
	-- Returns a new vector with the same direction as the original, but a magnitude of 1
	getNormalized = function(self)
		return self / self:getMagnitude()
	end,
	-- Gets the angle of a vector in relation to the coordinate grid
	getAngle = function(self)
		return self:getAngleTo(Vector4(1, 0, 0, 0))
	end,
	-- Gets the angle between two vectors
	getAngleTo = function(a, b)
		return (a * b) / (a:getMagnitude() * b:getMagnitude())
	end,
	-- Returns the result of a point multiplication.
	point = function(a, b)
		return a.x * b.x + a.y * b.y + a.z * b.z + a.w * b.w
	end,
	-- Memberwise addition (+)
	add = function(a, b)
		return a + b
	end,
	-- Memberwise subtraction (-)
	subtract = function(a, b)
		return a - b
	end,
	-- Memberwise multiplication (*)
	multiply = function(a, b)
		return Vector4(a.x * b.x, a.y * b.y, a.z * b.z, a.w * b.w)
	end,
	-- Memberwise division (/)
	divide = function(a, b)
		return Vector4(a.x / b.x, a.y / b.y, a.z / b.z, a.w / b.w)
	end,
	-- Memberwise modulo division (%)
	modulo = function(a, b)
		return Vector4(a.x % b.x, a.y % b.y, a.z % b.z, a.w % b.w)
	end,
	-- Memberwise exponent (^)
	power = function(a, b)
		return Vector4(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z, a.w ^ b.w)
	end,
	-- Returns all components in order
	unpack = function(self)
		return self.x, self.y, self.z, self.w
	end,
	-- Returns the largest/smallest component
	max = function(self)
		return math.max(self.x, self.y, self.z, self.w)
	end,
	min = function(self)
		return math.min(self.x, self.y, self.z, self.w)
	end,
	-- Type
	type = function() return TYPE_NAME end,
	typeOf = function(self, name) return name == TYPE_NAME end,
	is = function(value) return ffi.istype(Vector4, value) end
}

-- Metatable, including operators
local meta = {
	-- Addition
	__add = function(a, b)
		return Vector4(a.x + b.x, a.y + b.y, a.z + b.z, a.w + b.w)
	end,
	-- Subtraction
	__sub = function(a, b)
		return Vector4(a.x - b.x, a.y - b.y, a.z - b.z, a.w - b.w)
	end,
	-- Vector * scalar or Scalar-Multiplication
	__mul = function(a, b)
		if type(a) == "number" then
			return Vector4(a * b.x, a * b.y, a * b.z, a * b.w)
		elseif type(b) == "number" then
			return Vector4(a.x * b, a.y * b, a.z * b, a.w * b)
		end
		error("Invalid operation.")
	end,
	-- Vector / scalar
	__div = function(a, b)
		if type(b) == "number" then
			return Vector4(a.x / b, a.y / b, a.z / b, a.w / b)
		end
		error("Invalid operation.")
	end,
	-- Unary minus
	__unm = function(a)
		return Vector4(-a.x, -a.y, -a.z, -a.w)
	end,
	-- Equality
	__eq = function(a, b)
		if Vector4.is(a) ~= Vector4.is(b) then return false end
		return a.x == b.x and a.y == b.y and a.z == b.z and a.w == b.w
	end,
	-- Nicer string format
	__tostring = function(self)
		return ("Vector4: %.3f, %.3f, %.3f, %.3f"):format(self.x, self.y, self.z, self.w)
	end,
	-- Indexer
	__index = function(self, key)
		if const[key] then
			return const[key]()
		end
		return methods[key]
	end
}

-- Assign metatable
ffi.metatype(Vector4, meta)

return Vector4
