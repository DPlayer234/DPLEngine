--[[
Misc. functions for module management.
All these functions expect that the require path was used with periods (".") rather than slashes ("/").
Feel free to override 'module' with this; calling this module will call the original 'module' function.
]]
local module = module
local miscMod = setmetatable({}, {
	-- Call the original module function when attempting to call this.
	__call = function(self, ...)
		return module(...)
	end
})

-- Gets the module name.
-- Use to find the base require directory within a module.
function miscMod.getModule(requirePath, isInit)
	return (requirePath:gsub(isInit and "%.init$" or "%.[^%.]+$", ""))
end

-- Gets the path to the module directory.
-- Use this to find the effective directory within a module.
function miscMod.getPath(requirePath, isInit)
	return (miscMod.getModule(requirePath, isInit):gsub("%.", "/"))
end

-- Throws an error if the module path this was required as is not the expected one.
function miscMod.assert(real, expected)
	if real ~= expected then
		return error(("Module '%s' should be '%s'!"):format(real, expected))
	end
end

return miscMod
