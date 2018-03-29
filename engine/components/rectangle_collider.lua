--[[
Rectanglur Collider
]]
local ffi = require "ffi"
local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"

local Collider = require("Engine.components").Collider
local RectangleCollider = class("RectangleCollider", Collider)

-- Creates a new collider
-- > RectangleCollider(dimensions, [density])
-- > RectangleCollider(position, dimensions, [angle, density])
function RectangleCollider:new(a, b, c, d)
	if ffi.istype(Vector2, b) then
		self:Collider(physics.newRectangleShape(a.x, a.y, b.x, b.y, c), d)
	else
		self:Collider(physics.newRectangleShape(a.x, a.y), b)
	end
end

return RectangleCollider
