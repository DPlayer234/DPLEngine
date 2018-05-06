--[[
Physics Material to be applied to Colliders
]]
local class = require "Heartbeat::class"

local Material = class("Material")

local DEFAULT_FRICTION = 0.2 --#const
local DEFAULT_BOUNCINESS = 0 --#const

-- Creates a new Material
function Material:new()
	self.friction = DEFAULT_FRICTION
	self.bounciness = DEFAULT_BOUNCINESS
end

return Material
