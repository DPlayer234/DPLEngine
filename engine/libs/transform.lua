--[[
Entity Transform
]]
local Vector2 = require "Engine.Vector2"

local Transform = class("Transform")

-- Creates a new transform object
function Transform:new()
	self._position = Vector2()
	self._angle = 0
	self._scale = Vector2(1, 1)
end

-- Flips the scaling horizontally
function Transform:flipHorizontal()
	self:setScale(Vector2.multiply(self:getScale(), Vector2(-1, 1)))
end

-- Flips the scaling vertically
function Transform:flipVertical()
	self:setScale(Vector2.multiply(self:getScale(), Vector2(1, -1)))
end

-- Gets the body this is hooked to
function Transform:getBody()
	return self._body
end

-- Sets the body this is hooked to
function Transform:setBody(value, overrideBody)
	if self:getBody() then
		self._position = self:getPosition()
		self._angle = self:getAngle()
	end

	self._body = value
	if value and overrideBody then
		self:setPosition(self._position)
		self:setAngle(self._angle)
	end
end

-- Position
function Transform:getPosition()
	if self:getBody() then
		return Vector2(self:getBody():getPosition())
	end
	return self._position:copy()
end

function Transform:setPosition(value)
	if self:getBody() then
		return self:getBody():setPosition(value:unpack())
	end
	self._position = value:copy()
end

-- Angle
function Transform:getAngle()
	if self:getBody() then
		return self:getBody():getAngle()
	end
	return self._angle
end

function Transform:setAngle(value)
	if self:getBody() then
		return self:getBody():setAngle(value)
	end
	self._angle = value
end

-- Scaling (for renderers)
function Transform:getScale()
	return self._scale:copy()
end

function Transform:setScale(value)
	self._scale = value:copy()
end

function Transform:__tostring()
	return ("Transform: Pos. %.3f, %.3f"):format(self:getPosition():unpack())
end

return Transform
