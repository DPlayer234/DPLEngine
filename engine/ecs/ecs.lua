--[[
The Entity Component System
]]
local currentModule = miscMod.getModule(..., false)

-- The Entity Component System class
local ECS = class("ECS")

-- Load important classes
ECS.ComponentStorage = require(currentModule .. ".component_storage")
ECS.Component        = require(currentModule .. ".component")
ECS.EntityStorage    = require(currentModule .. ".entity_storage")
ECS.Entity           = require(currentModule .. ".entity")

-- Initializes a new Entity Component System
function ECS:new()
	self._entStorage = ECS.EntityStorage()
	self._compStorage = ECS.ComponentStorage()

	self.deltaTime = 0

	self.world = nil
	self.timer = nil
	self.transformation = nil
	self.gameState = nil
end

-- Adds an entity to the system and returns it
function ECS:addEntity(entity)
	entity:attachToECS(self)
	return entity
end

-- Finds a single entity with a given tag
function ECS:findEntityByTag(tag)
	return self._entStorage:getWithTag(tag)
end

-- Finds all entities with a given tag
function ECS:findEntitiesByTag(tag)
	return self._entStorage:getAllWithTag(tag)
end

-- Finds a single entity with all of the given tags
function ECS:findEntityByAllTags(...)
	return self._entStorage:getWithAllTags(...)
end

-- Finds all entities with all of the given tags
function ECS:findEntitiesByAllTags(...)
	return self._entStorage:getAllWithAllTags(...)
end

-- Finds a single entity of a given type
function ECS:findEntityByType(tag)
	return self._entStorage:getType(tag)
end

-- Finds all entities of a given type
function ECS:findEntitiesByType(tag)
	return self._entStorage:getAllType(tag)
end

-- Updates the system
function ECS:update()
	-- Update Entities
	self._entStorage:updateAll()
	self._compStorage:updateAll()
end

-- Post-Updates the system
function ECS:postUpdate()
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
