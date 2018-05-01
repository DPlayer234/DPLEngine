--[[
Stores entities
]]
local table = table
local class = require "Heartbeat.class"

local EntityStorage = class("EntityStorage")

-- Creates a new EntityStorage
function EntityStorage:new()
	self._entities = {}
	self._needsClear = true
	self._needsSort = true
end

-- Returns whether the storage contains the entity
function EntityStorage:contains(entity)
	for i=1, #self._entities do
		if self._entities[i] == entity then
			return true
		end
	end
	return false
end

-- Adds an entity to the storage
function EntityStorage:add(entity)
	if not entity:typeOf("Entity") then error("Can only add objects of type 'Entity' to an EntityStorage.") end
	if self:contains(entity) then return entity end

	self._entities[#self._entities + 1] = entity
	self._needsSort = true

	return entity
end

-- Gets a single entity with a given tag
function EntityStorage:getWithTag(tag)
	for i=1, #self._entities do
		if self._entities[i]:isTagged(tag) then
			return self._entities[i]
		end
	end
end

-- Gets all entities with a certain tag
function EntityStorage:getAllWithTag(tag)
	local entities = {}
	for i=1, #self._entities do
		if self._entities[i]:isTagged(tag) then
			entities[#entities + 1] = self._entities[i]
		end
	end
	return entities
end

-- Gets a single entity with all given tags
function EntityStorage:getWithAllTags(...)
	for i=1, #self._entities do
		if self._entities[i]:isTaggedWithAll(...) then
			return self._entities[i]
		end
	end
end

-- Gets all entities with all given tags
function EntityStorage:getAllWithAllTags(...)
	local entities = {}
	for i=1, #self._entities do
		if self._entities[i]:isTaggedWithAll(...) then
			entities[#entities + 1] = self._entities[i]
		end
	end
	return entities
end

-- Gets a single entity of a given type
function EntityStorage:getType(typeName)
	for i=1, #self._entities do
		if self._entities[i]:typeOf(typeName) then
			return self._entities[i]
		end
	end
end

-- Gets all entities of a given type
function EntityStorage:getAllType(typeName)
	local entities = {}
	for i=1, #self._entities do
		if self._entities[i]:typeOf(typeName) then
			entities[#entities + 1] = self._entities[i]
		end
	end
	return entities
end

-- Calls the named function on every entity that has the function and is active
function EntityStorage:callAll(funcName, ...)
	for i=1, #self._entities do
		local entity = self._entities[i]
		if entity[funcName] and entity:isActive() then
			entity[funcName](entity, ...)
		end
	end
end

-- Calls the named function on every entity that has the function
function EntityStorage:callAllAlways(funcName, ...)
	for i=1, #self._entities do
		local entity = self._entities[i]
		if entity[funcName] then
			entity[funcName](entity, ...)
		end
	end
end

-- Destroys all contained entities
function EntityStorage:destroyAll()
	for i=1, #self._entities do
		self._entities[i]:destroy()
	end
end

-- Marks this storage needing a clear
function EntityStorage:queueClear()
	self._needsClear = true
end

-- Handles internal stuff
function EntityStorage:handle()
	self:_handleComponents()

	if self._needsClear then
		self:_clearDestroyed()
	end

	if self._needsSort then
		self:_sort()
	end
end

-- Clear out destroyed components
function EntityStorage:_handleComponents()
	for i=1, #self._entities do
		self._entities[i]._compStorage:handle()
	end
end

-- Clears all destroyed entities out
function EntityStorage:_clearDestroyed()
	self._needsClear = false

	for i=#self._entities, 1, -1 do
		local entity = self._entities[i]
		if entity._destroy then
			entity._destroyed = true
			entity:onDestroy()
			table.remove(self._entities, i)
		end
	end
end

-- Sorting callback
local sort = function(a, b)
	return a.priority > b.priority
end

-- Sorts the entity list
function EntityStorage:_sort()
	table.sort(self._entities, sort)

	self._needsSort = false
end

return EntityStorage
