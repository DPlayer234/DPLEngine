--[[
The base class for any component addable to entities
]]
local currentModule = miscMod.getModule(..., false)

local Object = require(currentModule .. ".object")
local Component = class("Component", Object)

-- Creates a new component instance
function Component:new(entity)
	self:Object()

	self.entity = entity
	self.ecs = entity.ecs

	self.entity._compStorage:add(self)
	self.ecs._compStorage:add(self)

	self._destroyed = false
end

-- Destroys the component
function Component:destroy()
	self._destroyed = true
end

return Component
