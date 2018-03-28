--[[
Convenient access to entity classes
Also converts 'ClassName' to 'class_name' for file access
]]
local currentModule = (...):gsub("%.init$", "")

local classToFileName = function(name)
	return name:gsub("[A-Z]", function(letter)
		return "_" .. letter:lower()
	end):gsub("^_", "")
end

return setmetatable({}, {
	__index = function(t, key)
		local value = require(currentModule .. "." .. classToFileName(key))
		rawset(t, key, value)
		return value
	end
})
