--[[
This returns an instantiatable object that will load elements from
a directory via require when first accessed.
]]
local TYPE_NAME = "RequireTable" --#const

-- No duplicate instances
local instances = {}

-- Define a custom class-like structure
local RequireTable = setmetatable({}, {
	__call = function(self, root)
		if not (root:find("[%./\\]$")) then
			root = root .. "."
		end

		if instances[root] then
			-- Return an existing instance for the given element
			return instances[root]
		else
			-- Create a new instance
			local new = setmetatable({
				_root = root
			}, self)

			instances[root] = new

			return new
		end
	end
})

-- The main function making this work
function RequireTable:__index(element)
	if RequireTable[element] ~= nil then
		return RequireTable[element]
	end

	return self:_load(element)
end

-- Return the type of the instance (Compatability)
function RequireTable:type()
	return TYPE_NAME
end

-- Is the instance of a given type? (Compatability)
function RequireTable:typeOf(compare)
	return TYPE_NAME == compare
end

-- Internally loads and stores the data
function RequireTable:_load(element)
	local value = require(self._root .. element)
	rawset(self, element, value)
	return value
end

return RequireTable
