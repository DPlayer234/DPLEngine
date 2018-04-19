--[[
Any UI Element
]]
local class = require "Heartbeat.class"
local Vector2 = require "Heartbeat.Vector2"

local Alignment = require("Heartbeat.components").Alignment
local UiEventHandler = require("Heartbeat.entities").UiEventHandler

local UiElement = class("UiElement", require "Heartbeat.ECS.Entity")

-- Creates a new UiElement
function UiElement:new()
	self:Entity()

	self.handler = nil
	self:tagAs("UI")
end

-- Initializes a new element
function UiElement:initialize()
	UiEventHandler.create(self)

	self._wasPressed = false
	self._alignment = self:addComponent(Alignment())

	self._dimensions = Vector2(160, 60)
	self._screenAnchor = Vector2(0.5, 0.5)
	self._localAnchor = Vector2(0.5, 0.5)
	self._offset = Vector2.zero
end

-- Destroys the UiElement
function UiElement:destroy()
	self.handler._entStorage:queueClear()
	self.Entity.destroy(self)
end

-- Gets the dimensions
function UiElement:getDimensions()
	return self._dimensions:copy()
end

-- Sets the dimensions
function UiElement:setDimensions(value)
	self._dimensions = value:copy()
	self:_updateAlignment()
end

-- Gets the screen anchor
function UiElement:getScreenAnchor()
	return self._screenAnchor:copy()
end

-- Sets the screen anchor
function UiElement:setScreenAnchor(value)
	self._screenAnchor = value:copy()
	self:_updateAlignment()
end

-- Gets the local anchor
function UiElement:getLocalAnchor()
	return self._localAnchor:copy()
end

-- Sets the local anchor
function UiElement:setLocalAnchor(value)
	self._localAnchor = value:copy()
	self:_updateAlignment()
end

-- Gets the absolute offset
function UiElement:getOffset()
	return self._offset:copy()
end

-- Sets the absolute offset
function UiElement:setOffset(value)
	self._offset = value:copy()
	self:_updateAlignment()
end

-- Called when the mouse is pressed down it
function UiElement:onDown() end

-- Called when the mouse was pressed down on it and is now released, still on it
function UiElement:onUp() end

-- Updates the alignment
function UiElement:_updateAlignment()
	return self._alignment:set {
		anchor = self._screenAnchor,
		offset = Vector2.multiply(self._dimensions, (self._localAnchor - Vector2(0.5, 0.5))) + self._offset
	}
end

-- Called when the mouse button is pressed
function UiElement:_onDown(pos)
	if self:_intersect(pos) then
		self:onDown()

		self._wasPressed = true
		return
	end
	self._wasPressed = false
end

-- Called when the mouse button is released
function UiElement:_onUp(pos)
	if self._wasPressed and self:_intersect(pos) then
		self:onUp()
	end
end

-- Returns whether the point intersects the bounding box
function UiElement:_intersect(point)
	local pos = self.transform:getPosition()
	local scale = self.transform:getScale()

	return
		point.x > pos.x - self._dimensions.x * scale.x * 0.5 and
		point.x < pos.x + self._dimensions.x * scale.x * 0.5 and
		point.y > pos.y - self._dimensions.y * scale.y * 0.5 and
		point.y < pos.y + self._dimensions.y * scale.y * 0.5
end

return UiElement
