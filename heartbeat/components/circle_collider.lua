--[[
Circular Collider
]]
local ffi = require "ffi"
local physics = require "love.physics"
local Vector2 = require "Heartbeat.Vector2"

local Collider = require("Heartbeat.components").Collider
local CircleCollider = class("CircleCollider", Collider)

-- Creates a new collider
-- > CircleCollider(radius, [density])
-- > CircleCollider(position, radius, [density])
function CircleCollider:new(a, b, c)
	if ffi.istype(Vector2, a) then
		self:Collider(physics.newCircleShape(a.x, a.y, b), c)
	else
		self:Collider(physics.newCircleShape(a), b)
	end
end

return CircleCollider
