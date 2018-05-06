--[[
Entity Transform
]]
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"

local Transform = class("Transform")

-- Creates a new transform object
function Transform:new()
	self._position = Vector2.zero
	self._angle = 0
	self._scale = Vector2.one
end

-- Flips the scaling horizontally
function Transform:flipHorizontal()
	self:setScale(Vector2.multiply(self:getScale(), Vector2(-1, 1)))
end

-- Flips the scaling vertically
function Transform:flipVertical()
	self:setScale(Vector2.multiply(self:getScale(), Vector2(1, -1)))
end

-- Gets the Löve body this is hooked to
function Transform:getLBody()
	return self._body
end

-- Sets the Löve body this is hooked to
function Transform:setLBody(value, overrideBody)
	if self:getLBody() then
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
	if self:getLBody() then
		return Vector2(self:getLBody():getPosition())
	end
	return self._position:copy()
end

function Transform:setPosition(value)
	if self:getLBody() then
		return self:getLBody():setPosition(value:unpack())
	end
	self._position = value:copy()
end

-- Angle
function Transform:getAngle()
	if self:getLBody() then
		return self:getLBody():getAngle()
	end
	return self._angle
end

function Transform:setAngle(value)
	if self:getLBody() then
		return self:getLBody():setAngle(value)
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
