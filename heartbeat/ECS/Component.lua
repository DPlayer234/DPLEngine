--[[
The base class for any component addable to entities
]]
local assert, type = assert, type
local class = require "Heartbeat::class"

local Component = class("Component", require "Heartbeat::ECS::Object")

-- Creates a new component instance
function Component:new()
	self:Object()

	self._enabled = true
end

-- Called after the entity and ECS is attached
function Component:initialize() end

-- Called when the component is either explicitly or implicitly enabled
function Component:onEnable() end

-- Called when the component is either explicitly or implicitly disabled
function Component:onDisable() end

-- Attaches an entity to the component
function Component:attachToEntity(entity)
	assert(not self:isAttachedToEntity(), "Cannot attach a Component multiple times.")
	assert(entity:isAttachedToECS(), "Cannot attach Components to Entities not attached to an ECS.")

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

-- Sets whether the component is enabled
function Component:setEnabled(value)
	assert(type(value) == "boolean", "Enabled value must be a boolean.")

	if value ~= self._enabled then
		self._enabled = value

		if value then
			self:onEnable()
		else
			self:onDisable()
		end
	end
end

-- Gets whether the component is enabled
function Component:isEnabled()
	return self._enabled
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

-- Debug-Friendly debug message
function Component:__tostring()
	return ("%s: %s"):format(self:type(), self.entity)
end

return Component
