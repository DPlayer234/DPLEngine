--[[
2D-Vector (using C-FFI Struct)
]]
local math = math
local ffi = require "ffi"

-- Define the C structs
ffi.cdef [[
typedef struct {
	double x;
	double y;
} Engine_Vector2
]]

-- Get the type in Lua (also used for construction)
local Vector2 = ffi.typeof("Engine_Vector2")

-- Explicit methods
local methods = {
	-- Copy the current vector
	copy = function(self)
		return Vector2(self.x, self.y)
	end,
	-- Get the squared magnitude/length
	getMagnitudeSqr = function(self)
		return self.x * self.x + self.y * self.y
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
	getAngle = function(self)
		return math.atan2(self.y, self.x)
	end,
	-- Returns a new vector, which is the original vector rotated by rad radians around origin or (0, 0)
	rotate = function(self, rad, origin)
		if origin == nil then origin = Vector2(0, 0) end
		self = self - origin

		local sin = math.sin(rad)
		local cos = math.cos(rad)

		return Vector2(
			self.x * cos - self.y * sin,
			self.y * cos + self.x * sin
		) + origin
	end,
	-- Returns both components in order
	unpack = function(self)
		return self.x, self.y
	end
}

-- Metatable, including operators
local meta = {
	-- Addition
	__add = function(a, b)
		return Vector2(a.x + b.x, a.y + b.y)
	end,
	-- Subtraction
	__sub = function(a, b)
		return Vector2(a.x - b.x, a.y - b.y)
	end,
	-- Vector * scalar or Scalar-Multiplication
	__mul = function(a, b)
		if type(a) == "number" then
			return Vector2(a * b.x, a * b.y)
		elseif type(b) == "number" then
			return Vector2(a.x * b, a.y * b)
		end
		return a.x * b.x + a.y * b.y
	end,
	-- Vector / scalar
	__div = function(a, b)
		if type(b) == "number" then
			return Vector2(a.x / b, a.y / b)
		end
		error("Invalid operation.")
	end,
	-- Memberwise multiplication
	__concat = function(a, b)
		return Vector2(a.x * b.x, a.y * b.y)
	end,
	-- Unary minus
	__unm = function(a)
		return Vector2(-a.x, -a.y)
	end,
	-- Nicer string format
	__tostring = function(self)
		return ("Vector2: %.3f, %.3f"):format(self.x, self.y)
	end,
	__index = methods
}

-- Assign metatable
ffi.metatype(Vector2, meta)

return Vector2
