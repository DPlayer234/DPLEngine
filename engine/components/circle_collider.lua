--[[
Circular Collider
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = require(currentModule .. ".collider")
local CircleCollider = class("CircleCollider", Collider)

-- Creates a new collider
-- > CircleCollider(radius, [density])
-- > CircleCollider(x, y, radius, [density])
function CircleCollider:new(a, b, c, d)
	if c == nil then
		self:Collider(physics.newCircleShape(a), b)
	else
		self:Collider(physics.newCircleShape(a, b, c), d)
	end
end

return CircleCollider
