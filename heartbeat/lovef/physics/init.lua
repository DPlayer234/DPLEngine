--[[
A wrapper for Löve-physics
]]
local RequireTable = require "Heartbeat::RequireTable"
local lphysics = require "love.physics"

local physics = {}

-- Gets the set meter scale
physics.getMeter = lphysics.getMeter

-- Load submodules
local submoduleLoader = RequireTable((...):gsub("%.init$", ""))

submoduleLoader:loadInto(physics, "categories")

return physics
