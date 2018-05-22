--[[
This is a component that basically generates a new ShapeRenderer from and ImageCollider
]]
local lmath = love.math
local class = require "Heartbeat::class"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local ShapeRenderer = require("Heartbeat::components").ShapeRenderer
local ImageColliderRenderer = class("ImageColliderRenderer", require "Heartbeat::ECS::Component")

-- Creates a new ImageColliderRenderer from an ImageCollider
function ImageColliderRenderer:new(entity, drawMode, imageCollider)
	assert(imageCollider:typeOf("ImageCollider"), "ImageColliderRenderers require a ImageCollider passed to the constructor.")
	self:Component(entity)

	self._imageCollider = imageCollider

	self._drawMode = drawMode
	self._polygon = { imageCollider:getLFixture():getShape():getPoints() }

	self._center = imageCollider:getOffset()
	self._color = Color.white

	self._renderers = {}

	-- Seperate the polygon into triangles and add ShapeRenderers
	local triangles = lmath.triangulate(self._polygon)
	for i=1, #triangles do
		local renderer = ShapeRenderer(entity, self._drawMode, "polygon", triangles[i])
		renderer:setCenter(self._center)
		renderer:setColor(self._color)
		self._renderers[#self._renderers + 1] = renderer
	end
end

-- Returns the used ImageCollider
function ImageColliderRenderer:getImageCollider()
	return self._imageCollider
end

-- Returns the draw mode
function ImageColliderRenderer:getDrawMode()
	return self._drawMode
end

-- Returns the draw mode
function ImageColliderRenderer:setDrawMode(value)
	self:_forAllRenders(function(renderer)
		renderer:setDrawMode(value)
	end)
end

-- Returns the center
function ImageColliderRenderer:getCenter()
	return self._center:copy()
end

-- Gets the color used for drawing
function ImageColliderRenderer:getColor()
	return self._color
end

-- Sets the color used for drawing
function ImageColliderRenderer:setColor(value)
	self:_forAllRenders(function(renderer)
		renderer:setColor(value)
	end)
end

-- Destroys all renderers
function ImageColliderRenderer:onDestroy()
	self:_forAllRenders(function(renderer)
		renderer:destroy()
	end)
end

-- Calls a function for every renderer
function ImageColliderRenderer:_forAllRenders(func)
	for i=1, #self._renderers do
		if not self._renderers[i]:isDestroyed() then
			func(self._renderers[i])
		end
	end
end

return ImageColliderRenderer
