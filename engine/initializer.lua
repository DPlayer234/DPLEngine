--[[
Loading stuff
]]
local physics  = require "love.physics"
local graphics = require "love.graphics"

local EventStore = require "libs.event_store"

local Initializer = class("Initializer")

function Initializer:new(engine)
	self.engine = engine
end

-- Initializes the engine
function Initializer:initialize(args)
	args = args or {}

	physics.setMeter(args.meter or 30)
	graphics.setDefaultFilter(args.textureFilter or "nearest")

	if args.inputHandler ~= false then
		self:setUpInput()
	end

	if args.cbEventStores ~= false then
		self:wrapCallbacks()
	end
end

-- Sets up the input system
function Initializer:setUpInput()
	local input = self.engine.input

	input.setUpKeyboard(true)
	input.setUpGamepads(true)
	input.setUpMouse(true)
end

-- Wraps all callbacks into EventStore for easier modification
function Initializer:wrapCallbacks()
	for _, callback in ipairs {
		"keypressed",
		"keyreleased",
		"mousemoved",
		"mousepressed",
		"mousereleased",
		"resize",
		"textedited",
		"textinput",
		"touchmoved",
		"touchpressed",
		"touchreleased",
		"wheelmoved",
		"gamepadaxis",
		"gamepadpressed",
		"gamepadreleased",
		"joystickadded",
		"joystickaxis",
		"joystickhat",
		"joystickpressed",
		"joystickreleased",
		"joystickremoved"
	} do
		local love_callback = love[callback]
		love[callback] = EventStore { type = "handler" }
		if love_callback then
			love[callback]:add(love_callback)
		end
	end
end

return Initializer
