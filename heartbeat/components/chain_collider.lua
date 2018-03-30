--[[
Collider made up of several line segments
]]
local ffi = require "ffi"
local physics = require "love.physics"
local Vector2 = require "Heartbeat.Vector2"

local Collider = require("Heartbeat.components").Collider
local ChainCollider = class("ChainCollider", Collider)

-- Creates a new collider
function ChainCollider:new(loop, points, density)
	if ffi.istype(Vector2, points[1]) then
		points = self:_vectorToNumberList(points)
	end
	self:Collider(physics.newChainShape(loop, points), density)
end

return ChainCollider
