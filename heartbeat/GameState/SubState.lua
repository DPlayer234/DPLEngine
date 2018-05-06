--[[
The class for any sub state
]]
local table = table
local class = require "Heartbeat::class"

local SubState = class("SubState", require "Heartbeat::GameState")

-- This is should not be considered to be a GameState
SubState.TYPEOF.GameState = false

-- Creates a new SubState
function SubState:new()
	self:GameState()

	self._parent = nil
end

-- Gets the parent state.
function SubState:getParentState()
	return self._parent
end

-- Returns the main game state
function SubState:getMainState()
	return self:getParentState()
end

-- This is invalid here
function SubState:update(dt)
	error("Cannot use 'update' on SubStates.")
end

-- The update part before the physics simulation
function SubState:preUpdate(dt)
	self._dt = dt * self._timeScale
	self.ecs.deltaTime = self._dt

	self.ecs:update()
end

-- The update part after the physics simulation
function SubState:postUpdate(dt)
	self.timer:update(self._dt)

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

	self.GameState.destroy(self)
end

-- Called when added to a parent state
function SubState:_onAdd()
	self.world = self._parent.world
	self.input = self._parent.input

	self.ecs.world = self.world
	self.ecs.input = self.input
end

-- This does nothing here
function SubState:_setPhysicsWorld()
	self.world = nil
end

return SubState
