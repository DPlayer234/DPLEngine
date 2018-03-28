--[[
Load the debugger utility
]]
--#exclude start
local currentModule = miscMod.getModule(..., true)

local ok, debugger = pcall(require, currentModule .. ".debugger")
if not ok then
	debugger = require "debugger"
end

do
	-- Make sure that values are as expected
	local function _c(data, reqType)
		return type(data) == (reqType or "function")
	end

	assert(
		_c(debugger.allowFunctionIndex) and _c(debugger.monitorGlobal) and
		_c(debugger.newCommand) and _c(debugger.aliasCommand) and
		_c(debugger.addUpdate) and _c(debugger.varDisplay) and
		_c(debugger.isActive),
		"Incorrect debugger? Unexpected data types."
	)

	assert(
		_c(debugger.isActive(), "boolean"),
		"Incorrect debugger? Unexpected return value."
	)
end

do
	-- Load profiler, if it's there
	local ok, profile = pcall(require, currentModule .. ".profile")
	if not ok then
		ok, profile = pcall(require, "profile")
	end
	if ok then debugger.setProfiler(profile) end
end

debugger.doTempPrint = false

require(currentModule .. ".add_commands")(debugger)
require(currentModule .. ".add_aliases")(debugger)

love.errhand = debugger.errhand

-- Add as global variable
_debug = debugger()

debugger.allowFunctionIndex(true)
debugger.monitorGlobal()
--#exclude end
