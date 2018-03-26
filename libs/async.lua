--[[
Library for handling asynchronous actions via threads.
]]
local love = love
local table = table
local pairs, unpack, tonumber, assert = pairs, unpack, tonumber, assert

local async
async = {
	list = {},
	crashOnError = true,
	__call = function(self)
		return setmetatable({
			list = {},
			crashOnError = true
		}, async)
	end
}
async.__index = async
setmetatable(async, async)

local action = setmetatable({}, {
	__index = function(t, k)
		local v = function(...)
			return coroutine.yield {k, ...}
		end
		t[k] = v
		return v
	end
})

local function handle(v, gets)
	local ok, args = assert(coroutine.resume(v.corout, gets))

	if args == nil then
		-- Function probably returned
		v.toThreadChannel:push("kill")
		return true
	elseif type(args) ~= "table" then
		error("Invalid yield!")
	else
		v.toThreadChannel:push(args)
	end
end

function async:add(cofunc)
	local thread = love.thread.newThread([[
		local toThreadChannel, fromThreadChannel = ...

		local commands = {
			require = function(path)
				require(path)
			end,
			rf = function(path, key, ...)
				return require(path)[key](...)
			end,
			code = function(code, ...)
				return assert(load(code))(...)
			end,
		}

		while true do
			collectgarbage()

			local args = toThreadChannel:demand()
			if args == "kill" then
				return
			elseif type(args) == "table" then
				local command = table.remove(args, 1)

				local value = assert(commands[command], "Unknown command: "..tostring(command))(unpack(args))

				fromThreadChannel:push(value or false)
			end
		end
	]])

	local toThreadChannel, fromThreadChannel = love.thread.newChannel(), love.thread.newChannel()

	local corout = coroutine.create(cofunc)

	local id = #self.list + 1
	local v = {
		thread = thread,
		toThreadChannel = toThreadChannel, fromThreadChannel = fromThreadChannel,
		corout = corout
	}

	thread:start(toThreadChannel, fromThreadChannel)

	if not handle(v, action) then
		self.list[id] = v
	end

	return id
end

function async:remove(id)
	self.list[id] = nil
end

function async:update()
	for k,v in pairs(self.list) do
		local gets = v.fromThreadChannel:pop()
		if gets ~= nil then
			if handle(v, gets) then
				self.list[k] = nil
			end
		elseif v.thread:getError() then
			(self.crashOnError and error or print)(v.thread:getError())
		end
	end
end

function async:clear()
	self.list = {}
end

return async
