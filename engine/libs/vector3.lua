--[[
3D-Vector (using C-FFI Struct)
]]
local math = math
local ffi = require "ffi"

local TYPE_NAME = "Vector3" --#const

-- Define the C structs
ffi.cdef [[
typedef struct {
	double x;
	double y;
	double z;
} Engine_Vector3
]]

-- Get the type in Lua (also used for construction)
local Vector3 = ffi.typeof("Engine_Vector3")

-- Explicit methods
local methods = {
	-- Copy the current vector
	copy = function(self)
		return Vector3(self.x, self.y, self.z)
	end,
	-- Get the squared magnitude/length
	getMagnitudeSqr = function(self)
		return self.x * self.x + self.y * self.y + self.z * self.z
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
	-- Returns the cross product of two vectors
	cross = function(a, b)
		return Vector3(
			a.y * b.z - a.z * b.y,
			a.z * b.x - a.x * b.z,
			a.x * b.y - a.y * b.x
		)
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
		return Vector3(a.x * b.x, a.y * b.y, a.z * b.z)
	end,
	-- Memberwise division (/)
	divide = function(a, b)
		return Vector3(a.x / b.x, a.y / b.y, a.z / b.z)
	end,
	-- Memberwise modulo division (%)
	modulo = function(a, b)
		return Vector3(a.x % b.x, a.y % b.y, a.z % b.z)
	end,
	-- Memberwise exponent (^)
	power = function(a, b)
		return Vector3(a.x ^ b.x, a.y ^ b.y, a.z ^ b.z)
	end,
	-- Returns all components in order
	unpack = function(self)
		return self.x, self.y, self.z
	end,
	-- Type
	type = function() return TYPE_NAME end,
	typeOf = function(self, name) return name == TYPE_NAME end
}

-- Metatable, including operators
local meta = {
	-- Addition
	__add = function(a, b)
		return Vector3(a.x + b.x, a.y + b.y, a.z + b.z)
	end,
	-- Subtraction
	__sub = function(a, b)
		return Vector3(a.x - b.x, a.y - b.y, a.z - b.z)
	end,
	-- Vector * scalar or Scalar-Multiplication
	__mul = function(a, b)
		if type(a) == "number" then
			return Vector3(a * b.x, a * b.y, a * b.z)
		elseif type(b) == "number" then
			return Vector3(a.x * b, a.y * b, a.z * b)
		end
		return a.x * b.x + a.y * b.y + a.z * b.z
	end,
	-- Vector / scalar
	__div = function(a, b)
		if type(b) == "number" then
			return Vector3(a.x / b, a.y / b, a.z / b)
		end
		error("Invalid operation.")
	end,
	-- Unary minus
	__unm = function(a)
		return Vector3(-a.x, -a.y, -a.z)
	end,
	-- Equality
	__eq = function(a, b)
		if ffi.istype(Vector3, a) ~= ffi.istype(Vector3, b) then return false end
		return a.x == b.x and a.y == b.y and a.z == b.z
	end,
	-- Nicer string format
	__tostring = function(self)
		return ("Vector3: %.3f, %.3f, %.3f"):format(self.x, self.y, self.z)
	end,
	__index = methods
}

-- Assign metatable
ffi.metatype(Vector3, meta)

return Vector3
