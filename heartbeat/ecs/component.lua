--[[
The base class for any component addable to entities
]]
local Component = class("Component", require "Heartbeat.ECS.Object")

-- Creates a new component instance
function Component:new()
	self:Object()
end

-- Called after the entity and ECS is attached
function Component:initialize() end

-- Attaches an entity to the component
function Component:attachToEntity(entity)
	if self:isAttachedToEntity() then error("Cannot attach a Component multiple times.") end
	if not entity:isAttachedToECS() then error("Cannot attach Components to Entities not attached to an ECS.") end

	self.entity = entity

	self.ecs = self.entity.ecs
	self.transform = self.entity.transform

	self.entity._compStorage:add(self)
	if self:isUpdatable() then
		self.ecs._compStorage:add(self)
	end

	self:initialize()
end

-- Returns whether this component is attached to an Entity
function Component:isAttachedToEntity()
	return self.entity ~= nil
end

-- Destroys the component
function Component:destroy()
	self.entity._compStorage:queueClear()
	if self:isUpdatable() then
		self.ecs._compStorage:queueClear()
	end

	return self.Object.destroy(self)
end

-- Returns whether this component is updatable
function Component:isUpdatable()
	return (self.update or self.postUpdate or self.draw) and true
end

return Component
