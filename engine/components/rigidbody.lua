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
	self.body:setAngle(self.transform.rotation)

	self.transform:hook(self.body)
end

function Rigidbody:destroy()
	self.body:destroy()

	return self.Component.destroy(self)
end

return Rigidbody
--[[
RIGIDBODY NOT RIDIGBODY
]]
