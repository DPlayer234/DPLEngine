--[[
Stores entities
]]
local EntityStorage = class("EntityStorage")

-- Creates a new EntityStorage
function EntityStorage:new()
	self._entities = setmetatable({}, implicit2d)
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
	if self:contains(entity) then return entity end

	self._entities[#self._entities + 1] = entity

	return entity
end

-- Removes an entity from the storage
function EntityStorage:remove(entity)
	for i=1, #self._entities do
		if self._entities[i] == entity then
			table.remove(self._entities, i)
			return true
		end
	end
	return false
end

-- Updates all contained entities
function EntityStorage:updateAll(dt)
	for i=1, #self._entities do
		self._entities[i]:update(dt)
	end
end

-- Post-Updates all contained entities
function EntityStorage:postUpdateAll(dt)
	for i=1, #self._entities do
		self._entities[i]:postUpdate(dt)
	end
end

-- Draws all contained entities
function EntityStorage:drawAll(dt)
	for i=1, #self._entities do
		self._entities[i]:draw(dt)
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

	for i=1, #self._entities do
		if self._entities[i]._destroy then
			self._entities[i]._destroyed = true
			table.remove(self._entities, j)
		end
	end

	self._needsClear = false
	return true
end

return EntityStorage
