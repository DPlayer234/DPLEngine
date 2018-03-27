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

	Engine:initialize(50)

	local gameState = Engine.GameState()
	local ecs = gameState.ecs

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())
		entity:addComponent(Engine:getComponentType "Rigidbody" ()):setPosition(Engine.Vector2(100, 100))
		entity:addComponent(Engine:getComponentType "Collider" (love.physics.newRectangleShape(100, 100)))
	end

	do
		local entity = ecs:addEntity(Engine.ECS.Entity())
		local rigidbody = entity:addComponent(Engine:getComponentType "Rigidbody" ())
		rigidbody:setPosition(Engine.Vector2(250, 250))
		rigidbody:setAngle(0.2)
		rigidbody.body:setType("static")

		entity:addComponent(Engine:getComponentType "Collider" (love.physics.newRectangleShape(500, 50)))
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
