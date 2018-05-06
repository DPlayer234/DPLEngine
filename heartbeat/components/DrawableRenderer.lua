--[[
Renders any drawable object
]]
local lgraphics = require "love.graphics"
local class = require "Heartbeat::class"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local DrawableRenderer = class("DrawableRenderer", require "Heartbeat::ECS::Component")

DrawableRenderer.priority = -1

function DrawableRenderer:initialize()
	self._center = Vector2.zero
	self._color = Color.white
end

-- Gets the used drawable
function DrawableRenderer:getDrawable()
	return self._drawable
end

-- Sets the used Drawable
function DrawableRenderer:setDrawable(value)
	self._drawable = value
end

-- Gets the used quad
function DrawableRenderer:getQuad()
	return self._quad
end

-- Sets the Quad used (only valid if the drawable is a Texture)
function DrawableRenderer:setQuad(value)
	self._quad = value
end

-- Gets the center
function DrawableRenderer:getCenter()
	return self._center:copy()
end

-- Sets the center/rotation point of the Drawable
function DrawableRenderer:setCenter(value)
	self._center = value:copy()
end

-- Gets the color used for drawing
function DrawableRenderer:getColor()
	return self._color
end

-- Sets the color used for drawing
function DrawableRenderer:setColor(value)
	self._color = value
end

function DrawableRenderer:draw()
	if self:getDrawable() == nil then return end

	local x,  y  = self.transform:getPosition():unpack()
	local sx, sy = self.transform:getScale():unpack()
	local cx, cy = self:getCenter():unpack()

	lgraphics.setColor(self:getColor())

	if self:getQuad() then
		lgraphics.draw(self:getDrawable(), self:getQuad(), x, y, self.transform:getAngle(), sx, sy, cx, cy)
	else
		lgraphics.draw(self:getDrawable(), x, y, self.transform:getAngle(), sx, sy, cx, cy)
	end
end

return DrawableRenderer
