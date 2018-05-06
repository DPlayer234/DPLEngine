--[[
This entity handles UI events
]]
local input = require "Heartbeat::input"
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"
local EntityStorage = require "Heartbeat::ECS::EntityStorage"

local UIEventHandler = class("UIEventHandler", require "Heartbeat::ECS::Entity")

-- Initializes a new UIEventHandler
function UIEventHandler:initialize()
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

-- Adds a new UIEventHandler if there isn't already one
-- Returns the existing or new handler
-- This a class, not an instance method!
function UIEventHandler.create(element)
	assert(element:typeOf("UIElement"), "Can only add UIElements to the UIEventHandler.")

	local handler = element.ecs:findEntityByType("UIEventHandler") or element.ecs:addEntity(UIEventHandler())
	handler:_addElement(element)
end

-- Adds a ui element
function UIEventHandler:_addElement(element)
	self._entStorage:add(element)
	element.handler = self

	return element
end

return UIEventHandler
