--[[
Entity Transform
]]
local math = math
local ffi = require "ffi"

-- Define the C structs
ffi.cdef [[
typedef struct {
	Engine_Vector2 position;
	Engine_Vector2 velocity;
	Engine_Rotation rotation;
} Engine_Transform
]]

-- Get the type in Lua (also used for construction)
local Transform = ffi.typeof("Engine_Transform")

-- Explicit methods
local methods = {
	-- Applies the velocity given the time passed
	applyVelocity = function(self, dt)
		self.position = self.position + self.velocity * dt
	end
}

-- Metatable, including operators
local meta = {
	-- Nicer string format
	__tostring = function(self)
		return ("Transform: Pos. %.3f, %.3f"):format(self.position:unpack())
	end,
	__index = methods
}

-- Assign metatable
ffi.metatype(Transform, meta)

return Transform
