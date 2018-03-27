--[[
The base class for any Game State
]]
local currentModule = miscMod.getModule(..., false)

local physicsWorldDraw = require "dev.physics_world_draw"
local physics = require "love.physics"

local ECS = require(currentModule .. ".ecs")

-- The class
local GameState = class("GameState")

-- Creates a new GameState
function GameState:new()
	self.world = physics.newWorld(0, 9.85 * physics.getMeter(), true)

	self.ecs = ECS(self.world)
end

-- Called when the state is pushed onto the stack
function GameState:pushed()
end

-- Called when the state is popped off the stack
function GameState:popped()
	self.world:destroy()
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
	self.world:update(dt)
	self.ecs:postUpdate(dt)
end

-- Draws the game state
function GameState:draw()
	self.ecs:draw()

	physicsWorldDraw(self.world, 0, 0, love.graphics.getDimensions())
end

return GameState
