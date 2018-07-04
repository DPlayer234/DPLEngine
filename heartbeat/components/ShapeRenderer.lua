--[[
Renders a shape
]]
local assert = assert
local lgraphics = require "love.graphics"
local graphics = require "Heartbeat::lovef::graphics"
local class = require "Heartbeat::class"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local ShapeRenderer = class("ShapeRenderer", require("Heartbeat::components").Renderer)

-- Creates a new ShapeRenderer
function ShapeRenderer:new(drawMode, shape, arg)
	self:Renderer()

	self:setDrawMode(drawMode)

	self:setShape(shape, arg)

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

function ShapeRenderer:draw()
	graphics.push()

	graphics.useTransform(self.transform, self:getCenter())
	graphics.setColor(self:getColor())

	if self._shape == "rectangle" then
		lgraphics.rectangle(self._drawMode, 0, 0, self._arg:unpack())
	elseif self._shape == "ellipse" then
		lgraphics.ellipse(self._drawMode, 0, 0, self._arg:unpack())
	elseif self._shape == "circle" then
		lgraphics.circle(self._drawMode, 0, 0, self._arg)
	elseif self._shape == "polygon" then
		lgraphics.polygon(self._drawMode, self._arg)
	end

	graphics.pop()
end

return ShapeRenderer
