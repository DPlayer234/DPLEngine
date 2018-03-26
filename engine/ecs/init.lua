--[[
The Entity Component System
]]
local currentModule = miscMod.getModule(..., true)

local EventStore = require "libs.event_store"
local Timer      = require "libs.timer"

-- The Entity Component System class
local ECS = class("ECS")

-- Load important class
ECS.ComponentStorage = require(currentModule .. ".component_storage")
ECS.Component        = require(currentModule .. ".component")
ECS.Entity           = require(currentModule .. ".entity")

-- Initializes a new Entity Component System
function ECS:new()
	self._entities = {}
	self._compStorage = ECS.ComponentStorage()

	self.timer = Timer()
end

-- Updates the system
function ECS:update(dt)
	-- Update Entities
	for i=1, #self._entities do
		self._entities[i]:update(dt)
	end

	-- Update Components
	self._compStorage:updateAll(dt)

	-- Remove destroyed entities and components
	for i=#self._entities, 1, -1 do
		if self._entities[i]._destroy then
			self._entities[i]._destroyed = true
			table.remove(self._entities, i)
		end
	end

	self._compStorage:clearDestroyed()
end

-- Draws the system
function ECS:draw()
	-- Draw Entities
	for i=1, #self._entities do
		self._entities[i]:draw()
	end
end

return ECS
