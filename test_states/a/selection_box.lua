--[[
Selection Box
]]
local Color = heartbeat.Color
local Vector2 = heartbeat.Vector2

local SelectionBox = heartbeat.class("SelectionBox", heartbeat.ECS.Component)

function SelectionBox:new(entity)
	assert(entity:typeOf("UserController"), "SelectionBox must be attached to a UserController!")
	self:Component(entity)

	self.origin = self.transform:getPosition()
end

function SelectionBox:postUpdate()
	self.dimensions = self.transform:getPosition() - self.origin
end

function SelectionBox:draw()
	love.graphics.setColor(self.entity.color)
	love.graphics.print(("x%.0f, %.0f"):format(self.dimensions.x, self.dimensions.y), self.origin.x, self.origin.y)

	love.graphics.setColor(self.entity.color * Color(1, 1, 1, 0.25))
	love.graphics.rectangle("fill", self.origin.x, self.origin.y, self.dimensions.x, self.dimensions.y)
end

function SelectionBox:onDestroy()
	self.topLeft = Vector2(
		math.min(self.origin.x, self.origin.x + self.dimensions.x),
		math.min(self.origin.y, self.origin.y + self.dimensions.y)
	)

	self.dimensions = Vector2(
		math.max(1, math.abs(self.dimensions.x)),
		math.max(1, math.abs(self.dimensions.y))
	)

	if self.callback then
		--self.ecs.world:queryBoundingBox(self.topLeft.x, self.topLeft.y, self.bottomRight.x, self.bottomRight.y, self.callback)
		self:callback()
	end
end

return SelectionBox
