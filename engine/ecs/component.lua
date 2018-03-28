--[[
The base class for any component addable to entities
]]
local currentModule = miscMod.getModule(..., false)

local Object = require(currentModule .. ".object")
local Component = class("Component", Object)

-- Creates a new component instance
function Component:new()
	self:Object()
end

-- Called after the entity is attached
function Component:initialize() end

-- Attaches an entity to the component
function Component:attachToEntity(entity)
	self.entity = entity

	self.ecs = self.entity.ecs
	self.transform = self.entity.transform

	self.entity._compStorage:add(self)
	if self:isUpdatable() then
		self.ecs._compStorage:add(self)
	end

	self:initialize()
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
	local super = self.Component
	return self.update ~= super.update or self.postUpdate ~= super.postUpdate or self.draw ~= super.draw
end

return Component
