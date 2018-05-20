--[[
A wrapper for Löve-physics
]]
local lphysics = require "love.physics"

local physics = setmetatable({}, {
	__index = lphysics
})

return physics
