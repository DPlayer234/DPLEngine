-- Load general files
require "errhand"
require "r_redirect"

class = require "class"

function love.load()
	-- Load libraries
	input   = require "libs.input2"
	mathf   = require "libs.mathf"
	anim    = require "libs.anim2"
	assets  = require "libs.assets"
	colors  = require "libs.colors"
	fileT   = require "libs.file_t"
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

	Engine:initialize { meter = 50 }

	local gameState = Engine.GameState()
	local ecs = gameState.ecs

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())
		entity:addComponent(require "engine.components.rigidbody" ())
		entity:addComponent(require "engine.components.collider" (love.physics.newRectangleShape(100, 100))).fixture:setRestitution(0.7)

		entity.transform.position = Engine.Vector2(200, 100)
	end

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())
		local rigidbody = entity:addComponent(require "engine.components.rigidbody" ())
		rigidbody.body:setType("static")

		entity:addComponent(require "engine.components.collider" (love.physics.newRectangleShape(1000, 50)))

		entity.transform.position = Engine.Vector2(500, 500)
		entity.transform.rotation = 0.06
	end

	Engine:pushGameState(gameState)

	require "dev"
end

function love.update(dt)
	Engine:update(dt)

	sounds.update(dt)
	input.endFrame(dt)
end

function love.draw()
	Engine:draw()
end
