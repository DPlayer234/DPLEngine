--[[
A Collider for rigidbodies (Fixture)
]]
local currentModule = miscMod.getModule(..., false)

local physics = require "love.physics"

local Collider = class("Collider", require "Engine.ECS.Component")

-- Creates a new Collider
function Collider:new(shape, density)
	self:Component()

	self._shape = shape
	self._density = density
end

function Collider:initialize()
	self._rigidbody = assert(self.entity:getComponent("Rigidbody"), "Colliders require a Rigidbody.")

	self._fixture = physics.newFixture(self._rigidbody:getBody(), self._shape, self._density or 1)
	self._fixture:setUserData(self)
end

-- Returns the fixture
function Collider:getFixture()
	return self._fixture
end

function Collider:onDestroy()
	if not self._rigidbody:isDestroyed() then
		self._fixture:destroy()
	end
end

return Collider
