-- Load general files
require "r_redirect"

class = require "libs.class"

function love.load()
	-- Load libraries
	miscMod = require "libs.misc_mod"
	sounds  = require "libs.sounds2"

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

	require "dev"

	Engine:pushGameState(require "test_states.b" ())
end

function love.update(dt)
	Engine:update(dt)
	sounds.update(dt)
end

function love.draw()
	Engine:draw()
end
