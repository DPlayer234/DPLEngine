--[[
Rectanglur Collider
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = require(currentModule .. ".collider")
local RectangleCollider = class("RectangleCollider", Collider)

-- Creates a new collider
function RectangleCollider:new(width, height, density)
	self:Collider(physics.newRectangleShape(width, height), density)
end

return RectangleCollider
