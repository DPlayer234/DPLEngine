--[[
A Rigidbody (Body)
]]
local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"

local Rigidbody = class("Rigidbody", require "Engine.ECS.Component")

-- Initializes the Rigidbody
function Rigidbody:initialize()
	local x, y = self.transform.position:unpack()

	self.body = physics.newBody(self.ecs.world, x, y, "dynamic")
	self.body:setUserData(self)
	self.body:setAngle(self.transform.angle)

	self.transform:hookBody(self.body)
end

function Rigidbody:onDestroy()
	self.body:destroy()

	if not self.entity:toBeDestroyed() then
		self.transform:unhookBody()
	end
end

return Rigidbody
--[[
RIGIDBODY NOT RIDIGBODY
]]
