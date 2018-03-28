--[[
Stores entities
]]
local EntityStorage = class("EntityStorage")

-- Creates a new EntityStorage
function EntityStorage:new()
	self._entities = {}
	self._needsClear = true
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

-- Updates all contained entities
function EntityStorage:updateAll()
	for i=1, #self._entities do
		self._entities[i]:update()
	end
end

-- Post-Updates all contained entities
function EntityStorage:postUpdateAll()
	for i=1, #self._entities do
		self._entities[i]:postUpdate()
	end
end

-- Draws all contained entities
function EntityStorage:drawAll()
	for i=1, #self._entities do
		self._entities[i]:draw()
	end
end

-- Marks this storage needing a clear
function EntityStorage:queueClear()
	self._needsClear = true
end

-- Clears all destroyed entities out
function EntityStorage:clearDestroyed()
	-- Clear out destroyed components
	for i=1, #self._entities do
		self._entities[i]._compStorage:clearDestroyed()
	end

	-- Clear out destroyed entities
	if not self._needsClear then return false end

	for i=#self._entities, 1, -1 do
		if self._entities[i]._destroy then
			self._entities[i]._destroyed = true
			self._entities[i]:onDestroy()
			table.remove(self._entities, i)
		end
	end

	self._needsClear = false
	return true
end

return EntityStorage
