--[[
The GameState editor
]]
local currentModule = (...):gsub("%.[^%.]+$", "")

local UserController = require(currentModule .. ".user_controller")
local GameState = require "Engine.GameState"

local Editor = class("Editor", GameState)

-- Initializes a new editor state
function Editor:initialize(gameStateClass)
	self.stateClass = gameStateClass or GameState

	self.timeScale = 0

	self.user = self.ecs:addEntity(UserController())
end

function Editor:pushed()
	self:resumed()
end

function Editor:popped()
	self:suspended()
end

function Editor:resumed()
end

function Editor:suspended()
end

return Editor
