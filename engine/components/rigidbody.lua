--[[
A Rigidbody (Body)
]]
local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"

local Rigidbody = class("Rigidbody", require "Engine.ECS.Component")

-- Initializes the Rigidbody
function Rigidbody:initialize()
	local x, y = self.transform.position:unpack()

	self._body = physics.newBody(self.ecs.world, x, y, "dynamic")
	self._body:setUserData(self)
	self._body:setAngle(self.transform.angle)

	self.transform:hookBody(self._body)
end

-- Returns the physics body
function Rigidbody:getBody()
	return self._body
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
