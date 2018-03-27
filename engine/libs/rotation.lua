--[[
2D-Rotation object
]]
local math = math
local ffi = require "ffi"

-- Define the C structs
ffi.cdef [[
typedef struct {
	double angle;
	double xScale;
	double yScale;
} Engine_Rotation
]]

-- Get the type in Lua (also used for construction)
local Rotation = ffi.typeof("Engine_Rotation")

-- Explicit methods
local methods = {
	-- Returns a new rotation that is flipped horizontally
	flipHorizontal = function(self)
		return Rotation(
			self.angle,
			-self.xScale,
			self.yScale
		)
	end,
	-- Returns a new rotation that is flipped vertically
	flipVertical = function(self)
		return Rotation(
			self.angle,
			self.xScale,
			-self.yScale
		)
	end,
	-- Returns a new rotation that is rotated by the given angle
	rotate = function(self, angle)
		return Rotation(
			(self.angle + angle + math.pi) % (math.pi * 2) - math.pi,
			self.xScale,
			self.yScale
		)
	end
}

-- Metatable, including operators
local meta = {
	-- Nicer string format
	__tostring = function(self)
		return ("Rotation: %.3frad %.3fx%.3f"):format(self.angle, self.xScale, self.yScale)
	end,
	__index = methods
}

-- Assign metatable
ffi.metatype(Rotation, meta)

return Rotation
