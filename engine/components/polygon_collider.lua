--[[
Collider for a polygon shape. Has at most 8 vertices.
]]
local physics = require "love.physics"

local Collider = require("Engine.components").Collider
local PolygonCollider = class("PolygonCollider", Collider)

-- Creates a new collider
function PolygonCollider:new(vertices, density)
	self:Collider(physics.newPolygonShape(vertices), density)
end

return PolygonCollider
