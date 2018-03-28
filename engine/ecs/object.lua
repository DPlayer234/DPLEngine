--[[
Super class for updatable, drawable and destroyable things
]]
local Object = class("Object")

Object.priority = 0

-- Creates a new Object
function Object:new()
	-- Marks an entity for destruction
	self._destroy = false

	-- Marks an entity as already destroyed
	self._destroyed = false
end

--[[ Update and Draw callbacks ]]
-- Update the object before the physics simulation
-- > function Object:update()

-- Update the object after the physics simulation
-- > function Object:postUpdate()

-- Draw the object
-- > function Object:draw()

-- The following six optional callbacks all receive an Engine.GameState.Collision as an argument
--[[ Collision callbacks ]]
-- > function Object:onCollisionBegin(collision)
-- > function Object:onCollisionStay(collision)
-- > function Object:onCollisionEnd(collision)

--[[ Sensor callbacks ]]
-- > function Object:onSensorBegin(collision)
-- > function Object:onSensorStay(collision)
-- > function Object:onSensorEnd(collision)

-- Destroys the object
function Object:destroy()
	self._destroy = true
end

-- Called when the object is actually destroyed
function Object:onDestroy() end

-- Returns whether the object was set for destruction
function Object:isDestroyed()
	return self._destroy
end

-- Returns whether the object was destroyed already and cannot be used anymore
function Object:wasDestroyed()
	return self._destroyed
end

return Object
