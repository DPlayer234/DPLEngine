--[[
Stores events to be handled (executed) later.
'function' type EventStores:
	Events are functions.
	An event gets passed all additional arguments to *:add(event, ...)
'handler' type EventStores:
	Similar to 'function' type, except that the event is always called with all the
	arguments passed to *:handle(...) and is (almost) never removed.
	Could be used wherever a function is expected, including Löve-Handlers.
	If the given function returns anything other than nil or false, the event is removed.
'value' type EventStores:
	Events are values.
	The handler gets passed the event, current index and total count of events.
If any given function yields, it is paused until the EventStore is handling events again.
]]
local assert = assert
local remove = table.remove
local coroutine = coroutine
local class = require "Heartbeat::class"

local EventStore = class("EventStore")

-- Initializes a new Event Store.
--[[
'arg' is a table with the following keys: (first listed value is the default)
	mode = "queue" / "stack" (execution vs. add order)
	type = "function" / "handler" / "value"
	handler (if type == "value", what function to use for handling values)
]]
function EventStore:new(arg)
	arg = arg or {}

	self.mode = arg.mode or "queue"
	self.eventType = arg.type or "function"

	if self.eventType == "value" then
		self.valueHandler = arg.handler
	end

	self.list = {}
	self.tempQueue = false

	self:validate()
end

-- Creating event coroutines
local getCoEventFunction = {
	["function"] = function(self, event)
		return function(...)--[[EventStore.funcCoroutine]]
			coroutine.yield()
			return event(...)
		end
	end,
	["handler"] = function(self, event)--[[EventStore.handlerCoroutine]]
		return function()
			while true do
				if event(coroutine.yield()) then return end
			end
		end
	end,
	["value"] = function(self, event)
		return function()--[[EventStore.valueCoroutine]]
			return self.valueHandler(event, coroutine.yield())
		end
	end
}

-- Validates its settings
function EventStore:validate()
	assert(self.mode == "queue" or self.mode == "stack", "Mode must be 'queue' or 'stack'!")
	assert(getCoEventFunction[self.eventType], "Event Type is invalid!")
	assert(self.eventType ~= "value" or self.valueHandler, "'value' type EventStore needs a value handler!")
end

-- Add an event to the store (including arguments)
-- Return the event coroutine.
function EventStore:add(event, ...)
	local coEvent = coroutine.create(getCoEventFunction[self.eventType](self, event))
	coroutine.resume(coEvent, ...)

	local list = self.tempQueue or self.list

	list[#list+1] = {
		event = event,
		rout = coEvent
	}
	return coEvent
end

-- Returns whether the event is already added.
-- Unreliable if called during handling.
function EventStore:has(event)
	for i=1, #self.list do
		local this = self.list[i]
		if this.event == event or this.rout == event then
			return true
		end
	end
	return false
end

-- Removes an event by either the original value or by its coroutine.
-- It is illegal to call this during handling.
function EventStore:remove(event)
	assert(not self.tempQueue, "Cannot remove Events while handling.")

	for i=1, #self.list do
		local this = self.list[i]
		if this.event == event or this.rout == event then
			return remove(self.list, i)
		end
	end
end

-- Like EventStore:add(event, ...), but only adds when EventStore:has(event) returns false.
-- Either returns the event coroutine or nil.
function EventStore:addOnce(event, ...)
	if not self:has(event) then
		return self:add(event, ...)
	end
end

-- Returns the amount of events currently in the store
function EventStore:getCount()
	return #self.list
end

-- Clears all events from the queue
function EventStore:clear()
	self.list = {}
end

-- Handles a single event by resuming the coroutine and raising an error if needed
local function handleEvent(self, this, ...)
	local ok, errormsg = coroutine.resume(this.rout, ...)
	if ok then
		return coroutine.status(this.rout) == "suspended"
	else
		self.__errorBy = this
		error(debug.traceback(this.rout, errormsg))
	end
end

-- Handles all events
function EventStore:handle(...)
	if not self.list[1] then return end

	self.tempQueue = {}

	if self.mode == "stack" then
	 	for i=self:getCount(), 1, -1 do
			local this = remove(self.list, i)
			if handleEvent(self, this, ...) then
				self.list[#self.list+1] = this
			end
		end
	else
		for i=1, self:getCount(), 1 do
			local this = remove(self.list, 1)
			if handleEvent(self, this, ...) then
				self.list[#self.list+1] = this
			end
		end
	end

	for i=1, #self.tempQueue do
		self.list[#self.list+1] = self.tempQueue[i]
	end
	self.tempQueue = false
end

EventStore.__call = EventStore.handle

function EventStore:__tostring()
	return ("%s: %s-%s"):format(self:type(), self.eventType, self.mode)
end

return EventStore
