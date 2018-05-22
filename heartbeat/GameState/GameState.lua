--[[
The base class for any Game State
]]
local table = table
local assert = assert
local lphysics = require "love.physics"
local input = require "Heartbeat::input"
local class = require "Heartbeat::class"

local ECS            = require "Heartbeat::ECS"
local Transformation = require "Heartbeat::GameState::Transformation"
local Collision      = require "Heartbeat::GameState::Collision"

local Timer = require "Heartbeat::Timer"

-- The class
local GameState = class("GameState")

GameState.Collision = Collision
GameState.Transformation = Transformation

-- Creates a new GameState
function GameState:new(...)
	if self.heartbeat == nil then
		GameState.heartbeat = require "Heartbeat::heartbeat"
	end
	self.heartbeat = self.heartbeat

	self:_setPhysicsWorld()

	self.timer = Timer()
	self._timeScale = 1

	self.transformation = Transformation()
	self.input = input.MergedInput()

	self.ecs = ECS()
	self.ecs.world = self.world
	self.ecs.timer = self.timer
	self.ecs.transformation = self.transformation
	self.ecs.input = self.input
	self.ecs.gameState = self

	self._subs = {}

	self:_init(...)
end

-- Called when the game state is paused or removed
function GameState:onPause() end

-- Called when the game state is resumed or started
function GameState:onResume() end

-- Called when the game state is destroyed
function GameState:onDestroy() end

-- Gets a sub-state by index
function GameState:getSubState(index)
	return self._subs[i]
end

-- Gets the amount of sub-states added
function GameState:getSubStateCount()
	return #self._subs
end

-- Returns the main game state
function GameState:getMainState()
	return self
end

-- Gets the current time scale
function GameState:getTimeScale()
	return value
end

-- Sets the current time scale. Must be greater than or equal to 0.
function GameState:setTimeScale(value)
	assert(value > 0, "The time scale needs to be greater than or equal to 0.")
	self._timeScale = value
end

-- Updates the game state
function GameState:update(dt)
	dt = dt * self._timeScale
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

	for i=1, #self._subs do self._subs[i]:draw() end
end

-- Destroys the ECS, child-states and associated destroyable resources
function GameState:destroy()
	self.heartbeat:_popGameState(self)

	self:_destroy()
end

-- Internally called on pause
function GameState:_onPause()
	input.remove(self.input)

	for i=1, #self._subs do self._subs[i]:_onPause() end

	self:onPause()
end

-- Internally called on pause
function GameState:_onResume()
	input.add(self.input)

	for i=1, #self._subs do self._subs[i]:_onResume() end

	self:onResume()
end

-- Sets the physics world
function GameState:_setPhysicsWorld()
	self.world = lphysics.newWorld(0, 9.85 * lphysics.getMeter(), true)

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

-- Adds a sub state and initializes it
function GameState:_addSubState(subState)
	self._subs[#self._subs + 1] = subState

	subState:_onAdd()
	subState:_onResume()
end

-- Internal destruction
function GameState:_destroy()
	self:onDestroy()
	self.ecs:destroy()

	for i=#self._subs, 1, -1 do
		self._subs[i]:destroy()
	end
end

-- Initializes the GameState
function GameState:_init()
	self.heartbeat:_pushGameState(self)
end

return GameState
