--[[
The engine itself
]]
local table = table
local assert = assert
local ltimer = require "love.timer"
local class = require "Heartbeat::class"
local Timer = require "Heartbeat::Timer"

-- Class for the game engine
local Heartbeat = class("Heartbeat")

local ES_IDLE              = "idle" --#const
local ES_INITIALIZE        = "initialize" --#const
local ES_TIMER_UPDATE      = "timer:update" --#const
local ES_GAME_STATE_UPDATE = "gameState:update" --#const
local ES_GAME_STATE_DRAW   = "gameState:draw" --#const

-- Add class library
Heartbeat.class = require "Heartbeat::class"

-- Load primary classes
Heartbeat.ECS         = require "Heartbeat::ECS"
Heartbeat.GameState   = require "Heartbeat::GameState"
Heartbeat.SubState    = require "Heartbeat::SubState"
Heartbeat.Initializer = require "Heartbeat::Initializer"

-- Quick access
Heartbeat.entities   = require "Heartbeat::entities"
Heartbeat.components = require "Heartbeat::components"

-- Load Libraries
Heartbeat.lovef = require "Heartbeat::lovef"

for k, v in pairs(require "Heartbeat::libs") do
	Heartbeat[k] = v
end

-- Instantiates a new engine state
function Heartbeat:new()
	self._gameStates = {}
	self._engineState = ES_IDLE

	self.timer = Timer()
	self.usesInput = false

	self.initializer = Heartbeat.Initializer(self)
end

-- Initializes the engine
function Heartbeat:initialize(args)
	self._engineState = ES_INITIALIZE

	self.initializer:initialize(args)

	self._engineState = ES_IDLE
end

-- Returns the currently active game state
function Heartbeat:getActiveGameState()
	return self:getGameState(0)
end

-- Returns the game state at the given depth.
-- 0 is the active game state, 1 is the state that becomes active when the current one is popped etc.
function Heartbeat:getGameState(depth)
	return self._gameStates[self:getGameStateCount() - depth]
end

-- Returns the amount of game states on the stack
function Heartbeat:getGameStateCount()
	return #self._gameStates
end

-- Pushes the game state onto the stack
function Heartbeat:pushGameState(gameState)
	assert(gameState:typeOf("GameState"), "Can only push objects of type 'GameState' as a game state.")
	assert(not gameState:hasHeartbeat(), "GameStates can only be pushed once.")

	local state = self:getActiveGameState()
	if state then state:_onPause() end

	self._gameStates[#self._gameStates + 1] = gameState

	gameState.heartbeat = self
	gameState:initialize()

	gameState:_onResume()

	if self:getEngineState() == ES_GAME_STATE_UPDATE then
		gameState:update(ltimer.getDelta())
	end
end

-- Pops the current game state of the stack
function Heartbeat:popGameState()
	local state = self:getActiveGameState()
	if state then
		state:_onPause()
		state:destroy()
	end

	table.remove(self._gameStates, #self._gameStates)

	local state = self:getActiveGameState()
	if state then
		state:_onResume()

		if self:getEngineState() == ES_GAME_STATE_UPDATE then
			state:update(ltimer.getDelta())
		end
	end
end

-- Gets the current update state of the engine
function Heartbeat:getEngineState()
	return self._engineState
end

-- Updates the engine and active game state
function Heartbeat:update(dt)
	self._engineState = ES_TIMER_UPDATE

	self.timer:update(dt)

	self._engineState = ES_GAME_STATE_UPDATE

	local state = self:getActiveGameState()
	if state then state:update(dt) end

	self._engineState = ES_IDLE

	if self.usesInput then
		self.input.endFrame(dt)
	end
end

-- Draws the active game state
function Heartbeat:draw()
	self._engineState = ES_GAME_STATE_DRAW

	local state = self:getActiveGameState()
	if state then state:draw() end

	self._engineState = ES_IDLE
end

-- ToString, including the amount of stored game-states
function Heartbeat:__tostring()
	return ("Heartbeat: %d GSs"):format(self:getGameStateCount())
end

return Heartbeat()
