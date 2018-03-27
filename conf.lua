--[[
Löve Startup Configuration File
]]
function love.conf(t)
	-- General data
	_game = {
		title     = "DPLEngine",
		subtitle  = "Löve Engine",
		copyright = "Copyright © 2018 Darius \"DPlay\" K.",
		developer = "Darius \"DPlay\" K.",
		publisher = "None",
		version   = "0.0.0",
		identity  = "DPLEngine"
	}

	_game.fullTitle = _game.subtitle and _game.title .. ": " .. _game.subtitle or _game.title

	-- Main settings
	t.version = "0.10.2"
	t.accelerometerjoystick = false

	t.identity = _game.identity
	t.appendidentity = true
	t.externalstorage = false

	-- I'll create the window within love.load
	t.window = false
	t.gammacorrect = true

	-- Argument processing
	_arg = require "libs.args"

	if type(_arg.srgb) == "boolean" then t.gammacorrect = _arg.srgb end
end
