--[[
The Entity Component System
]]
local ECS = class("ECS")

-- Load important classes
ECS.Object           = require "Engine.ECS.Object"
ECS.Entity           = require "Engine.ECS.Entity"
ECS.Component        = require "Engine.ECS.Component"
ECS.EntityStorage    = require "Engine.ECS.EntityStorage"
ECS.ComponentStorage = require "Engine.ECS.ComponentStorage"

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
	self._entStorage:callAll("update")
	self._compStorage:callAll("update")
end

-- Post-Updates the system
function ECS:postUpdate()
	-- Update Entities
	self._entStorage:callAll("postUpdate")
	self._compStorage:callAll("postUpdate")

	self._entStorage:handle()
	self._compStorage:handle()
end

-- Draws the system
function ECS:draw()
	self._entStorage:callAll("draw")
	self._compStorage:callAll("draw")
end

-- Destroy and clear all entities and components associated
function ECS:destroy()
	self._entStorage:destroyAll()
	self._compStorage:destroyAll()

	self._entStorage:handle()
	self._compStorage:handle()
end

return ECS
