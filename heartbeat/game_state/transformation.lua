--[[
Render Transformation for GameStates
]]
local Mat3x3 = require "Heartbeat.Mat3x3"
local Vector2 = require "Heartbeat.Vector2"

local Transformation = class("Transformation")

-- Creates a new Transformation
function Transformation:new()
	self:reset()
end

-- Translates the transformation
function Transformation:translate(tl)
	self._mat = Mat3x3(
		1.00, 0.00, tl.x,
		0.00, 1.00, tl.y,
		0.00, 0.00, 1.00
	) * self._mat
end

-- Scales the transformation
function Transformation:scale(sc)
	self._mat = Mat3x3(
		sc.x, 0.00, 0.00,
		0.00, sc.y, 0.00,
		0.00, 0.00, 1.00
	) * self._mat
end

-- Shears the transformation
function Transformation:shear(sh)
	self._mat = Mat3x3(
		1.00, sh.x, 0.00,
		sh.y, 1.00, 0.00,
		0.00, 0.00, 1.00
	) * self._mat
end

-- Rotates the transformation
function Transformation:rotate(angle)
	local sin = math.sin(angle)
	local cos = math.cos(angle)

	self._mat = Mat3x3(
		 cos,  sin, 0.00,
		-sin,  cos, 0.00,
		0.00, 0.00, 1.00
	) * self._mat
end

-- Resets the transformation
function Transformation:reset()
	self._mat = Mat3x3(1)
end

-- Applies the transformation as good as possible
function Transformation:apply()
	love.graphics.scale(self._mat.a.x, self._mat.b.y)
	love.graphics.shear(self._mat.a.y, self._mat.b.x)
	love.graphics.translate(self._mat.a.z, self._mat.b.z)
end

-- Translates world coordinates to screen coordinates
function Transformation:applyPoint(point)
	return Vector2(
		self._mat.a.x * point.x + self._mat.a.y * point.y + self._mat.a.z,
		self._mat.b.x * point.x + self._mat.b.y * point.y + self._mat.b.z
	)
end

-- Translates screen coordinates to world coordinates
-- TODO: Rotation and Shearing don't work
-- TODO: Scaling by 0
function Transformation:inverseApplyPoint(point)
	local p2 = point - Vector2(self._mat.a.z, self._mat.b.z)
	return Vector2(
		p2.x / self._mat.a.x,
		p2.y / self._mat.b.y
	)
end

return Transformation
