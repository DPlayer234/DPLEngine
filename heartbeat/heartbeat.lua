--[[
The engine itself
]]
local Timer = require "Heartbeat.Timer"

-- Class for the game engine
local Heartbeat = class("Heartbeat")

-- Load Libraries
Heartbeat.input      = require "Heartbeat.input"
Heartbeat.complex    = require "Heartbeat.complex"
Heartbeat.EventStore = require "Heartbeat.EventStore"
Heartbeat.Material   = require "Heartbeat.Material"
Heartbeat.mathf      = require "Heartbeat.mathf"
Heartbeat.Timer      = require "Heartbeat.Timer"
Heartbeat.Vector2    = require "Heartbeat.Vector2"
Heartbeat.Vector3    = require "Heartbeat.Vector3"
Heartbeat.Vector4    = require "Heartbeat.Vector4"

-- Load primary classes
Heartbeat.ECS         = require "Heartbeat.ECS"
Heartbeat.GameState   = require "Heartbeat.GameState"
Heartbeat.Initializer = require "Heartbeat.Initializer"

-- Quick access
Heartbeat.entities   = require "Heartbeat.entities"
Heartbeat.components = require "Heartbeat.components"

-- Instantiates a new engine state
function Heartbeat:new()
	self._gameStates = {}
	self.timer = Timer()
	self.usesInput = false

	self.initializer = Heartbeat.Initializer(self)
end

-- Initializes the engine
function Heartbeat:initialize(args)
	self.initializer:initialize(args)
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
	if not gameState:typeOf("GameState") then error("Can only push objects of type 'GameState' as a game state.") end

	local state = self:getActiveGameState()
	if state then state:suspended() end

	self._gameStates[#self._gameStates + 1] = gameState
	if gameState.heartbeat ~= self then
		gameState.heartbeat = self
		gameState:initialize()
	end

	gameState:pushed()
end

-- Pops the current game state of the stack
function Heartbeat:popGameState()
	local state = self:getActiveGameState()
	if state then state:popped() end

	table.remove(self._gameStates, #self._gameStates)

	local state = self:getActiveGameState()
	if state then state:resumed() end
end

-- Updates the engine and active game state
function Heartbeat:update(dt)
	self.timer:update(dt)

	local state = self:getActiveGameState()
	if state then state:update(dt) end

	if self.usesInput then
		self.input.endFrame(dt)
	end
end

-- Draws the active game state
function Heartbeat:draw()
	local state = self:getActiveGameState()
	if state then state:draw() end
end

-- ToString, including the amount of stored game-states
function Heartbeat:__tostring()
	return ("Heartbeat: %d GSs"):format(self:getGameStateCount())
end

return Heartbeat()
