--[[
This is similar to an EventStore, however was optimized to have functions added once
and to run them in a group. Handlers can be copied and support + and - operators in
the way that C# delegates support them. This creates a new copied instance as well.
]]
local table = table
local class = require "Heartbeat::class"

local Handler = class("Handler")

-- Create a new Handler
function Handler:new()
	self._list = {}
end

-- Gets the index of a function in the handler list.
-- Returns nil if it's not contained.
function Handler:getIndex(func)
	for i=1, #self._list do
		if self._list[i] == func then
			return i
		end
	end
	return nil
end

-- Returns whether the handler has the function.
function Handler:has(func)
	return self:getIndex(func) ~= nil
end

-- Adds a function if it not contained already.
function Handler:add(func)
	if not self:has(func) then
		self._list[#self._list + 1] = func
	end
end

-- Removes a function if it is contained.
function Handler:remove(func)
	local index = self:getIndex(func)
	if index ~= nil then
		table.remove(self._list, index)
	end
end

-- Calls all handler functions.
function Handler:handle(...)
	for i=1, #self._list do
		self._list[i](...)
	end
end

-- Creates an identical copy of this handler
function Handler:instantiate()
	local instance = Handler()

	for i=1, #self._list do
		instance._list[i] = self._list[i]
	end

	return instance
end

-- Allow calling the handler like a function
Handler.__call = Handler.handle

-- The (+) Operator creates a new handler with the new function added.
-- The handler needs to be on the left.
function Handler:__add(func)
	return self:instantiate():add(func)
end

-- The (-) Operator creates a new handler with the function removed.
-- The handler needs to be on the left.
function Handler:__sub(func)
	return self:instantiate():remove(func)
end

return Handler
