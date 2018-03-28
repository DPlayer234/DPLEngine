--[[
The base class for any entity to be added to a scene
]]
local currentModule = miscMod.getModule(..., false)
local parentModule  = miscMod.getModule(currentModule, false)

local Object = require(currentModule .. ".object")

local Component = require(currentModule .. ".component")
local ComponentStorage = require(currentModule .. ".component_storage")

local Transform = require "Engine.Transform"

-- Class
local Entity = class("Entity", Object)

-- Initializes a new Entity
function Entity:new()
	self:Object()

	self.transform = Transform()

	self._compStorage = ComponentStorage(false)
	self._tags = {}
end

-- Called after the ECS is attached
function Entity:initialize() end

-- Collision callbacks
function Entity:onCollisionBegin(other, contact) end
function Entity:onCollisionStay(other, contact) end
function Entity:onCollisionEnd(other, contact) end

-- Sensor callbacks
function Entity:onSensorBegin(other, contact) end
function Entity:onSensorStay(other, contact) end
function Entity:onSensorEnd(other, contact) end

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

	for _, component in ipairs(self:getComponents("Component")) do
		component:destroy()
	end
end

return Entity
