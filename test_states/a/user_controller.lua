--[[
Entity following the mouse
]]
local currentModule = (...):gsub("%.[^%.]+$", "")

local Color = heartbeat.Color
local Vector2 = heartbeat.Vector2

local SelectionBox = require(currentModule .. ".selection_box")

local UserController = heartbeat.class("UserController", heartbeat.ECS.Entity)

local color = {
	neutral = Color(1, 1, 1, 1),
	lmb = Color(0, 1, 1, 1),
	rmb = Color(1, 0, 1, 1),
	mmb = Color(1, 1, 0, 1)
}

local releaseCallbacks

function UserController:initialize()
	self.down = {}
	self.held = {}

	self.selection = {}
end

function UserController:update()
	self.transform:setPosition(self.ecs.transformation:inverseTransformPoint(Vector2(love.mouse.getPosition())))

	-- Mouse state
	for i=1, 3 do
		self.down[i] = love.mouse.isDown(i) and not self.held[i]
		self.held[i] = love.mouse.isDown(i)

		if self.down[i] then
			self.selection[i] = self:addComponent(SelectionBox())
			self.selection[i].callback = releaseCallbacks[i]
		elseif self.selection[i] and not self.held[i] then
			self.selection[i]:destroy()
			self.selection[i] = nil
		end
	end

	self.color = self.held[1] and color.lmb or self.held[2] and color.rmb or self.held[3] and color.mmb or color.neutral

	if love.keyboard.isDown("escape") then
		for i,v in ipairs(self.ecs:findEntitiesByTag("Box")) do
			v:destroy()
		end
	end
end

function UserController:draw()
	love.graphics.setColor(self.color)

	local x, y = self.transform:getPosition():unpack()
	love.graphics.points(x, y)

	love.graphics.printf(("%.0f, %.0f"):format(x, y), x - 1000, y, 1000, "right")
end

releaseCallbacks = {
	[1] = function(box)
		local e = box.ecs:addEntity(heartbeat.ECS.Entity())

		e:tagAs("Box")
		e:addComponent(heartbeat.components.Rigidbody("dynamic"))
		e:addComponent(heartbeat.components.Collider("Rectangle", box.dimensions))
		e.transform:setPosition(box.topLeft + box.dimensions * 0.5)

		e:addComponent(heartbeat.components.ShapeRenderer("fill", "polygon", { -box.dimensions.x * 0.5, -box.dimensions.y * 0.5, box.dimensions.x * 0.5, -box.dimensions.y * 0.5, box.dimensions.x * 0.5, box.dimensions.y * 0.5 }))
	end,
	[2] = function(box)
		local e = box.ecs:addEntity(heartbeat.ECS.Entity())

		e:tagAs("Box")
		e:addComponent(heartbeat.components.Rigidbody("static"))
		e:addComponent(heartbeat.components.Collider("Rectangle", box.dimensions))
		e.transform:setPosition(box.topLeft + box.dimensions * 0.5)
	end
}

return UserController
