--[[
Repeating test state
]]
local TestState = class("TestState", Heartbeat.GameState)

function TestState:initialize()
	-- Create a game state
	local ecs = self.ecs

	local Vector2 = Heartbeat.Vector2

	do
		local entity = ecs:addEntity(Heartbeat.ECS.Entity())

		local rigidbody = entity:addComponent(Heartbeat.components.Rigidbody())
		rigidbody:setMaterial(Heartbeat.Material() { friction = 0, bounciness = 2 })

		entity:addComponent(Heartbeat.components.Collider("Rectangle", Vector2(0, 0), Vector2(100, 100), 0))
		entity:addComponent(Heartbeat.components.Collider("Circle", Vector2(70, 70), 50))

		local animator = entity:addComponent(Heartbeat.components.Animator(love.graphics.newImage("assets/textures/azure.png"), 15, 19))
		animator:newAnimation("idle"):setRate(12):addFrames(4, 0,0, 1,0):setLoop(true)
		animator:setAnimation("idle")

		local renderer = entity:addComponent(Heartbeat.components.AnimationRenderer())
		renderer:setAnimator(animator)
		renderer:setCenter(Vector2(7.5, 9.5))

		entity.transform:setPosition(Vector2(200, 100))
		entity.transform:setScale(Vector2(10, 10))

		entity:tagAs("Azure")
	end

	do
		local entity = ecs:addEntity(Heartbeat.ECS.Entity())
		local rigidbody = entity:addComponent(Heartbeat.components.Rigidbody("static"))

		entity:addComponent(Heartbeat.components.Collider("Chain", false, {
			Vector2(0, 500),
			Vector2(400, 600),
			Vector2(600, 550),
			Vector2(900, 800)
		}))
	end

	do
		local entity = ecs:addEntity(Heartbeat.ECS.Entity())

		local rigidbody = entity:addComponent(Heartbeat.components.Rigidbody("dynamic"))
		entity:addComponent(Heartbeat.components.ImageCollider(love.image.newImageData("assets/textures/test_collider.png"), 0.71))

		rigidbody:setGravityScale(0)
		rigidbody:setMass(1, 1)

		entity.transform:setPosition(Vector2(800, 400))
	end

	self.timer:coTask(function(wait)
		while true do
			wait(1)
			ecs:findEntityByTag("Azure").transform:flipHorizontal()
		end
	end)

	-- Set a function to run after 5 seconds
	self.timer:queueTask(5, function()
		-- Pop the state of the stack
		self.heartbeat:popGameState()

		-- Set a new identical state
		self.heartbeat:pushGameState(TestState())
	end)
end

return TestState
