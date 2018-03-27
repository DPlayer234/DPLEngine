--[[
The Entity Component System
]]
local currentModule = miscMod.getModule(..., true)

local EventStore = require "libs.event_store"

-- The Entity Component System class
local ECS = class("ECS")

-- Load important class
ECS.ComponentStorage = require(currentModule .. ".component_storage")
ECS.Component        = require(currentModule .. ".component")
ECS.EntityStorage    = require(currentModule .. ".entity_storage")
ECS.Entity           = require(currentModule .. ".entity")

-- Initializes a new Entity Component System
function ECS:new(world)
	self._entStorage = ECS.EntityStorage()
	self._compStorage = ECS.ComponentStorage()

	self.deltaTime = 0

	self.world = nil
	self.timer = nil
end

-- Adds an entity to the system and returns it
function ECS:addEntity(entity)
	entity:attachToECS(self)
	return self._entStorage:add(entity)
end

-- Updates the system
function ECS:update(dt)
	self.deltaTime = dt

	-- Update Entities
	self._entStorage:updateAll()
	self._compStorage:updateAll()
end

-- Post-Updates the system
function ECS:postUpdate(dt)
	self.deltaTime = dt

	-- Update Entities
	self._entStorage:postUpdateAll()
	self._compStorage:postUpdateAll()

	-- Remove destroyed entities and components
	self._entStorage:clearDestroyed()
	self._compStorage:clearDestroyed()
end

-- Draws the system
function ECS:draw()
	self._entStorage:drawAll()
	self._compStorage:drawAll()
end

return ECS
