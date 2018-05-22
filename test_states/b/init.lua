--[[
Repeating test state
]]
local Vector2 = heartbeat.Vector2

local TestSub = heartbeat.class("TestSub", heartbeat.SubState)

function TestSub:new(mainState)
	self:SubState(mainState)

	local ecs = self.ecs

	do
		local button = heartbeat.entities.Button(ecs)

		local x = 0

		button.onClick:add(function()
			x = x + 1
			print(">> Clicked " .. tostring(x) .. " times!")
		end)

		button:setScreenAnchor(Vector2(0.5, 0.5))
		button:setLocalAnchor(Vector2(0.5, 0.5))
		button:setDimensions(Vector2(100, 100))
		button:setOffset(Vector2(200, 0))

		heartbeat.components.ShapeRenderer(button, "line", "rectangle", Vector2(100, 100)):setCenter(Vector2(50, 50))
	end
end

local TestState = heartbeat.class("TestState", heartbeat.GameState)

function TestState:new()
	self:GameState()

	local ecs = self.ecs

	do
		local entity = heartbeat.ECS.Entity(ecs)

		local rigidbody = heartbeat.components.Rigidbody(entity)
		rigidbody:setMaterial(heartbeat.Material() { friction = 0, bounciness = 2 })

		heartbeat.components.Collider(entity, "Rectangle", Vector2.zero, Vector2(100, 100), 0)
		heartbeat.components.Collider(entity, "Circle", Vector2(70, 70), 50)

		local animator = heartbeat.components.Animator(entity, love.graphics.newImage("assets/textures/azure.png"), 15, 19)
		animator:newAnimation("idle"):setRate(12):addFrames(4, 0,0, 1,0):setLoop(true)
		animator:setAnimation("idle")

		local renderer = heartbeat.components.AnimationRenderer(entity)
		renderer:setAnimator(animator)
		renderer:setCenter(Vector2(7.5, 9.5))

		entity.transform:setPosition(Vector2(200, 100))
		entity.transform:setScale(Vector2(10, 10))

		entity:tagAs("Azure")
	end

	do
		local entity = heartbeat.ECS.Entity(ecs)
		local rigidbody = heartbeat.components.Rigidbody(entity, "static")

		heartbeat.components.Collider(entity, "Chain", false, {
			Vector2(0, 500),
			Vector2(400, 600),
			Vector2(600, 550),
			Vector2(900, 800)
		})
	end

	do
		local entity = heartbeat.ECS.Entity(ecs)

		local rigidbody = heartbeat.components.Rigidbody(entity, "dynamic")
		heartbeat.components.ImageCollider(entity, love.image.newImageData("assets/textures/test_collider.png"), nil, Vector2(12, 12))

		rigidbody:setGravityScale(0)
		rigidbody:setMass(1, 1)
		rigidbody:setBullet(true)

		entity.transform:setPosition(Vector2(800, 400))
	end

	TestSub(self)

	self.timer:startCoroutine(function(self)
		while true do
			self:yield(1)

			local azure = ecs:findEntityByTag("Azure")
			if azure then
				azure.transform:flipHorizontal()
			end
		end
	end)

	-- Set a function to run after 5 seconds
	self.timer:runAfter(5, function()
		-- Pop the state of the stack
		self:destroy()

		-- Set a new identical state
		TestState()
	end)
end

return TestState
