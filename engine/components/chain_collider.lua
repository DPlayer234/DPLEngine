--[[
Collider made up of several line segments
]]
local physics = require "love.physics"

local Collider = require("Engine.components").Collider
local ChainCollider = class("ChainCollider", Collider)

-- Creates a new collider
function ChainCollider:new(loop, points, density)
	self:Collider(physics.newChainShape(loop, points), density)
end

return ChainCollider
