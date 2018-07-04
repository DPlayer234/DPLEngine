--[[
Renders any drawable object
]]
local class = require "Heartbeat::class"
local graphics = require "Heartbeat::lovef::graphics"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local DrawableRenderer = class("DrawableRenderer", require("Heartbeat::components").Renderer)

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

function DrawableRenderer:draw()
	if self:getDrawable() == nil then return end

	graphics.setColor(self:getColor())

	if self:getQuad() then
		graphics.drawTransform(self:getDrawable(), self:getQuad(), self.transform, self:getCenter())
	else
		graphics.drawTransform(self:getDrawable(), self.transform, self:getCenter())
	end
end

return DrawableRenderer
