--[[
Collider for a polygon shape. Has at most 8 vertices.
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = require(currentModule .. ".collider")
local PolygonCollider = class("PolygonCollider", Collider)

-- Creates a new collider
function PolygonCollider:new(vertices, density)
	self:Collider(physics.newPolygonShape(vertices), density)
end

return PolygonCollider
