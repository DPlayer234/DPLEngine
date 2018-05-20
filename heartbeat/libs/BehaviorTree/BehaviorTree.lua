--[[
This is a BehaviorTree.
You create it by supplying a predefined data structure representing the nodes.
If you want to do this manually, use the node classes directly and use the root node
instead of the BehaviorTree.
]]
local class = require "Heartbeat::class"

local BehaviorTree = class("BehaviorTree")

BehaviorTree.Node     = require "Heartbeat::BehaviorTree::Node"
BehaviorTree.Task     = require "Heartbeat::BehaviorTree::Task"
BehaviorTree.Selector = require "Heartbeat::BehaviorTree::Selector"
BehaviorTree.Sequence = require "Heartbeat::BehaviorTree::Sequence"
BehaviorTree.Parallel = require "Heartbeat::BehaviorTree::Parallel"

-- Creates a new BehaviorTree based on the given data structure
function BehaviorTree:new(data)
	self._root = BehaviorTree.Node.createFromData(data)
end

-- Gets the root node
function BehaviorTree:getRoot()
	return self._root
end

-- Continues the execution
function BehaviorTree:continue(...)
	if self:getRoot() then
		return self:getRoot():continue(...)
	end
end

return BehaviorTree
