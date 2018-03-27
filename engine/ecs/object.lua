--[[
Super class for updatable, drawable and destroyable things
]]
local Object = class("Object")

-- Creates a new Object
function Object:new()
	-- Marks an entity for destruction
	self._destroy = false

	-- Marks an entity as already destroyed
	self._destroyed = false
end

-- By default, does nothing
function Object:update(dt) end

-- By default, does nothing
function Object:postUpdate(dt) end

-- By default, does nothing
function Object:draw(dt) end

-- Destroys the object
function Object:destroy()
	self._destroy = true
end

-- Returns whether the object was destroyed already and cannot be used anymore
function Object:wasDestroyed()
	return self._destroyed
end

return Object
