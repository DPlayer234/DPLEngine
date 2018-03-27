--[[
The engine itself
]]
local currentModule = miscMod.getModule(..., true)

local physics = require "love.physics"

local EventStore = require "libs.event_store"
local Timer      = require "libs.timer"

-- Class for the game engine
local Engine = class("Engine")

-- Load Libraries
local libs = require(currentModule .. ".libs")

Engine.Vector2   = libs.Vector2
Engine.Rotation  = libs.Rotation
Engine.Transform = libs.Transform

-- Load primary classes
Engine.GameState   = require(currentModule .. ".game_state")
Engine.ECS         = require(currentModule .. ".ecs")
Engine.Initializer = require(currentModule .. ".initializer")

-- Stores functions to be called upon the end of the initialization
local onInitDone = EventStore()

-- Preload Hooker
require(currentModule .. ".preload")

-- Instantiates a new engine state
function Engine:new()
	self._entities = {}
	self._components = {}

	self.initializer = Engine.Initializer(self)

	self._gameStates = {}
	self.timer = Timer()
end

-- Initializes the engine
function Engine:initialize(meterScale)
	physics.setMeter(meterScale or 30)

	self.initializer:loadEntities()
	self.initializer:loadComponents()

	onInitDone()
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

-- Gets a loaded entity class by name
function Engine:getEntityType(entityType)
	return self._entities[entityType]
end

-- Gets a loaded component class by name
function Engine:getComponentType(componentType)
	return self._components[componentType]
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

-- Adds an event to be called after initialization
function Engine.callAfterInit(event)
	return onInitDone:add(event)
end

return Engine()
