--[[
The base class for any Game State
]]
local physicsWorldDraw = require "dev.physics_world_draw"
local physics = require "love.physics"

local ECS            = require "Engine.ECS"
local Transformation = require "Engine.Transformation"
local Collision      = require "Engine.GameState.Collision"

local Timer = require "libs.timer"

-- The class
local GameState = class("GameState")

GameState.Collision = Collision

-- Creates a new GameState
function GameState:new()
	self.world = physics.newWorld(0, 9.85 * physics.getMeter(), true)
	self:_setWorldCallbacks()

	self.timer = Timer()
	self.timeScale = 1
	self.transformation = Transformation()

	self.ecs = ECS()
	self.ecs.world = self.world
	self.ecs.timer = self.timer
	self.ecs.transformation = self.transformation
	self.ecs.gameState = self

	self.engine = nil
end

-- Initializes the game state and, f.e., sets the entities and terrain used when instantiating
-- Called when the game state is first pushed
function GameState:initialize() end

-- Called when the state is pushed onto the stack
function GameState:pushed() end

-- Called when the state is popped off the stack
function GameState:popped() end

-- Called when the state is suspended and becomes inactive
function GameState:suspended() end

-- Called when the state is resumed and becomes active once more
function GameState:resumed() end

-- Updates the game state
function GameState:update(dt)
	dt = dt * self.timeScale
	self.ecs.deltaTime = dt

	self.ecs:update()

	self.world:update(dt)
	self.timer:update(dt)

	self.ecs:postUpdate()
end

-- Draws the game state
function GameState:draw()
	self.transformation:apply()
	self.ecs:draw()

	physicsWorldDraw(self.world, 0, 0, love.graphics.getDimensions())
end

-- Destroys the ECS and associated destroyable resources
function GameState:destroy()
	self.ecs:destroy()

	-- Disabled because it MAY cause crashes.
	-- It's still being garbage-collected, so it shouldn't cause any issues.
	--self.world:destroy()
end

-- Sets the callbacks to the world
function GameState:_setWorldCallbacks()
	-- All callbacks receive the two fixtures and their contact point
	local function getCallback(sensor, collision)
		return function(fixA, fixB, contact)
			local colA = fixA:getUserData()
			local colB = fixB:getUserData()

			local cntA = Collision(contact, colA, colB, false)
			local cntB = Collision(contact, colB, colA, true)

			if colA:isSensor() or colB:isSensor() then
				colA.entity:_callEvent(sensor, cntA)
				colB.entity:_callEvent(sensor, cntB)
			else
				colA.entity:_callEvent(collision, cntA)
				colB.entity:_callEvent(collision, cntB)
			end
		end
	end

	self.world:setCallbacks(
		getCallback("onSensorBegin", "onCollisionBegin"), -- Begin
		getCallback("onSensorEnd",   "onCollisionEnd"), -- End
		getCallback("onSensorStay",  "onCollisionStay") -- PreSolve
	)
end

return GameState
