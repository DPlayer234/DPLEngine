--[[
The base class for any Game State
]]
local currentModule = miscMod.getModule(..., false)

local physicsWorldDraw = require "dev.physics_world_draw"
local physics = require "love.physics"

local ECS = require(currentModule .. ".ecs")
local Timer = require "libs.timer"

-- The class
local GameState = class("GameState")

-- Creates a new GameState
function GameState:new()
	self.world = physics.newWorld(0, 9.85 * physics.getMeter(), true)
	self:_setWorldCallbacks()

	self.timer = Timer()

	self.ecs = ECS()
	self.ecs.world = self.world
	self.ecs.timer = self.timer
end

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
	self.ecs:update(dt)

	self.world:update(dt)
	self.timer:update(dt)

	self.ecs:postUpdate(dt)
end

-- Draws the game state
function GameState:draw()
	self.ecs:draw()

	physicsWorldDraw(self.world, 0, 0, love.graphics.getDimensions())
end

-- Sets the callbacks to the world
function GameState:_setWorldCallbacks()
	-- All callbacks receive the two fixtures and their contact point
	self.world:setCallbacks(
		function(a, b, contact)
			-- Begin
			local entityA = a:getUserData().entity
			local entityB = b:getUserData().entity

			if a:isSensor() or b:isSensor() then
				entityA:onSensorBegin(entityB, contact)
				entityB:onSensorBegin(entityA, contact)
			else
				entityA:onCollisionBegin(entityB, contact)
				entityB:onCollisionBegin(entityA, contact)
			end
		end,
		function(a, b, contact)
			-- End
			local entityA = a:getUserData().entity
			local entityB = b:getUserData().entity

			if a:isSensor() or b:isSensor() then
				entityA:onSensorEnd(entityB, contact)
				entityB:onSensorEnd(entityA, contact)
			else
				entityA:onCollisionEnd(entityB, contact)
				entityB:onCollisionEnd(entityA, contact)
			end
		end,
		function(a, b, contact)
			-- PreSolve
			local entityA = a:getUserData().entity
			local entityB = b:getUserData().entity

			if a:isSensor() or b:isSensor() then
				entityA:onSensorStay(entityB, contact)
				entityB:onSensorStay(entityA, contact)
			else
				entityA:onCollisionStay(entityB, contact)
				entityB:onCollisionStay(entityA, contact)
			end
		end)
end


return GameState
