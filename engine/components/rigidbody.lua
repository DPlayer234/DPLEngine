--[[
A Rigidbody with a body
]]
local physics = require "love.physics"

local Vector2 = Engine.Vector2

local Rigidbody = class("Rigidbody", Engine.ECS.Component)

-- Initializes the Rigidbody
function Rigidbody:initialize()
	local x, y = self.transform.position:unpack()
	self.body = physics.newBody(self.ecs.world, x, y, "dynamic")
	self.body:setUserData(self)
end

-- Gets the position of the object
function Rigidbody:getPosition()
	return Vector2(self.body:getPosition())
end

-- Sets the position of the object
function Rigidbody:setPosition(position)
	self.transform.position = position
	self.body:setPosition(position:unpack())
end

-- Gets the angel of the object
function Rigidbody:getAngle()
	return self.body:getAngle()
end

-- Sets the angle of the object
function Rigidbody:setAngle(angle)
	self.transform.rotation.angle = angle
	self.body:setAngle(angle)
end

function Rigidbody:postUpdate()
	self.transform.position = Vector2(self.body:getPosition())
	self.transform.rotation.angle = self.body:getAngle()
end

function Rigidbody:destroy()
	self.body:destroy()

	return self.Component.destroy(self)
end

return Rigidbody
