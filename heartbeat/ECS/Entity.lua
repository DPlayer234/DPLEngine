--[[
The base class for any entity to be added to a scene
]]
local assert, type = assert, type
local class = require "Heartbeat::class"

local Component = require "Heartbeat::ECS::Component"
local ComponentStorage = require "Heartbeat::ECS::ComponentStorage"

local Transform = require "Heartbeat::ECS::Transform"

-- Class
local Entity = class("Entity", require "Heartbeat::ECS::Object")

-- Initializes a new Entity
function Entity:new()
	self:Object()

	self.transform = Transform()

	self._active = true
	self._compStorage = ComponentStorage(false)
	self._tags = {}
end

-- Called after the ECS is attached
function Entity:initialize() end

-- Attaches an ECS to the entity
function Entity:attachToECS(ecs)
	assert(not self:isAttachedToECS(), "Cannot attach an Entity multiple times.")

	self.ecs = ecs
	self.ecs._entStorage:add(self)

	self:initialize()
end

-- Returns whether this entity is attached to an ECS
function Entity:isAttachedToECS()
	return self.ecs ~= nil
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

-- Sets whether the entity is active and will be updated
function Entity:setActive(value)
	assert(type(value) == "boolean", "Activity value must be a boolean.")

	if value ~= self._active then
		self._active = value

		self._compStorage:callAllAlways(value and "onEnable" or "onDisable")
	end
end

-- Gets whether the entity is active and will be updated
function Entity:isActive()
	return self._active
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

-- Debug-Friendly debug message
function Entity:__tostring()
	local tag = next(self._tags)
	if not tag then
		return ("%s: %p"):format(self:type(), self)
	end
	return ("%s (%s): %p"):format(self:type(), tag, self)
end

-- Calls the named function for all of its components and itself
function Entity:_callEvent(funcName, ...)
	if self[funcName] ~= nil then self[funcName](self, ...) end
	return self._compStorage:callAll(funcName, ...)
end

return Entity
