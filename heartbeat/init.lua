--[[
Quick loading the engine itself
]]
local currentModule = (...):gsub("%.init$", "")

-- Make sure a compatible class library is loaded.
assert(pcall(function()
	local assType = function(v, t) assert(type(v) == t) end

	-- Check class structure
	local Test = class("Test")
	assType(Test.BASE, "table")
	assType(Test.NAME, "string")
	assType(Test.CHILDREN, "table")
	assert(Test.PARENT == class.Default)

	-- Abstract class so far == not instantiatable
	assert(not pcall(function() Test() end))

	-- Add constructor == no longer abstract
	function Test:new() end

	local testValue = {}

	-- Create and test instance
	local test = Test() {
		testValue = testValue
	}
	assert(test:type() == "Test")
	assert(test:typeOf("Test"))
	assert(test:typeOf("Default"))
	assert(test.testValue == testValue)

	local itest = test:instantiate()
	assert(itest:type() == test:type())
	assert(itest.testValue == testValue)
end), "The library loaded into the global variable 'class' is not a Heartbeat-compatible class library.")

-- Hooking require
require(currentModule .. "._preload")

return require "Heartbeat"
