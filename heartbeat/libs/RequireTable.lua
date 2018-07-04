--[[
This returns an instantiatable object that will load elements from
a directory via require when first accessed.
]]
local class = require "Heartbeat::class"

local RequireTable = class("RequireTable")

-- No duplicate instances
RequireTable._instances = {}

-- Create a new one or return an existing, matching instance
function RequireTable:new(root)
	if not (root:find("[%./\\]$")) then
		root = root .. "."
	end

	if RequireTable._instances[root] then
		-- Return an existing instance for the given element
		return RequireTable._instances[root]
	else
		-- Initialize the instance
		self._root = root
		self._loaded = {}

		RequireTable._instances[root] = self
	end
end

-- Loads the content of a loaded element into a specified table.
-- This crashes if the loaded element is not a table itself.
function RequireTable:loadInto(table, element)
	for key, value in pairs(self[element]) do
		table[key] = value
	end

	return table
end

-- The main function making this work
function RequireTable:__index(element)
	if self._loaded[element] ~= nil then
		return self._loaded[element]
	end

	return self:_load(element)
end

function RequireTable:__tostring()
	return ("%s: %q"):format(self:type(), self._root)
end

-- Internally loads and stores the data
function RequireTable:_load(element)
	local value = require(self._root .. element)
	rawset(self._loaded, element, value)
	return value
end

return RequireTable
