--[[
A Rigidbody (Body)
]]
local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"
local Material = require "Engine.Material"

local Rigidbody = class("Rigidbody", require "Engine.ECS.Component")

-- Creates a new Rigidbody, optionally with a certain body type
function Rigidbody:new(bodyType)
	self._type = bodyType or "dynamic"
	self:Component()
end

-- Initializes the Rigidbody
function Rigidbody:initialize()
	local x, y = self.transform.position:unpack()

	self._body = physics.newBody(self.ecs.world, x, y, self._type)
	self._body:setUserData(self)
	self._body:setAngle(self.transform.angle)

	self._material = Material()

	self.transform:hookBody(self._body)
end

-- Returns the physics body
function Rigidbody:getBody()
	return self._body
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
	return self:getBody():isActive()
end

-- Sets whether the body is active.
function Rigidbody:setActive(value)
	return self:getBody():setActive(value)
end

-- Gets linear damping. Basically friction with the air
function Rigidbody:getDamping()
	return self:getBody():getLinearDamping()
end

-- Sets linear damping.
function Rigidbody:setDamping(value)
	return self:getBody():setLinearDamping(value)
end

-- Gets angular damping. Basically friction with the air for rotational velocity
function Rigidbody:getAngularDamping()
	return self:getBody():getAngularDamping()
end

-- Sets angular damping.
function Rigidbody:setAngularDamping(value)
	return self:getBody():setAngularDamping(value)
end

-- Gets whether the rotation is locked and cannot be changed by the physics simulation
function Rigidbody:isRotationLocked()
	return self:getBody():isFixedRotation()
end

-- Sets whether the rotation is locked
function Rigidbody:setRotationLocked(value)
	return self:getBody():setFixedRotation(value)
end

-- Gets the mass, inertia and local center of mass
function Rigidbody:getMass()
	local x, y, mass, inertia = self:getBody():getMassData()
	return mass, inertia, Vector2(x, y)
end

-- Sets the mass, inertia and local center of mass
-- If no arguments are passed, they are instead recalculated from the attached Colliders.
function Rigidbody:setMass(mass, inertia, center)
	if center then
		return self:getBody():setMassData(center.x, center.y, mass, inertia)
	elseif inertia then
		self:getBody():setInertia(inertia)
	end
	if mass then
		return self:getBody():setMass(mass)
	end
	return self:getBody():resetMassData()
end

-- Gets the body type. Either "static", "dynamic" or "kinematic"
function Rigidbody:getType()
	return self:getBody():getType()
end

-- Sets the body type
function Rigidbody:setType(type)
	return self:getBody():setType(type)
end

-- Gets whether this is using bullet collisions. Bullets take more time to calculate but are more accurate
function Rigidbody:isBullet()
	return self:getBody():isBullet()
end

-- Sets whether this is using bullet collisions.
function Rigidbody:setBullet(value)
	return self:getBody():setBullet(value)
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
