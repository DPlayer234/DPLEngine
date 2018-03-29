--[[
Renders any drawable object
]]
local graphics = require "love.graphics"
local colors = require "libs.colors"
local Vector2 = require "Engine.Vector2"

local DrawableRenderer = class("DrawableRenderer", require "Engine.ECS.Component")

DrawableRenderer.priority = -100

function DrawableRenderer:initialize()
	self._center = Vector2()
	self._color = colors.vec4(1, 1, 1, 1)
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

	graphics.setColor(self:getColor())

	if self:getQuad() then
		graphics.draw(self:getDrawable(), self:getQuad(), x, y, self.transform:getAngle(), sx, sy, cx, cy)
	else
		graphics.draw(self:getDrawable(), x, y, self.transform:getAngle(), sx, sy, cx, cy)
	end
end

return DrawableRenderer
