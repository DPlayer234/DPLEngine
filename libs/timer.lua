--[[
Simple Timer Class
]]
local remove = table.remove
local unpack, type = unpack, type
local coroutine = coroutine

local Timer = {}

function Timer.construct()
	return {
		time = 0,
		tasks = {}
	}
end

function Timer:new(start)
	if start ~= nil then
		self.time = start
	end
end

local coroutineWait = function(time)
	return coroutine.yield(time)
end

local taskHandler = {
	["single"] = function(self, task, i)
		task.func()
		return remove(self.tasks, i)
	end,
	["repeat"] = function(self, task, i)
		task.func(-task.wait)
		if -task.wait > task.duration then
			return remove(self.tasks, i)
		end
	end,
	["coroutine"] = function(self, task, i)
		if coroutine.status(task.rout) == "suspended" then
			local ok, wait = coroutine.resume(task.rout, coroutineWait)
			if ok then
				task.wait = type(wait) == "number" and wait or 0
			end
		else
			return remove(self.tasks, i)
		end
	end
}

-- Updates the timer and tasks
function Timer:update(dt)
	self.time = self.time + dt

	for i=#self.tasks, 1, -1 do
		local task = self.tasks[i]

		task.wait = task.wait - dt
		if task.wait < 0 then
			taskHandler[task.type](self, task, i)
		end
	end
end

-- Queues a task to be executed after a set delay
-- func()
function Timer:queueTask(delay, func)
	self.tasks[#self.tasks+1] = {
		wait = delay,
		func = func,
		type = "single"
	}
end

-- Executes a task after a set delay for some time every update
-- func(totalTime)
function Timer:repeatTask(delay, duration, func)
	self.tasks[#self.tasks+1] = {
		wait = delay,
		duration = duration,
		func = func,
		type = "repeat"
	}
end

-- Executes a task as a coroutine
-- func(wait)
function Timer:coTask(func)
	self.tasks[#self.tasks+1] = {
		wait = 0,
		func = func,
		rout = coroutine.create(func),
		type = "coroutine"
	}
end

-- Resets the time and clears all tasks
function Timer:reset()
	self.time = 0
	self.tasks = {}
end

function Timer:__tostring()
	return ("%s: %.3fs; %d Tasks"):format(self:type(), self.time, #self.tasks)
end

return class("Timer", Timer)
