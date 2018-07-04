--[[
A wrapper for Löve-graphics
Functions to draw Drawable objects.
]]
local lgraphics = require "love.graphics"
local Vector2 = require "Heartbeat::Vector2"

local assert = assert

local graphics = {}

-- Drawing via vectors
function graphics.draw(drawable, quad, pos, angle, scale, center)
	if not quad:typeOf("Quad") then
		quad, pos, angle, scale, center = nil, quad, pos, angle, scale
	end

	if scale == nil then scale = Vector2.one end
	if center == nil then center = Vector2.zero end

	assert(pos:typeOf("Vector2"), "Expected a Vector2.")

	if quad == nil then
		return lgraphics.draw(drawable, pos.x, pos.y, angle, scale.x, scale.y, center.x, center.y)
	end

	return lgraphics.draw(drawable, quad, pos.x, pos.y, angle, scale.x, scale.y, center.x, center.y)
end

-- Drawing via a transform and center point
function graphics.drawTransform(drawable, quad, transform, center)
	if not quad:typeOf("Quad") then
		quad, transform, center = nil, quad, transform
	end

	assert(transform:typeOf("Transform"), "Expected a Transform.")

	local pos   = transform:getPosition()
	local scale = transform:getScale()
	local angle = transform:getAngle()

	if quad == nil then
		return graphics.draw(drawable, quad, pos, angle, scale, center)
	end

	return graphics.draw(drawable, quad, pos, angle, scale, center)
end

return graphics
