--[[
Rectanglur Collider
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = require(currentModule .. ".collider")
local RectangleCollider = class("RectangleCollider", Collider)

-- Creates a new collider
-- > RectangleCollider(width, height, [density])
-- > RectangleCollider(x, y, width, height, angle, [density])
function RectangleCollider:new(a, b, c, d, e, f)
	if d == nil then
		self:Collider(physics.newRectangleShape(a, b), c)
	else
		self:Collider(physics.newRectangleShape(a, b, c, d, e), f)
	end
end

return RectangleCollider
