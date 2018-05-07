--[[
Parallel runs all its children every continue until all of them are finished.
Its result is the 'and' of all its children's results.
]]
local class = require "Heartbeat::class"
local Node = require "Heartbeat::BehaviorTree::Node"

local Parallel = class("Parallel", Node)

function Parallel:new(closure)
	self:Node()

	self._finChildren = {}
end

function Parallel:reset()
	self.Node.reset(self)

	for i=1, #self._finChildren do
		self._finChildren[i] = false
	end
end

function Parallel:addNode(node)
	self.Node.addNode(node)

	self._finChildren[#self._finChildren + 1] = false
end

function Parallel:continue(...)
	self:resetFinish()
	self._result = true

	for i=1, self:getChildCount() do
		local child = self:getChild(i)

		if not self._finChildren[i] then
			-- Continue the child if is not finished
			child:continue(...)
		end

		local finChild = child:isFinished()
		self._finChildren[i] = finChild

		self._result = self._result and child:getResult()
		self._finished = self._finished and finChild
	end
end

return Parallel
