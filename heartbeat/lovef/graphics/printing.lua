--[[
A wrapper for Löve-graphics
Functions to print text on the screen.
]]
local lgraphics = require "love.graphics"
local Vector2 = require "Heartbeat::Vector2"

local assert = assert

local graphics = {}

-- Draws text
function graphics.print(font, text, pos, angle, scale, center)
	assert(font:typeOf("Font"), "Expected a Font.")

	if scale == nil then scale = Vector2.one end
	if center == nil then center = Vector2.zero end

	return lgraphics.print(text, font, pos.x, pos.y, angle, scale.x, scale.y, center.x, center.y)
end

-- Draws text with alignment
function graphics.printAligned(font, text, wraplimit, alignmode, pos, angle, scale, center)
	assert(font:typeOf("Font"), "Expected a Font.")

	if scale == nil then scale = Vector2.one end
	if center == nil then center = Vector2.zero end

	return lgraphics.printf(text, font, pos.x, pos.y, wraplimit, alignmode, angle, scale.x, scale.y, center.x, center.y)
end

-- Printing text via a transform and center point
function graphics.printTransform(font, text, transform, center)
	assert(transform:typeOf("Transform"), "Expected a Transform.")

	local pos   = transform:getPosition()
	local scale = transform:getScale()
	local angle = transform:getAngle()

	return graphics.print(font, text, pos, angle, scale, center)
end

-- Printing text with alignment via a transform and center point
function graphics.printAlignedTransform(font, text, wraplimit, alignmode, transform, center)
	assert(transform:typeOf("Transform"), "Expected a Transform.")

	local pos   = transform:getPosition()
	local scale = transform:getScale()
	local angle = transform:getAngle()

	return graphics.printAligned(font, text, wraplimit, alignmode, pos, angle, scale, center)
end

return graphics
