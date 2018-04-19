--[[
This entity handles UI events
]]
local input = require "Heartbeat.input"
local class = require "Heartbeat.class"
local Vector2 = require "Heartbeat.Vector2"
local EntityStorage = require "Heartbeat.ECS.EntityStorage"

local UiEventHandler = class("UiEventHandler", require "Heartbeat.ECS.Entity")

-- Initializes a new UiEventHandler
function UiEventHandler:initialize()
	self._entStorage = EntityStorage()

	self._input = input.MouseInput({})

	-- Input binding
	self._input:bindMouse(1, "")

	self._input:bindDownEvent("", function(x, y)
		self._entStorage:callAll("_onDown", self.ecs.transformation:inverseTransformPoint(Vector2(x, y)))
	end)

	self._input:bindUpEvent("", function(x, y)
		self._entStorage:callAll("_onUp", self.ecs.transformation:inverseTransformPoint(Vector2(x, y)))
	end)

	self:registerInput(self._input)
end

-- Adds a new UiEventHandler if there isn't already one
-- Returns the existing or new handler
-- This a class, not an instance method!
function UiEventHandler.create(element)
	assert(element:typeOf("UiElement"), "Can only add UiElements to the UiEventHandler.")

	local handler = element.ecs:findEntityByType("UiEventHandler") or element.ecs:addEntity(UiEventHandler())
	handler:_addElement(element)
end

-- Adds a ui element
function UiEventHandler:_addElement(element)
	self._entStorage:add(element)
	element.handler = self

	return element
end

return UiEventHandler
