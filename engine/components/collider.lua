--[[
A Collider for rigidbodies (Fixture)
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"

local Rigidbody = require(currentModule .. ".rigidbody")

local Collider = class("Collider", require "Engine.ECS.Component")

-- Creates a new Collider
function Collider:new(shape, density)
	self:Component()

	self._shape = shape
	self._density = density
end

function Collider:initialize()
	self.rigidbody = assert(self.entity:getComponent(Rigidbody), "Colliders require a Rigidbody.")

	self.fixture = physics.newFixture(self.rigidbody.body, self._shape, self._density or 1)
	self.fixture:setUserData(self)
end

return Collider
