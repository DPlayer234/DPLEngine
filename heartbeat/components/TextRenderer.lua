--[[
Renders any drawable object
]]
local lgraphics = require "love.graphics"
local class = require "Heartbeat::class"
local graphics = require "Heartbeat::lovef::graphics"
local Color = require "Heartbeat::Color"
local Vector2 = require "Heartbeat::Vector2"

local TextRenderer = class("TextRenderer", require("Heartbeat::components").Renderer)

local DEFAULT_TEXT = "" --#const
local DEFAULT_ALIGN_MODE = "left" --#const
local DEFAULT_WRAP_LIMIT = 2 ^ 15 - 1 --#const

-- Creates a new TextRenderer
function TextRenderer:new(font, text, wrapLimit, alignMode)
	self:Renderer()

	self:setFont(font or lgraphics.getFont())
	self:setText(text or DEFAULT_TEXT)
	self:setWrapLimit(wrapLimit or DEFAULT_WRAP_LIMIT)
	self:setAlignMode(alignMode or DEFAULT_ALIGN_MODE)
end

-- Gets the drawn text
function TextRenderer:getText()
	return self._text
end

-- Sets the drawn text
function TextRenderer:setText(value)
	self._text = value
end

-- Gets the alignment mode
function TextRenderer:getAlignMode()
	return self._alignMode
end

-- Sets the alignment mode
function TextRenderer:setAlignMode(alignMode)
	assert(
		alignMode == "left" or alignMode == "right" or alignMode == "center" or alignMode == "justify",
		"Expected 'left', 'right', 'center' or 'justify'.")

	self._alignMode = alignMode
end

-- Gets the wrap limit in pixels
function TextRenderer:getWrapLimit()
	return self._wrapLimit
end

-- Sets the wrap limit in pixels
function TextRenderer:setWrapLimit(wrapLimit)
	assert(type(wrapLimit) == "number", "Expected a number.")
	self._wrapLimit = wrapLimit
end

-- Gets the used font
function TextRenderer:getFont()
	return self._font
end

-- Sets the used font
function TextRenderer:setFont(font)
	assert(font:typeOf("Font"), "Expected a Font.")
	self._font = font
end

function TextRenderer:draw()
	graphics.setColor(self:getColor())

	graphics.printAlignedTransform(
		self:getFont(), self:getText(),
		self:getWrapLimit(), self:getAlignMode(),
		self.transform, self:getCenter())
end

return TextRenderer
