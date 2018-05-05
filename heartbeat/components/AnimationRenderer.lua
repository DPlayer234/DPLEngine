--[[
Renders and updates an animation
]]
local class = require "Heartbeat::class"

local DrawableRenderer = require("Heartbeat::components").DrawableRenderer
local AnimationRenderer = class("AnimationRenderer", DrawableRenderer)

function AnimationRenderer:getAnimator()
	return self._animator
end

function AnimationRenderer:setAnimator(value)
	self._animator = value
end

-- Returns the used drawable
function AnimationRenderer:getDrawable()
	if self:getAnimator() == nil then return end
	return self:getAnimator():getTexture()
end

-- Sets the used Drawable
function AnimationRenderer:setDrawable(value)
	if self:getAnimator() == nil then return end
	self:getAnimator():setTexture(value)
end

-- Returns the used quad
function AnimationRenderer:getQuad()
	if self:getAnimator() == nil then return end
	return self:getAnimator():getFrame()
end

-- Sets the Quad used (does not work)
function AnimationRenderer:setQuad(value) end

return AnimationRenderer
