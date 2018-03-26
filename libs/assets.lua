--[[
Simple library for loading and discarding data via garbage collector, that may not always be in use.
	loadingStorage = assets(name, constructor)
loadingStorage will also be stored as assets[name].
To get a value from the loadingStorage, do:
	myValue = loadingStorage[keyToGet]
	myValue = loadingStorage(keyToGet, ...)
If the resource is not in memory, it will call the constructor and return its output, meanwhile storing it for
latter re-usage.
]]

local rawget, rawset = rawget, rawset
local setmetatable, getmetatable = setmetatable, getmetatable
local type, assert = type, assert

local assets = {}

local __constructor = setmetatable({}, { __mode = "k" })

local metaTable = {
	__mode = "v",
	__call = function(t, k, ...)
		local v = rawget(t, k)
		if v ~= nil then
			return v
		else
			local new = __constructor[t](k, ...)
			rawset(t, k, new)
			return new
		end
	end,
	__index = function(t, k)
		local new = __constructor[t](k)
		rawset(t, k, new)
		return new
	end,
	__newindex = function(t, k, v)
		rawset(t, k, v)
	end,
	__tostring = function(t)
		return "store-"..tostring(__constructor[t])
	end
}

-- Creates a new store-function with name
function assets:__call(name, constructor)
	if constructor == nil then return self(nil, name) end

	assert(type(constructor) == "function", "Argument #2 to 'assets' (constructor) is not a function.")
	local new = setmetatable({}, metaTable)
	__constructor[new] = constructor

	if name ~= nil then rawset(self, name, new) end

	return new
end

-- Sets whether the GC is allowed to collect data loaded via a store-function
-- Defaults to 'true'
function assets.setAllowGC(allow)
	metaTable.__mode = allow and "v" or ""
end

-- Gets whether the GC is allowed to collect data
function assets.getAllowGC()
	return (metaTable.__mode:find("v")) and true or false
end

assets.__constructor = __constructor
assets.__index = assets

assets = setmetatable({}, assets)

return assets
