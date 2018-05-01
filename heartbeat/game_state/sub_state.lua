--[[
The class for any sub state
]]
local table = table
local class = require "Heartbeat.class"

local SubState = class("SubState", require "Heartbeat.GameState")

-- Creates a new SubState
function SubState:new()
	self:GameState()

	self._parent = nil
end

-- Gets the parent state.
function SubState:getParentState()
	return self._parent
end

-- This is invalid here
function SubState:update(dt)
	error("Cannot use 'update' on SubStates.")
end

-- The update part before the physics simulation
function SubState:preUpdate(dt)
	dt = dt * self.timeScale
	self.ecs.deltaTime = dt

	self.ecs:update()
end

-- The update part after the physics simulation
function SubState:postUpdate(dt)
	self.timer:update(dt * self.timeScale)

	self.ecs:postUpdate()
end

-- In addition to the functionality of GameState:destroy, also removes itself from its parent's list
function SubState:destroy()
	for i=1, #self._parent._subs do
		if self._parent._subs[i] == self then
			table.remove(self._parent._subs, i)
			break
		end
	end

	self.SubState.destroy(self)
end

-- This does nothing here
function SubState:_setPhysicsWorld()
	self.world = nil
end

return SubState
