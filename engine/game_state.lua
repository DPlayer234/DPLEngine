--[[
The base class for any Game State
]]
local currentModule = miscMod.getModule(..., false)

local ECS = require(currentModule .. ".ecs")

-- The class
local GameState = class("GameState")

-- Creates a new GameState
function GameState:new()
	self.ecs = ECS()
end

-- Called when the state is pushed onto the stack
function GameState:pushed()
end

-- Called when the state is popped off the stack
function GameState:popped()
end

-- Called when the state is suspended and becomes inactive
function GameState:suspended()
end

-- Called when the state is resumed and becomes active once more
function GameState:resumed()
end

-- Updates the game state
function GameState:update(dt)
	self.ecs:update(dt)
end

-- Draws the game state
function GameState:draw()
	self.ecs:draw()
end

return GameState
