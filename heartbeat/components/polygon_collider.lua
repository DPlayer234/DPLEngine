--[[
Collider for a polygon shape. Has at most 8 vertices.
]]
local ffi = require "ffi"
local physics = require "love.physics"
local Vector2 = require "Heartbeat.Vector2"

local Collider = require("Heartbeat.components").Collider
local PolygonCollider = class("PolygonCollider", Collider)

-- Creates a new collider
function PolygonCollider:new(vertices, density)
	if ffi.istype(Vector2, vertices[1]) then
		vertices = self:_vectorToNumberList(vertices)
	end
	self:Collider(physics.newPolygonShape(vertices), density)
end

return PolygonCollider
