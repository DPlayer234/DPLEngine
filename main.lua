-- Load general files
require "r_redirect"

class = require "heartbeat.class"

function love.load()
	-- Load libraries
	miscMod = require "libs.misc_mod"
	sounds  = require "libs.sounds2"

	ffi = require "ffi"

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
	heartbeat = require "heartbeat"

	heartbeat:initialize { meter = 100 }

	require "dev"

	heartbeat:pushGameState(require "test_states.a" ())
end

function love.update(dt)
	heartbeat:update(dt)
	sounds.update(dt)
end

local physicsWorldDraw = require "dev.physics_world_draw"

function love.draw()
	heartbeat:draw()

	local gameState = heartbeat:getActiveGameState()
	if gameState then
		physicsWorldDraw(gameState.world, 0, 0, love.graphics.getDimensions())
	end
end
