--[[
The GameState editor
]]
local currentModule = miscMod.getModule(..., false)

local Mouse = require(currentModule .. ".mouse")
local GameState = require "Engine.GameState"

local Editor = class("Editor", GameState)

-- Initializes a new editor state
function Editor:initialize(gameStateClass)
	self.stateClass = gameStateClass or GameState

	self.mouse = self.ecs:addEntity(Mouse())
end

return Editor
