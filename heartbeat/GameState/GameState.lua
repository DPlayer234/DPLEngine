--[[
The base class for any Game State
]]
local table = table
local assert = assert
local physics = require "love.physics"
local input = require "Heartbeat::input"
local class = require "Heartbeat::class"
local EventStore = require "Heartbeat::EventStore"

local ECS            = require "Heartbeat::ECS"
local Transformation = require "Heartbeat::GameState::Transformation"
local Collision      = require "Heartbeat::GameState::Collision"

local Timer = require "Heartbeat::Timer"

-- The class
local GameState = class("GameState")

GameState.Collision = Collision
GameState.Transformation = Transformation

-- Creates a new GameState
function GameState:new()
	self:_setPhysicsWorld()

	self.timer = Timer()
	self.timeScale = 1
	self.transformation = Transformation()
	self.input = input.MergedInput()

	self.ecs = ECS()
	self.ecs.world = self.world
	self.ecs.timer = self.timer
	self.ecs.transformation = self.transformation
	self.ecs.input = self.input
	self.ecs.gameState = self

	self._subs = {}

	self.heartbeat = nil
end

-- Initializes the game state and, f.e., sets the entities and terrain used when instantiating
-- Called when the game state is first pushed
function GameState:initialize() end

-- Called when the game state is paused or removed
function GameState:onPause() end

-- Called when the game state is resumed or started
function GameState:onResume() end

-- Called when the game state is destroyed
function GameState:onDestroy() end

-- Returns whether the game state has been pushed and initialized
function GameState:hasHeartbeat()
	return self.heartbeat ~= nil
end

-- Adds a sub state and initializes it
function GameState:addSubState(gameState)
	assert(self:hasHeartbeat(), "Can only push sub-states to states with a heartbeat.")
	assert(gameState:typeOf("SubState"), "Can only add objects of type 'SubState' as sub-states.")
	assert(not gameState:hasHeartbeat(), "GameStates can only be pushed once.")

	self._subs[#self._subs + 1] = gameState

	gameState.heartbeat = self.heartbeat
	gameState._parent = self
	gameState:initialize()

	gameState:_onResume()
end

-- Gets a sub-state by index
function GameState:getSubState(index)
	return self._subs[i]
end

-- Gets the amount of sub-states added
function GameState:getSubStateCount()
	return #self._subs
end

-- Updates the game state
function GameState:update(dt)
	dt = dt * self.timeScale
	self.ecs.deltaTime = dt

	self.ecs:update()

	for i=1, #self._subs do self._subs[i]:preUpdate(dt) end

	self.world:update(dt)
	self.timer:update(dt)

	self.ecs:postUpdate()

	for i=1, #self._subs do self._subs[i]:postUpdate(dt) end
end

-- Draws the game state
function GameState:draw()
	self.transformation:replace()
	self.ecs:draw()
end

-- Destroys the ECS, child-states and associated destroyable resources
function GameState:destroy()
	self:onDestroy()
	self.ecs:destroy()

	for i=#self._subs, 1, -1 do
		self._subs[i]:destroy()
		table.remove(self._subs, i)
	end
end

-- Internally called on pause
function GameState:_onPause()
	input.remove(self.input)

	self:onPause()
end

-- Internally called on pause
function GameState:_onResume()
	input.add(self.input)

	self:onResume()
end

-- Sets the physics world
function GameState:_setPhysicsWorld()
	self.world = physics.newWorld(0, 9.85 * physics.getMeter(), true)

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
