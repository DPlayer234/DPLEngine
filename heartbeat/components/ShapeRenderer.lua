--[[
Renders a shape
]]
local assert = assert
local lgraphics = require "love.graphics"
local class = require "Heartbeat::class"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local ShapeRenderer = class("ShapeRenderer", require "Heartbeat::ECS::Component")

-- Creates a new ShapeRenderer
function ShapeRenderer:new(entity, drawMode, shape, arg)
	self:Component(entity)

	self:setDrawMode(drawMode)

	self:setShape(shape, arg)

	self._center = Vector2.zero
	self._color = Color.white

	if shape == "rectangle" then
		self:setCenter(arg * 0.5)
	end
end

-- Gets the draw mode
function ShapeRenderer:getDrawMode()
	return self._drawMode
end

-- Sets the draw mode
function ShapeRenderer:setDrawMode(value)
	assert(value == "fill" or value == "line", "Invalid draw mode.")
	self._drawMode = value
end

-- Gets the information on the renderered shape
function ShapeRenderer:getShape()
	if Vector2.is(self._arg) then
		return self._shape, self._arg:unpack()
	end
	return self._shape, self._arg
end

-- Sets the shape
function ShapeRenderer:setShape(shape, arg)
	if shape == "rectangle" or shape == "ellipse" then
		assert(Vector2.is(arg), "Invalid argument to ShapeRenderer")
		self._arg = arg
	elseif shape == "circle" or shape == "polygon" then
		self._arg = arg
	else
		error("Unknown shape '" .. tostring(shape) .. "'.")
	end

	self._shape = shape
end

-- Gets the center
function ShapeRenderer:getCenter()
	return self._center:copy()
end

-- Sets the center/rotation point of the Drawable
function ShapeRenderer:setCenter(value)
	self._center = value:copy()
end

-- Gets the color used for drawing
function ShapeRenderer:getColor()
	return self._color
end

-- Sets the color used for drawing
function ShapeRenderer:setColor(value)
	self._color = value
end

function ShapeRenderer:draw()
	lgraphics.push()

	local x,  y  = self.transform:getPosition():unpack()
	local sx, sy = self.transform:getScale():unpack()
	local cx, cy = self:getCenter():unpack()

	lgraphics.translate(x, y)
	lgraphics.rotate(self.transform:getAngle())
	lgraphics.translate(-cx, -cy)
	lgraphics.scale(sx, sy)
	lgraphics.setColor(self:getColor())

	if self._shape == "rectangle" then
		lgraphics.rectangle(self._drawMode, 0, 0, self._arg:unpack())
	elseif self._shape == "ellipse" then
		lgraphics.ellipse(self._drawMode, 0, 0, self._arg:unpack())
	elseif self._shape == "circle" then
		lgraphics.circle(self._drawMode, 0, 0, self._arg)
	elseif self._shape == "polygon" then
		lgraphics.polygon(self._drawMode, self._arg)
	end

	lgraphics.pop()
end

return ShapeRenderer
