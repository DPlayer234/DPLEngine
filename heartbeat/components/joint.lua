--[[
A Joint connecting two Rigidbodies
]]
local physics = require "love.physics"
local class = require "Heartbeat.class"
local Vector2 = require "Heartbeat.Vector2"
local Material = require "Heartbeat.Material"

local Joint = class("Joint", require "Heartbeat.ECS.Component")

local lJointConstructor

-- Creates a new Joint, optionally with a certain body type
function Joint:new(jointType)
	self:Component()

	assert(lJointConstructor[jointType] ~= nil, "Unknown Joint Type.")
	self._type = jointType
end

-- Initializes the Joint
function Joint:initialize()
	self._rigidbody = self.entity:getComponent("Rigidbody")
	if not self._rigidbody then
		error("Joints require the use of Rigidbodies.")
	end
end

-- Connect this joint to another one
function Joint:connect(other, collideConnected)
	if self:isConnected() or other:isConnected() then
		error("At least one of these joints was already connected.")
	end

	-- Need to check whether it's also a component since Löve uses the same method and class name for the same object.
	assert(other:typeOf("Joint") and other:typeOf("Component"), "Can only connect a Joint to another (Heartbeat) Joint.")
	assert(self:getType() == other:getType(), "Joints must be of the same type to be connected.")

	self._other = other
	other._other = self

	self._collide = collideConnected and true

	self:_create(true)
	other:_create(false)
end

-- Returns the Löve joint
function Joint:getLJoint()
	return self._joint
end

-- Gets the type of the joint
function Joint:getType()
	return self._type
end

-- Gets the anchor point (world coordinates); this default to the entity position.
-- If possible, this is ignored for the second Rigidbody.
function Joint:getAnchor()
	return self._anchor or self.transform:getPosition()
end

-- Sets the anchor point. Setting it to nil will revert it back to the entity position.
function Joint:setAnchor(value)
	self._anchor = value
end

-- (Rope) Gets the maximum lenght.
function Joint:getMaximumLenght()
	return self._maximumLenght
end

-- (Rope) Sets the maximum lenght.
function Joint:setMaximumLenght(value)
	self._maximumLenght = value
end

-- (Motor) Gets the correction factor.
function Joint:getCorrectionFactor()
	return self._correctionFactor
end

-- (Motor) Sets the correction factor.
function Joint:setCorrectionFactor(value)
	self._correctionFactor = value
end

-- (Prismatic/Wheel) Gets the axis vector.
function Joint:getAxis()
	return self._axis
end

-- (Prismatic/Wheel) Sets the axis vector.
function Joint:setAxis(value)
	self._axis = value
end

-- (Pulley) Gets the ground anchor.
function Joint:getGroundAnchor()
	return self._groundAnchor
end

-- (Pulley) Sets the ground anchor.
function Joint:setGroundAnchor(value)
	self._groundAnchor = value
end

-- (Pulley) Gets the joint ratio.
function Joint:getRatio()
	return self._ratio
end

-- (Pulley) Sets the joint ratio.
function Joint:setRatio(value)
	self._ratio = value
end

-- Returns whether the joint was already connected to another one
function Joint:isConnected()
	return self._other ~= nil
end

-- Returns the joint this one is connected to
function Joint:getConnected()
	return self._other
end

-- Returns whether the two Rigidbodies used will collide
-- May return nil if they have not been connected yet.
function Joint:getCollideConnected()
	return self._collide
end

-- Creates the joint
function Joint:_create(isFirst)
	if isFirst then
		self._joint = lJointConstructor[self:getType()](self, self._other)
		self._joint:setUserData(self)
	else
		self._joint = self._other:getLJoint()
	end
end

lJointConstructor = {
	-- Enforces a strict distance between two bodies
	Distance = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()
		local x2, y2 = j2:getAnchor():unpack()

		return physics.newDistanceJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1, x2, y2,
			j1:getCollideConnected())
	end,
	-- Applies friction to two bodies
	Friction = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()

		return physics.newFrictionJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1,
			j1:getCollideConnected())
	end,
	-- .... I honestly don't get it. But here you go.
	Motor = function(j1, j2)
		local correction = j1:getCorrectionFactor() or j2:getCorrectionFactor()
		assert(correction, "The correction factor for the Motor Joint was never set.")

		return physics.newMotorJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			correction,
			j1:getCollideConnected())
	end,
	-- Constrains relative movement to a specified axis
	Prismatic = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()

		local axis = j1:getAxis() or j2:getAxis()
		assert(axis, "The axis vector for the Prismatic Joint was never set.")

		return physics.newPrismaticJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1,
			axis.x, axis.y,
			j1:getCollideConnected())
	end,
	-- Simulates a pulley
	Pulley = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()
		local x2, y2 = j2:getAnchor():unpack()

		local g1 = j1:getGroundAnchor()
		local g2 = j2:getGroundAnchor()
		assert(g1 and g2, "The ground anchor was never set for both Pulley Joints.")

		local ratio = j1:getRatio() or j2:getRatio()
		assert(axis, "The ratio for the Pulley Joint was never set.")

		return physics.newDistanceJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			g1.x, g1.y, g2.x, g2.y,
			x1, y1, x2, y2,
			ratio,
			j1:getCollideConnected())
	end,
	-- Restrains movement of two bodies to only rotate around each other
	Revolute = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()

		return physics.newRevoluteJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1,
			j1:getCollideConnected())
	end,
	-- Enforces a maximum distance between two bodies
	Rope = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()
		local x2, y2 = j2:getAnchor():unpack()

		local maxLenght = j1:getMaximumLenght() or j2:getMaximumLenght()
		assert(maxLenght, "The maximum lenght for the Rope Joint was not set.")

		return physics.newRopeJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1, x2, y2,
			maxLenght,
			j1:getCollideConnected())
	end,
	-- Effectively glues two bodies together
	Weld = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()

		return physics.newWeldJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1,
			j1:getCollideConnected())
	end,
	-- Restricts a point on the second body to a line relative to the first body
	Wheel = function(j1, j2)
		local x1, y1 = j1:getAnchor():unpack()

		local axis = j1:getAxis() or j2:getAxis()
		assert(axis, "The axis vector for the Wheel Joint was never set.")

		return physics.newWheelJoint(
			j1._rigidbody:getLBody(),
			j2._rigidbody:getLBody(),
			x1, y1,
			axis.x, axis.y,
			j1:getCollideConnected())
	end
}

return Joint
