--[[
The base class for any entity to be added to a scene
]]
local currentModule = miscMod.getModule(..., false)
local parentModule  = miscMod.getModule(currentModule, false)

local Object = require(currentModule .. ".object")

local Component = require(currentModule .. ".component")
local ComponentStorage = require(currentModule .. ".component_storage")

local libs = require(parentModule .. ".libs")

-- Class
local Entity = class("Entity", Object)

-- Initializes a new Entity
function Entity:new()
	self:Object()

	self.transform = libs.Transform()

	self._compStorage = ComponentStorage()
	self._tags = {}
end

-- For Overrides
function Entity:initialize() end

-- Attaches an ECS to the entity
function Entity:attachECS(ecs)
	self.ecs = ecs

	self:initialize()
end

-- Adds a component to the entity
function Entity:addComponent(component)
	component:attachEntity(self)
	return self._compStorage:add(component)
end

-- Gets an attached component of the given type
function Entity:getComponent(class)
	return self._compStorage:get(class)
end

-- Gets an attached component of exactly the given type
function Entity:getExactComponent(class)
	return self._compStorage:getExact(class)
end

-- Gets all attached components of the given type
function Entity:getComponents(class)
	return self._compStorage:getAll(class)
end

-- Gets all attached components of exactly the given type
function Entity:getExactComponents(class)
	return self._compStorage:getAllExact(class)
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

-- Destroys this entity and all of its components
function Entity:destroy()
	self.ecs._entStorage:queueClear()

	for _, component in ipairs(self:getComponents(Component)) do
		component:destroy()
	end

	return self.Object.destroy(self)
end

return Entity
