--[[
This is a runnable task node.
It cannot have any children.
]]
local class = require "Heartbeat::class"
local Coroutine = require "Heartbeat::Coroutine"
local Node = require "Heartbeat::BehaviorTree::Node"

local Task = class("Task", Node)

-- Pass a function to the constructor to set the coroutine function to run.
-- The function should return 'false' if it did not exit successfully (which is whatever you define success to be)
-- and return 'true' if it did exit successfully. It may also yield to delay execution.
-- Also see Coroutines.
function Task:new(closure)
	self:Node()
	self._coroutine = Coroutine(closure)
end

function Task:reset()
	self.Node.reset(self)
	self._coroutine:reset()
end

function Task:addChild()
	error("Tasks cannot have children.")
end

function Task:continue(...)
	self:resetFinish()

	self._result = self._coroutine:resume(...) or false
	self._finished = self._coroutine:isDead()
end

return Task
