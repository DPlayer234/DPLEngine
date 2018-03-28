-- Load general files
require "errhand"
require "r_redirect"

class = require "libs.class"

function love.load()
	-- Load libraries
	input   = require "libs.input2"
	miscMod = require "libs.misc_mod"
	sounds  = require "libs.sounds2"

	-- Register input callbacks
	input.setUpKeyboard(true)
	input.setUpGamepads(true)
	input.setUpMouse(true)

	do
		-- Creating the window
		local width, height = love.window.getDesktopDimensions()

		love.window.setMode(width*(2/3), height*(2/3), {
			fullscreen     = false,
			fullscreentype = "desktop",
			vsync          = true,
			resizable      = true,
			borderless     = false,
			minwidth       = 640,
			minheight      = 360,
			msaa           = 0
		})

		love.window.setIcon(love.image.newImageData("assets/textures/icon.png"))
	end

	-- Load and initialize the engine
	Engine = require "engine"

	Engine:initialize { meter = 100 }

	-- Example
	local function setState()
		-- Create a game state
		local gameState = Engine.GameState()
		local ecs = gameState.ecs

		do
			local entity = ecs:addEntity(Engine.ECS.Entity())

			entity:addComponent(require "engine.components.rigidbody" ())
			entity:addComponent(require "engine.components.rectangle_collider" (0, 0, 100, 100, 0)):getFixture():setRestitution(0.5)
			entity:addComponent(require "engine.components.circle_collider" (70, 70, 50)):getFixture():setRestitution(0.5)

			local animator = entity:addComponent(require "engine.components.animator" (love.graphics.newImage("assets/textures/azure.png"), 15, 19))
			animator:newAnimation("idle"):setRate(12):addFrames(4, 0,0, 1,0):setLoop(true)
			animator:setAnimation("idle")

			local renderer = entity:addComponent(require "engine.components.animation_renderer" ())
			renderer:setAnimator(animator)
			renderer:setCenter(Engine.Vector2(7.5, 9.5))

			entity.transform.position = Engine.Vector2(200, 100)
			entity.transform.scale = Engine.Vector2(10, 10)

			entity:tagAs("Azure")
		end

		do
			local entity = ecs:addEntity(Engine.ECS.Entity())
			local rigidbody = entity:addComponent(require "engine.components.rigidbody" ())
			rigidbody:getBody():setType("static")

			entity:addComponent(require "engine.components.chain_collider" (false, {
				0, 500,
				400, 600,
				600, 550,
				900, 800
			}))
		end

		gameState.timer:coTask(function(wait)
			while true do
				wait(1)
				ecs:findEntityByTag("Azure").transform:flipHorizontal()
			end
		end)

		-- Set a function to run after 5 seconds
		gameState.timer:queueTask(5, function()
			-- Pop the state of the stack
			Engine:popGameState()

			-- Call the setState function again
			setState()
		end)

		-- You probably want to create a new class inheriting GameState instead

		-- Push the state
		Engine:pushGameState(gameState)
	end

	require "dev"

	setState()

	--Engine:pushGameState(Engine.Editor())
end

function love.update(dt)
	Engine:update(dt)

	sounds.update(dt)
	input.endFrame(dt)
end

function love.draw()
	Engine:draw()
end
