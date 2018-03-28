--[[
The GameState editor
]]
local currentModule = miscMod.getModule(..., false)

local UserController = require(currentModule .. ".user_controller")
local GameState = require "Engine.GameState"

local Editor = class("Editor", GameState)

-- Initializes a new editor state
function Editor:initialize(gameStateClass)
	self.stateClass = gameStateClass or GameState

	self.timeScale = 0

	self.user = self.ecs:addEntity(UserController())
end

return Editor
