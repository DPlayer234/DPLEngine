--[[
Circular Collider
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = require(currentModule .. ".collider")
local CircleCollider = class("CircleCollider", Collider)

-- Creates a new collider
function CircleCollider:new(radius, density)
	self:Collider(physics.newCircleShape(radius), density)
end

return CircleCollider
