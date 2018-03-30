--[[
The base class for any entity to be added to a scene
]]
local Component = require "Heartbeat.ECS.Component"
local ComponentStorage = require "Heartbeat.ECS.ComponentStorage"

local Transform = require "Heartbeat.ECS.Transform"

-- Class
local Entity = class("Entity", require "Heartbeat.ECS.Object")

-- Initializes a new Entity
function Entity:new()
	self:Object()

	self.transform = Transform()

	self._compStorage = ComponentStorage(false)
	self._tags = {}
end

-- Called after the ECS is attached
function Entity:initialize() end

-- Attaches an ECS to the entity
function Entity:attachToECS(ecs)
	self.ecs = ecs
	self.ecs._entStorage:add(self)

	self:initialize()
end

-- Adds a component to the entity
function Entity:addComponent(component)
	component:attachToEntity(self)
	return component
end

-- Gets an attached component of the given type
function Entity:getComponent(typeName)
	return self._compStorage:get(typeName)
end

-- Gets an attached component of exactly the given type
function Entity:getExactComponent(typeName)
	return self._compStorage:getExact(typeName)
end

-- Gets all attached components of the given type
function Entity:getComponents(typeName)
	return self._compStorage:getAll(typeName)
end

-- Gets all attached components of exactly the given type
function Entity:getExactComponents(typeName)
	return self._compStorage:getAllExact(typeName)
end

-- Tags the entity
function Entity:tagAs(tag)
	self._tags[tag] = true
end

-- Removes a tag from the entity
function Entity:untagAs(tag)
	self._tags[tag] = nil
end

-- Returns whether the entity is tagged as such
function Entity:isTagged(tag)
	return self._tags[tag] and true
end

-- Returns whether the entity is tagged with all given tags
function Entity:isTaggedWithAll(...)
	local tags = {...}
	for i=1, #tags do
		if not self:isTagged(tags[i]) then
			return false
		end
	end
	return true
end

-- Destroys this entity and all of its components
function Entity:destroy()
	self.ecs._entStorage:queueClear()
	self.Object.destroy(self)
	self._compStorage:destroyAll()
end

-- Calls the named function for all of its components and itself
function Entity:_callEvent(funcName, ...)
	if self[funcName] then self[funcName](self, ...) end
	return self._compStorage:callAll(funcName, ...)
end

return Entity
