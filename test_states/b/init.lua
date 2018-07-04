--[[
Repeating test state
]]
local Vector2 = heartbeat.Vector2

heartbeat.lovef.physics.addCategory("azure")
heartbeat.lovef.physics.addCategory("lineShape")
heartbeat.lovef.physics.setCollisionMasks("azure", { lineShape = false })

local TestSub = heartbeat.class("TestSub", heartbeat.SubState)

function TestSub:initialize()
	local ecs = self.ecs

	do
		local button = ecs:addEntity(heartbeat.entities.Button())

		local x = 0

		button.onClick:add(function()
			x = x + 1
			print(">> Clicked " .. tostring(x) .. " times!")
		end)

		button:setScreenAnchor(Vector2(0.5, 0.5))
		button:setLocalAnchor(Vector2(0.5, 0.5))
		button:setDimensions(Vector2(100, 100))
		button:setOffset(Vector2(200, 0))

		button:addComponent(heartbeat.components.ShapeRenderer("line", "rectangle", Vector2(100, 100))):setCenter(Vector2(50, 50))
	end
end

local TestState = heartbeat.class("TestState", heartbeat.GameState)

function TestState:initialize()
	local ecs = self.ecs

	do
		local entity = ecs:addEntity(heartbeat.ECS.Entity())

		local rigidbody = entity:addComponent(heartbeat.components.Rigidbody())
		rigidbody:setMaterial(heartbeat.Material() { friction = 0, bounciness = 2 })

		local collider1 = entity:addComponent(heartbeat.components.Collider("Rectangle", Vector2.zero, Vector2(100, 100), 0))
		collider1:setCategory("azure")

		local collider2 = entity:addComponent(heartbeat.components.Collider("Circle", Vector2(70, 70), 50))
		collider2:setCategory("azure")

		local animator = entity:addComponent(heartbeat.components.Animator(love.graphics.newImage("assets/textures/azure.png"), 15, 19))
		animator:newAnimation("idle"):setRate(12):addFrames(4, 0,0, 1,0):setLoop(true)
		animator:setAnimation("idle")

		local renderer = entity:addComponent(heartbeat.components.AnimationRenderer())
		renderer:setAnimator(animator)
		renderer:setCenter(Vector2(7.5, 9.5))

		entity.transform:setPosition(Vector2(200, 100))
		entity.transform:setScale(Vector2(10, 10))

		entity:tagAs("Azure")
	end

	do
		local entity = ecs:addEntity(heartbeat.ECS.Entity())
		local rigidbody = entity:addComponent(heartbeat.components.Rigidbody("static"))

		entity:addComponent(heartbeat.components.Collider("Chain", false, {
			Vector2(0, 500),
			Vector2(400, 600),
			Vector2(600, 550),
			Vector2(900, 800)
		}))

		entity:addComponent(heartbeat.components.TextRenderer(nil, "Test Text", 100, "center"))
	end

	do
		local entity = ecs:addEntity(heartbeat.ECS.Entity())

		local rigidbody = entity:addComponent(heartbeat.components.Rigidbody("dynamic"))
		rigidbody:setGravityScale(0)
		rigidbody:setMass(1, 1)
		rigidbody:setBullet(true)

		local collider = entity:addComponent(heartbeat.components.ImageCollider(love.image.newImageData("assets/textures/test_collider.png"), nil, Vector2(12, 12)))
		collider:setCategory("lineShape")

		entity.transform:setPosition(Vector2(800, 400))
	end

	self:addSubState(TestSub())

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
		self.heartbeat:popGameState()

		-- Set a new identical state
		self.heartbeat:pushGameState(TestState())
	end)
end

return TestState
