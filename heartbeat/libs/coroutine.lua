--[[
Easy to use coroutines
]]
local coroutine = coroutine
local assert = assert
local class = require "Heartbeat.class"

local Coroutine = class("Coroutine")

-- Returns all arguments passed except the first
local function returnFrom2nd(first, ...)
	return ...
end

-- Creates a new coroutine
function Coroutine:new(closure)
	self._thread = coroutine.create(closure)
end

-- Returns the current coroutine status
function Coroutine:getStatus()
	return coroutine.status(self._thread)
end

-- Returns the Lua coroutine object
function Coroutine:getThread()
	return self._thread
end

-- Resumes the coroutine and returns what it yields.
-- Throws an error if the coroutine throws one.
function Coroutine:resume(...)
	if self:getStatus() ~= "suspended" then return end
	return returnFrom2nd(assert(coroutine.resume(self._thread, ...)))
end

-- Resumes the coroutine.
-- If it didn't throw any errors, returns true and any yielded values.
-- Otherwise returns false followed by the error message.
function Coroutine:resumeProtected(...)
	return coroutine.resume(self._thread, ...)
end

Coroutine.__call = Coroutine.resume

return Coroutine
