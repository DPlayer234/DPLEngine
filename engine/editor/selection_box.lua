--[[
Selection Box
]]
local colors = require "libs.colors"
local Vector2 = require "Engine.Vector2"

local SelectionBox = class("SelectionBox", require "Engine.ECS.Component")

function SelectionBox:initialize()
	assert(self.entity:typeOf("UserController"), "SelectionBox must be attached to a UserController!")
	self.origin = self.transform.position
end

function SelectionBox:postUpdate()
	self.dimensions = self.transform.position - self.origin
end

function SelectionBox:draw()
	love.graphics.setColor(self.entity.color)
	love.graphics.print(("x%.0f, %.0f"):format(self.dimensions.x, self.dimensions.y), self.origin.x, self.origin.y)

	love.graphics.setColor(self.entity.color * colors.vec4(1, 1, 1, 0.25))
	love.graphics.rectangle("fill", self.origin.x, self.origin.y, self.dimensions.x, self.dimensions.y)
end

function SelectionBox:onDestroy()
	self.topLeft = Vector2(
		math.min(self.origin.x, self.origin.x + self.dimensions.x),
		math.min(self.origin.y, self.origin.y + self.dimensions.y)
	)

	self.bottomRight = Vector2(
		math.max(self.origin.x, self.origin.x + self.dimensions.x),
		math.max(self.origin.y, self.origin.y + self.dimensions.y)
	)

	if self.callback then
		self.ecs.world:queryBoundingBox(self.topLeft.x, self.topLeft.y, self.bottomRight.x, self.bottomRight.y, self.callback)
	end
end

return SelectionBox
