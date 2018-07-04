--[[
Base class for any Renderers
]]
local class = require "Heartbeat::class"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local Renderer = class("Renderer", require "Heartbeat::ECS::Component")

Renderer.priority = -1

function Renderer:new()
	self:Component()

	self._center = Vector2.zero
	self._color = Color.white
end

-- Gets the center
function Renderer:getCenter()
	return self._center:copy()
end

-- Sets the center/rotation point
function Renderer:setCenter(value)
	self._center = value:copy()
end

-- Gets the color used for drawing
function Renderer:getColor()
	return self._color
end

-- Sets the color used for drawing
function Renderer:setColor(value)
	self._color = value
end

-- Draw method to be overriden
function Renderer:draw()
	error("Cannot draw using a plain Renderer!")
end

return Renderer
