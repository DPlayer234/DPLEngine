--[[
Any UI Element
]]
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"

local Alignment = require("Heartbeat::components").Alignment
local UIEventHandler = require("Heartbeat::entities").UIEventHandler

local UIElement = class("UIElement", require "Heartbeat::ECS::Entity")

-- Creates a new UIElement
function UIElement:new()
	self:Entity()

	self.handler = nil
	self:tagAs("UI")
end

-- Initializes a new element
function UIElement:initialize()
	UIEventHandler.create(self)

	self._wasPressed = false
	self._alignment = self:addComponent(Alignment())

	self._dimensions = Vector2(160, 60)
	self._screenAnchor = Vector2(0.5, 0.5)
	self._localAnchor = Vector2(0.5, 0.5)
	self._offset = Vector2.zero
end

-- Destroys the UIElement
function UIElement:destroy()
	self.handler._entStorage:queueClear()
	self.Entity.destroy(self)
end

-- Gets the dimensions
function UIElement:getDimensions()
	return self._dimensions:copy()
end

-- Sets the dimensions
function UIElement:setDimensions(value)
	self._dimensions = value:copy()
	self:_updateAlignment()
end

-- Gets the screen anchor
function UIElement:getScreenAnchor()
	return self._screenAnchor:copy()
end

-- Sets the screen anchor
function UIElement:setScreenAnchor(value)
	self._screenAnchor = value:copy()
	self:_updateAlignment()
end

-- Gets the local anchor
function UIElement:getLocalAnchor()
	return self._localAnchor:copy()
end

-- Sets the local anchor
function UIElement:setLocalAnchor(value)
	self._localAnchor = value:copy()
	self:_updateAlignment()
end

-- Gets the absolute offset
function UIElement:getOffset()
	return self._offset:copy()
end

-- Sets the absolute offset
function UIElement:setOffset(value)
	self._offset = value:copy()
	self:_updateAlignment()
end

-- Called when the mouse is pressed down it
function UIElement:onDown() end

-- Called when the mouse was pressed down on it and is now released, still on it
function UIElement:onUp() end

-- Updates the alignment
function UIElement:_updateAlignment()
	return self._alignment:set {
		anchor = self._screenAnchor,
		offset = Vector2.multiply(self._dimensions, (self._localAnchor - Vector2(0.5, 0.5))) + self._offset
	}
end

-- Called when the mouse button is pressed
function UIElement:_onDown(pos)
	if self:_intersect(pos) then
		self:onDown()

		self._wasPressed = true
		return
	end
	self._wasPressed = false
end

-- Called when the mouse button is released
function UIElement:_onUp(pos)
	if self._wasPressed and self:_intersect(pos) then
		self:onUp()
	end
end

-- Returns whether the point intersects the bounding box
function UIElement:_intersect(point)
	local pos = self.transform:getPosition()
	local scale = self.transform:getScale()

	return
		point.x > pos.x - self._dimensions.x * scale.x * 0.5 and
		point.x < pos.x + self._dimensions.x * scale.x * 0.5 and
		point.y > pos.y - self._dimensions.y * scale.y * 0.5 and
		point.y < pos.y + self._dimensions.y * scale.y * 0.5
end

return UIElement
