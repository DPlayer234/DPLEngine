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
function Object:update() end

-- By default, does nothing
function Object:postUpdate() end

-- By default, does nothing
function Object:draw() end

-- Destroys the object
function Object:destroy()
	self._destroy = true
end

-- Called when the object is actually destroyed
function Object:onDestroy() end

-- Returns whether the object was set for destruction
function Object:toBeDestroyed()
	return self._destroy
end

-- Returns whether the object was destroyed already and cannot be used anymore
function Object:wasDestroyed()
	return self._destroyed
end

return Object
