--[[
The GameState editor
]]
local currentModule = (...):gsub("%.init$", "")
local class = heartbeat.class

local UserController = require(currentModule .. ".user_controller")
local GameState = heartbeat.GameState

local TestState = class("TestState", GameState)

-- Initializes a new test state
function TestState:initialize(gameStateClass)
	self.stateClass = gameStateClass or GameState

	self.user = self.ecs:addEntity(UserController())
end

return TestState
