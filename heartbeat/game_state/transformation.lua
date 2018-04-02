--[[
Render Transformation for GameStates
]]
local Mat3x3 = require "Heartbeat.Mat3x3"
local Vector2 = require "Heartbeat.Vector2"
local lgraphics = require "love.graphics"
local lmath = require "love.math"

local Transformation = class("Transformation")

-- Creates a new Transformation
function Transformation:new()
	self._transform = lmath.newTransform()
end

-- Translates the transformation
function Transformation:translate(tl)
	self._transform:translate(tl.x, tl.y)
	return self
end

-- Scales the transformation
function Transformation:scale(sc)
	self._transform:scale(sc.x, sc.y)
	return self
end

-- Shears the transformation
function Transformation:shear(sh)
	self._transform:shear(sh.x, sh.y)
	return self
end

-- Rotates the transformation
function Transformation:rotate(angle)
	self._transform:rotate(angle)
	return self
end

function Transformation:set(x, y, angle, sx, sy, ox, oy, kx, ky)
	self._transform:set(x, y, angle, sx, sy, ox, oy, kx, ky)
	return self
end

-- Resets the transformation
function Transformation:reset()
	self._transform:reset()
	return self
end

-- Applies the transformation
function Transformation:apply()
	lgraphics.applyTransform(self._transform)
	return self
end

-- Replaces the current screen transformation with this one
function Transformation:apply()
	lgraphics.replaceTransform(self._transform)
	return self
end

-- Translates world coordinates to screen coordinates
function Transformation:transformPoint(globalPoint)
	return Vector2(self._transform:transformPoint(globalPoint:unpack()))
end

-- Translates screen coordinates to world coordinates
function Transformation:inverseTransformPoint(localPoint)
	return Vector2(self._transform:inverseTransformPoint(localPoint:unpack()))
end

return Transformation
