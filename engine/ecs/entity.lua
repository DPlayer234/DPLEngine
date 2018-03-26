--[[
The base class for any entity to be added to a scene
]]
local currentModule = miscMod.getModule(..., false)

local Object    = require(currentModule .. ".object")
local Component = require(currentModule .. ".component")

local Entity = class("Entity", Object)

local ComponentStorage = require(currentModule .. ".component_storage")

-- Initializes a new Entity
function Entity:new(ecs)
	self:Object()

	self._compStorage = ComponentStorage()
	self.ecs = ecs
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

-- Destroys this entity and all of its components
function Entity:destroy()
	for _, component in ipairs(self:getComponents(Component)) do
		component:destroy()
	end

	return self.Object.destroy(self)
end

return Entity
