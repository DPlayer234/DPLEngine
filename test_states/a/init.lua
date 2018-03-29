--[[
The GameState editor
]]
local currentModule = (...):gsub("%.init$", "")

local UserController = require(currentModule .. ".user_controller")
local GameState = require "Engine.GameState"

local TestState = class("TestState", GameState)

-- Initializes a new test state
function TestState:initialize(gameStateClass)
	self.stateClass = gameStateClass or GameState

	self.user = self.ecs:addEntity(UserController())
end

function TestState:pushed()
	self:resumed()
end

function TestState:popped()
	self:suspended()
end

function TestState:resumed()
end

function TestState:suspended()
end

return TestState
