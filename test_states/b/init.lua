--[[
Repeating test state
]]
local TestState = class("TestState", Engine.GameState)

function TestState:initialize()
	-- Create a game state
	local ecs = self.ecs

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())

		local rigidbody = entity:addComponent(Engine.components.Rigidbody())
		rigidbody:setMaterial(Engine.Material() { friction = 0, bounciness = 2 })

		entity:addComponent(Engine.components.RectangleCollider(0, 0, 100, 100, 0))
		entity:addComponent(Engine.components.CircleCollider(70, 70, 50))

		local animator = entity:addComponent(Engine.components.Animator(love.graphics.newImage("assets/textures/azure.png"), 15, 19))
		animator:newAnimation("idle"):setRate(12):addFrames(4, 0,0, 1,0):setLoop(true)
		animator:setAnimation("idle")

		local renderer = entity:addComponent(Engine.components.AnimationRenderer())
		renderer:setAnimator(animator)
		renderer:setCenter(Engine.Vector2(7.5, 9.5))

		entity.transform:setPosition(Engine.Vector2(200, 100))
		entity.transform:setScale(Engine.Vector2(10, 10))

		entity:tagAs("Azure")
	end

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())
		local rigidbody = entity:addComponent(Engine.components.Rigidbody("static"))

		entity:addComponent(Engine.components.ChainCollider(false, {
			0, 500,
			400, 600,
			600, 550,
			900, 800
		}))
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
		self.engine:popGameState()

		-- Set a new identical state
		self.engine:pushGameState(TestState())
	end)
end

return TestState
