--[[
The engine itself
]]
local currentModule = miscMod.getModule(..., false)

local physics    = require "love.physics"
local Timer      = require "libs.timer"
local EventStore = require "libs.event_store"

-- Class for the game engine
local Engine = class("Engine")

-- Load Libraries
Engine.Vector2   = require(currentModule .. ".libs.vector2")
Engine.Transform = require(currentModule .. ".libs.transform")

-- Load primary classes
Engine.GameState = require(currentModule .. ".game_state")
Engine.ECS       = require(currentModule .. ".ecs")

-- Instantiates a new engine state
function Engine:new()
	self._gameStates = {}
	self.timer = Timer()
end

-- Initializes the engine
function Engine:initialize(args)
	args = args or {}
	physics.setMeter(args.meter or 30)
end

-- Returns the currently active game state
function Engine:getGameState()
	return self._gameStates[#self._gameStates]
end

-- Pushes the game state onto the stack
function Engine:pushGameState(gameState)
	local state = self:getGameState()
	if state then state:suspended() end

	self._gameStates[#self._gameStates + 1] = gameState

	gameState:pushed()
end

-- Pops the current game state of the stack
function Engine:popGameState()
	local state = self:getGameState()
	if state then state:popped() end

	table.remove(self._gameStates, #self._gameStates)

	local state = self:getGameState()
	if state then state:resumed() end
end

-- Updates the engine and active game state
function Engine:update(dt)
	self.timer:update(dt)

	local state = self:getGameState()
	if state then state:update(dt) end
end

-- Draws the active game state
function Engine:draw()
	local state = self:getGameState()
	if state then state:draw() end
end

return Engine()
