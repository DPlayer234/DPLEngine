--[[
Entity following the mouse
]]
local Vector2 = require "Engine.Vector2"

local Mouse = class("Mouse", require "Engine.ECS.Entity")

function Mouse:update()
	self.transform.position = self.ecs.transformation:inverseApplyPoint(Vector2(love.mouse.getPosition()))

	-- Mouse state
	self.down1 = love.mouse.isDown(1) and not self.held1
	self.held1 = love.mouse.isDown(1)

	self.down2 = love.mouse.isDown(2) and not self.held2
	self.held2 = love.mouse.isDown(2)
end

function Mouse:draw()
	love.graphics.points(self.transform.position:unpack())
end

return Mouse
