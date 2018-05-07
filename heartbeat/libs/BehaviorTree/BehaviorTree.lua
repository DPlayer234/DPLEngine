--[[
This is a BehaviorTree.
It really doesn't do a lot, you may as well just use the nodes directly.
]]
local class = require "Heartbeat::class"

local BehaviorTree = class("BehaviorTree")

BehaviorTree.Node     = require "Heartbeat::BehaviorTree::Node"
BehaviorTree.Task     = require "Heartbeat::BehaviorTree::Task"
BehaviorTree.Selector = require "Heartbeat::BehaviorTree::Selector"
BehaviorTree.Sequence = require "Heartbeat::BehaviorTree::Sequence"
BehaviorTree.Parallel = require "Heartbeat::BehaviorTree::Parallel"

-- Creates a new, empty BehaviorTree
function BehaviorTree:new()
	self._root = nil
end

-- Gets the root node
function BehaviorTree:getRoot()
	return self._root
end

-- Sets the root node. It is attached as a child to a dummy node.
function BehaviorTree:setRoot(node)
	BehaviorTree.Node():addNode(node)
	self._root = node
end

-- Continues the execution
function BehaviorTree:continue(...)
	if self:getRoot() then
		return self:getRoot():continue(...)
	end
end

return BehaviorTree
