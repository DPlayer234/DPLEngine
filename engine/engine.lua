--[[
The engine itself
]]
local Timer = require "libs.timer"

-- Class for the game engine
local Engine = class("Engine")

-- Load Libraries
Engine.input     = require "Engine.input"
Engine.Mat3x3    = require "Engine.Mat3x3"
Engine.Vector2   = require "Engine.Vector2"
Engine.Transform = require "Engine.Transform"

-- Load primary classes
Engine.ECS         = require "Engine.ECS"
Engine.GameState   = require "Engine.GameState"
Engine.Initializer = require "Engine.Initializer"

-- Quick access
Engine.entities   = require "Engine.entities"
Engine.components = require "Engine.components"

-- Instantiates a new engine state
function Engine:new()
	self._gameStates = {}
	self.timer = Timer()

	self.initializer = Engine.Initializer(self)
end

-- Initializes the engine
function Engine:initialize(args)
	self.initializer:initialize(args)
end

-- Returns the currently active game state
function Engine:getGameState()
	return self._gameStates[#self._gameStates]
end

-- Pushes the game state onto the stack
function Engine:pushGameState(gameState)
	if not gameState:typeOf("GameState") then error("Can only push objects of type 'GameState' to the Engine.") end

	local state = self:getGameState()
	if state then state:suspended() end

	self._gameStates[#self._gameStates + 1] = gameState

	gameState:pushed()
end

-- Pops the current game state of the stack
function Engine:popGameState()
	local state = self:getGameState()
	if state then
		state:popped()
		state:destroy()
	end

	table.remove(self._gameStates, #self._gameStates)

	local state = self:getGameState()
	if state then state:resumed() end
end

-- Updates the engine and active game state
function Engine:update(dt)
	self.timer:update(dt)

	local state = self:getGameState()
	if state then state:update(dt) end

	self.input.endFrame(dt)
end

-- Draws the active game state
function Engine:draw()
	local state = self:getGameState()
	if state then state:draw() end
end

-- For optional libraries
function Engine:__index(key)
	local value
	if key == "Editor" then
		value = require "Engine.Editor"
	end

	Engine[key] = value
	return value
end

return Engine()
