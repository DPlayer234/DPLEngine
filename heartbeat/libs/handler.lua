--[[
This is similar to a handler-type EventStore but faster
]]
local class = require "Heartbeat.class"

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
-- Returns the original handler.
function Handler:add(func)
	if not self:has(func) then
		self._list[#self._list + 1] = func
	end
	return self
end

-- Removes a function if it is contained.
-- Returns the original handler.
function Handler:remove(func)
	local index = self:getIndex(func)
	if index ~= nil then
		table.remove(self._list, index)
	end
	return self
end

-- Calls all handler functions and returns the handler.
function Handler:handle(...)
	for i=1, #self._list do
		self._list[i](...)
	end
	return self
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
