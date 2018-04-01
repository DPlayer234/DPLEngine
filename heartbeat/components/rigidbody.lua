--[[
A Rigidbody (Body)
]]
local physics = require "love.physics"
local Vector2 = require "Heartbeat.Vector2"
local Material = require "Heartbeat.Material"

local Rigidbody = class("Rigidbody", require "Heartbeat.ECS.Component")

-- Creates a new Rigidbody, optionally with a certain body type
function Rigidbody:new(bodyType)
	self._type = bodyType or "dynamic"
	self:Component()
end

-- Initializes the Rigidbody
function Rigidbody:initialize()
	self._body = physics.newBody(self.ecs.world, 0, 0, self._type)
	self._body:setUserData(self)

	self._material = Material()

	self.transform:setLBody(self._body, true)
end

-- Returns the Löve physics body
function Rigidbody:getLBody()
	return self._body
end

-- Applies a force to the body
function Rigidbody:applyForce(force, position)
	if position then
		return self:getLBody():applyForce(force.x, force.y, position:unpack())
	end
	return self:getLBody():applyForce(force:unpack())
end

-- Applies torque (rotational force) to the body
function Rigidbody:applyTorque(torque)
	return self:getLBody():applyTorque(torque)
end

-- Applies an impulse to the body
function Rigidbody:applyImpulse(impulse)
	if position then
		return self:getLBody():applyLinearImpulse(impulse.x, impulse.y, position:unpack())
	end
	return self:getLBody():applyLinearImpulse(impulse:unpack())
end

-- Applies a rotational impulse to the body
function Rigidbody:applyAngularImpulse(impulse)
	return self:getLBody():applyAngularImpulse(impulse)
end

-- Gets the default Material for any colliders added
function Rigidbody:getMaterial()
	return self._material:instantiate()
end

-- Sets the default Material for any colliders added
function Rigidbody:setMaterial(value)
	if not value:typeOf("Material") then error("Can only set Materials!") end
	self._material = value:instantiate()
end

-- Gets whether the body is active and partaking in the physics simulation.
function Rigidbody:isActive()
	return self:getLBody():isActive()
end

-- Sets whether the body is active.
function Rigidbody:setActive(value)
	return self:getLBody():setActive(value)
end

-- Gets the velocity
function Rigidbody:getVelocity()
	return Vector2(self:getLBody():getLinearVelocity())
end

-- Overrides the velocity
function Rigidbody:setVelocity(value)
	return self:getLBody():setLinearVelocity(value:unpack())
end

-- Gets rotational velocity
function Rigidbody:getAngularVelocity()
	return self:getLBody():getAngularVelocity()
end

-- Overrides the angular velocity
function Rigidbody:setAngularVelocity(value)
	return self:getLBody():setAngularVelocity(value)
end

-- Gets linear damping. Basically friction with the air
function Rigidbody:getDamping()
	return self:getLBody():getLinearDamping()
end

-- Sets linear damping.
function Rigidbody:setDamping(value)
	return self:getLBody():setLinearDamping(value)
end

-- Gets angular damping. Basically friction with the air for rotational velocity
function Rigidbody:getAngularDamping()
	return self:getLBody():getAngularDamping()
end

-- Sets angular damping.
function Rigidbody:setAngularDamping(value)
	return self:getLBody():setAngularDamping(value)
end

-- Gets whether the rotation is locked and cannot be changed by the physics simulation
function Rigidbody:isRotationLocked()
	return self:getLBody():isFixedRotation()
end

-- Sets whether the rotation is locked
function Rigidbody:setRotationLocked(value)
	return self:getLBody():setFixedRotation(value)
end

-- Gets the mass, inertia and local center of mass
function Rigidbody:getMass()
	local x, y, mass, inertia = self:getLBody():getMassData()
	return mass, inertia, Vector2(x, y)
end

-- Sets the mass, inertia and local center of mass
-- If no arguments are passed, they are instead recalculated from the attached Colliders.
function Rigidbody:setMass(mass, inertia, center)
	if center then
		return self:getLBody():setMassData(center.x, center.y, mass, inertia)
	elseif inertia then
		self:getLBody():setInertia(inertia)
	end
	if mass then
		return self:getLBody():setMass(mass)
	end
	return self:getLBody():resetMassData()
end

-- Gets the body type. Either "static", "dynamic" or "kinematic"
function Rigidbody:getType()
	return self:getLBody():getType()
end

-- Sets the body type
function Rigidbody:setType(type)
	return self:getLBody():setType(type)
end

-- Gets whether this is using bullet collisions. Bullets take more time to calculate but are more accurate
function Rigidbody:isBullet()
	return self:getLBody():isBullet()
end

-- Sets whether this is using bullet collisions.
function Rigidbody:setBullet(value)
	return self:getLBody():setBullet(value)
end

-- Gets the gravity scale
function Rigidbody:getGravityScale()
	return self:getLBody():getGravityScale()
end

-- Sets the gravity scale
function Rigidbody:setGravityScale(value)
	return self:getLBody():setGravityScale(value)
end

function Rigidbody:onDestroy()
	self._body:destroy()

	if not self.entity:isDestroyed() then
		self.transform:unhookBody()
	end
end

return Rigidbody
--[[
RIGIDBODY NOT RIDIGBODY
]]
