--[[
Wraps the Contact object to be more similar to the rest of the engine
]]
local class = require "Heartbeat.class"
local Vector2 = require "Heartbeat.Vector2"

local Collision = class("Collision")

-- Creates a new collision data object
function Collision:new(contact, myCol, otherCol, invertNormal)
	self.myCollider = myCol
	self.otherCollider = otherCol

	self._contact = contact
	self._invertNormal = invertNormal
end

-- Gets the contact points
function Collision:getPoints()
	local x1, y1, x2, y2 = self._contact:getPositions()
	if x2 then
		return Vector2(x1, y1), Vector2(x2, y2)
	end
	return Vector2(x1, y1)
end

-- Gets the normal, pointing from this object to the other one
function Collision:getNormal()
	local normal = Vector2(self._contact:getNormal())
	if self._invertNormal then
		return -normal
	end
	return normal
end

-- Gets the friction between the two objects
function Collision:getFriction()
	return self._contact:getFriction()
end

-- Sets the friction between the two objects
function Collision:setFriction(value)
	return self._contact:setFriction(value)
end

-- Gets the bounciness of the collision
function Collision:getBounciness()
	return self._contact:getRestitution()
end

-- Sets the bounciness of the collision
function Collision:setBounciness(value)
	return self._contact:setRestitution(value)
end

-- Gets the tangential speed of the collision (number!)
function Collision:getTangentSpeed()
	return self._contact:getTangentSpeed()
end

-- Sets the tangential speed of the collision (number!)
function Collision:setTangentSpeed(value)
	return self._contact:setTangentSpeed(value)
end

return Collision
