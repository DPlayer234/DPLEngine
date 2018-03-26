--[[
Formatting time. It's kinda useful...
]]
local floor, min = math.floor, math.min

local formatTime = {}

local TimeFormatter = {}
do
	local LIMIT_MARGIN = 0.999999 --#const

	function TimeFormatter:new(func, limit)
		self.limit = limit
		self.func = func
	end

	function TimeFormatter:normal(time)
		return self.func(time)
	end

	function TimeFormatter:clamped(time)
		return self.func(min(time, self.limit * LIMIT_MARGIN))
	end

	function TimeFormatter:wrapped(time)
		return self.func(time % self.limit)
	end

	TimeFormatter.__call = TimeFormatter.normal

	TimeFormatter = class("TimeFormatter", TimeFormatter)
end

local MAX_MINUTES = 6000 --#const
local MAX_HOURS = 360000 --#const

-- Formats Minutes, Seconds and Centiseconds
formatTime.minutes = TimeFormatter(function(time)
	local centiSeconds = (time%1)*100

	time = floor(time)
	local seconds = time%60

	time = floor(time*(1/60))

	return ("%02d:%02d,%02d"):format(time, seconds, centiSeconds)
end, MAX_MINUTES)

-- Formats Hours, Minutes and Seconds
formatTime.hours = TimeFormatter(function(time)
	time = floor(time)
	local seconds = time%60

	time = floor(time*(1/60))
	local minutes = time%60

	time = floor(time*(1/60))

	return ("%02d:%02d:%02d"):format(time, minutes, seconds)
end, MAX_HOURS)

return formatTime
