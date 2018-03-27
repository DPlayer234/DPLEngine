--[[
Loads all libraries in the correct order
]]
local currentModule = miscMod.getModule(..., true)

-- Load the libraries
return {
	Vector2   = require(currentModule .. ".vector2"),
	Rotation  = require(currentModule .. ".rotation"),
	Transform = require(currentModule .. ".transform")
}
