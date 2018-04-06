--[[
Loading stuff
]]
local physics  = require "love.physics"
local lgraphics = require "love.graphics"

local EventStore = require "Heartbeat.EventStore"

local Initializer = class("Initializer")

function Initializer:new(heartbeat)
	self.heartbeat = heartbeat
end

-- Initializes the engine
function Initializer:initialize(args)
	args = args or {}

	physics.setMeter(args.meter or 30)
	lgraphics.setDefaultFilter(args.textureFilter or "nearest")

	if args.inputHandler ~= false then
		self:setUpInput()
	end

	self:wrapCallbacks()
end

-- Sets up the input system
function Initializer:setUpInput()
	local input = self.heartbeat.input

	input.setUpKeyboard(true)
	input.setUpGamepads(true)
	input.setUpMouse(true)

	self.heartbeat.usesInput = true
end

-- Sets the default callbacks
function Initializer:setCallbacks()
	--[[love.quit:add(function()
		for i=1, self.engine:getGameStateCount() do
			local state = self.engine:getActiveGameState()
			self.engine:popGameState()
			state:destroy()
		end
	end)]]
end

-- Wraps all callbacks into an EventStore for easier modification
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
		"joystickremoved",
		"quit"
	} do
		local love_callback = love[callback]
		love[callback] = EventStore { type = "handler" }
		if love_callback then
			love[callback]:add(love_callback)
		end
	end
end

return Initializer