--[[
A Collider for rigidbodies (Fixture)
]]
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

	self:setMaterial(self._rigidbody:getMaterial())
end

-- Returns the fixture
function Collider:getFixture()
	return self._fixture
end

-- Gets the Material of the collider
function Collider:getMaterial()
	return self._material:instantiate()
end

-- Sets the Material of the collider
function Collider:setMaterial(value)
	if not value:typeOf("Material") then error("Can only set Materials!") end
	self._material = value:instantiate()

	self:getFixture():setFriction(value.friction)
	self:getFixture():setRestitution(value.bounciness)
end

-- Gets this collider's sensor state
function Collider:isSensor()
	return self:getFixture():isSensor()
end

-- Sets this collider's sensor state
function Collider:setSensor(value)
	return self:getFixture():setSensor(value)
end

function Collider:onDestroy()
	if not self._rigidbody:isDestroyed() then
		self._fixture:destroy()
	end
end

return Collider
