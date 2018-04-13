--[[
A wholesome solution to all your keyboard, mouse or gamepad input needs.
Maybe.
]]
local currentModule = (...):gsub("%.init$", "")
local love, math, table, ipairs, pairs = love, math, table, ipairs, pairs

local input2 = {}

local keyNames    = require(currentModule .. ".key_names")
local buttonNames = require(currentModule .. ".button_names")

-- Key bindings
local boundKeys    = {}
local boundButtons = {}
local boundAxes    = {}
local boundMouse   = {}

local axisThreshold = 0.25
local repeatDelay, repeatRate = 0.5, 0.075

local lastType
local KEYBOARD_TYPE = "keyboard" --#const
local GAMEPAD_TYPE = "gamepad" --#const

-- Events
local downEvents = {}
local upEvents   = {}

local emptyHandler = function() end

local eventList = {
	"keypressed",
	"keyreleased",
	"gamepadpressed",
	"gamepadreleased",
	"gamepadaxis",
	"mousepressed",
	"mousereleased",
	"mousemoved",
	"wheelmoved"
}

local axesNeg = {}
local axesPos = {}

for _, name in ipairs { "leftx", "lefty", "rightx", "righty", "triggerleft", "triggerright" } do
	axesNeg[name] = name .. "-"
	axesPos[name] = name .. "+"
end

-- Input classes
-- Base Input class
local Input = class("Input")
do
	function Input:new()
		self:reset()
	end

	function Input:held(id)
		return self._down[id] and true
	end

	function Input:down(id)
		return self._now[id] == true
	end

	function Input:up(id)
		return self._now[id] == false
	end

	function Input:rep(id)
		return self:down(id) or (self._down[id] or 0) > repeatDelay
	end

	function Input:axis(id)
		return self._axis[id] or self:held(id) and 1 or 0
	end

	function Input:_onDown(id, ...)
		if self._downEvents[id] then self._downEvents[id](...) end
	end

	function Input:_onUp(id, ...)
		if self._upEvents[id] then self._upEvents[id](...) end
	end

	function Input:reset(id)
		self._down = {}
		self._now  = {}
		self._axis = {}
	end

	function Input:releaseInput(id)
		self._down[id] = nil
		self._now[id] = false
	end

	function Input:endFrame(dt)
		self._now = {}

		for k, v in pairs(self._down) do
			if v > repeatDelay then
				v = (v - repeatDelay) % repeatRate + repeatDelay - repeatRate
			end
			v = v + dt * self:axis(k)
			self._down[k] = v
		end
	end

	function Input:_bindInput(what, id)
		self._bound[what] = id
	end

	function Input:_bindAxis(axis, idneg, idpos)
		self._bound[axesNeg[axis]] = idneg
		self._bound[axesPos[axis]] = idpos
	end

	function Input:_noBindSet()
		error("Cannot bind this input type to " .. tostring(self))
	end

	function Input:_getBinding(what)
		return self._bound[what]
	end

	function Input:_getAxisBinding(what)
		return self._bound[axesNeg[what]], self._bound[axesPos[what]]
	end

	function Input:_noBindGet() end

	Input.bindKey    = Input._noBindSet
	Input.bindButton = Input._noBindSet
	Input.bindAxis   = Input._noBindSet
	Input.bindMouse  = Input._noBindSet

	Input.getKeyBinding    = Input._noBindGet
	Input.getButtonBinding = Input._noBindGet
	Input.getAxisBinding   = Input._noBindGet
	Input.getMouseBinding  = Input._noBindGet

	function Input:bindDownEvent(id, event)
		self._downEvents[id] = event
	end

	function Input:bindUpEvent(id, event)
		self._upEvents[id] = event
	end

	for _, event in ipairs(eventList) do
		Input[event] = emptyHandler
	end
end

-- Keyboard Input
local KeyboardInput = class("KeyboardInput", Input)
do
	function KeyboardInput:new(bound, down, up)
		self:Input()

		self._bound = bound or boundKeys
		self._downEvents = down or {}
		self._upEvents = up or {}
	end

	KeyboardInput.bindKey = Input._bindInput
	KeyboardInput.getKeyBinding = Input._getBinding

	function KeyboardInput:keypressed(key, scancode, isrepeat)
		if not isrepeat and self._bound[scancode] then
			lastType = KEYBOARD_TYPE

			self._down[self._bound[scancode]] = 0
			self._now[self._bound[scancode]] = true
			self:_onDown(self._bound[scancode], key, scancode, isrepeat)
		end
	end

	function KeyboardInput:keyreleased(key, scancode)
		if self._bound[scancode] then
			self._down[self._bound[scancode]] = nil
			self._now[self._bound[scancode]] = false
			self:_onUp(self._bound[scancode], key, scancode)
		end
	end
end

-- Gamepad Button Input
local GamepadButtonInput = class("GamepadInput", Input)
do
	function GamepadButtonInput:new(joystick, bound, down, up)
		self:Input()
		self._joystick = joystick

		self._bound = bound or boundButtons
		self._downEvents = down or {}
		self._upEvents = up or {}
	end

	GamepadButtonInput.bindButton = Input._bindInput
	GamepadButtonInput.getButtonBinding = Input._getBinding

	function GamepadButtonInput:gamepadpressed(joystick, button)
		if (self._joystick == joystick or self._joystick == nil) and self._bound[button] then
			lastType = GAMEPAD_TYPE

			self._down[self._bound[button]] = 0
			self._now[self._bound[button]] = true
			self:_onDown(self._bound[button], joystick, button)
		end
	end

	function GamepadButtonInput:gamepadreleased(joystick, button)
		if (self._joystick == joystick or self._joystick == nil) and self._bound[button] then
			self._down[self._bound[button]] = nil
			self._now[self._bound[button]] = false
			self:_onUp(self._bound[button], joystick, button)
		end
	end
end

-- Gamepad Axis Input
local GamepadAxisInput = class("GamepadAxisInput", Input)
do
	function GamepadAxisInput:new(joystick, bound, down, up)
		self:Input()
		self._joystick = joystick

		self._bound = bound or boundAxes
		self._downEvents = down or {}
		self._upEvents = up or {}
	end

	GamepadAxisInput.bindAxis = Input._bindAxis
	GamepadAxisInput.getAxisBinding = Input._getAxisBinding

	function GamepadAxisInput:axisdown(axis, value)
		if value > axisThreshold and self._bound[axis] then
			lastType = GAMEPAD_TYPE

			if not self._down[self._bound[axis]] then
				self._down[self._bound[axis]] = 0
				self._now[self._bound[axis]] = true
				self:_onDown(self._bound[axis], self._joystick, axis, value)
			end
			self._axis[self._bound[axis]] = math.min(1.0, 2 * (value - axisThreshold) / (1.0 - axisThreshold))
		end
	end

	function GamepadAxisInput:axisup(axis, value)
		if value < axisThreshold and self._bound[axis] then
			if self._down[self._bound[axis]] then
				self._down[self._bound[axis]] = nil
				self._now[self._bound[axis]] = false
				self:_onUp(self._bound[axis], self._joystick, axis, value)
			end
			self._axis[self._bound[axis]] = nil
		end
	end

	function GamepadAxisInput:gamepadaxis(joystick, axis, value)
		if (self._joystick == joystick or self._joystick == nil) then
			if value > axisThreshold then
				self:axisdown(axesPos[axis], value)
				self:axisup(axesNeg[axis], 0)
			elseif value < -axisThreshold then
				self:axisup(axesPos[axis], 0)
				self:axisdown(axesNeg[axis], -value)
			else
				self:axisup(axesPos[axis], 0)
				self:axisup(axesNeg[axis], 0)
			end
		end
	end
end

-- Mouse Input
local MouseInput = class("MouseInput", Input)
do
	function MouseInput:new(bound, down, up)
		self:Input()

		self._bound = bound or boundMouse
		self._downEvents = down or {}
		self._upEvents = up or {}
	end

	MouseInput.bindMouse = Input._bindInput
	MouseInput.getMouseBinding = Input._getBinding

	function MouseInput:mousepressed(x, y, button, istouch)
		if self._bound[button] then
			self._down[self._bound[button]] = 0
			self._now[self._bound[button]] = true
			self:_onDown(self._bound[button], x, y, button, istouch)
		end
	end

	function MouseInput:mousereleased(x, y, button, istouch)
		if self._bound[button] then
			self._down[self._bound[button]] = nil
			self._now[self._bound[button]] = false
			self:_onUp(self._bound[button], x, y, button, istouch)
		end
	end

	function MouseInput:mousemoved(x, y, dx, dy, istouch)
		if self._bound.move then
			self._now[self._bound.move] = true
			self:_onDown(self._bound.move, x, y, dx, dy, istouch)
		end
	end

	function MouseInput:wheelmoved(x, y)
		do -- X
			local id
			if x > 0 then
				id = self._bound["x+"]
			elseif x < 0 then
				id = self._bound["x-"]
			end

			if id then
				self._now[id] = true
				self:_onDown(id, x, y)
			end
		end

		do -- Y
			local id
			if y > 0 then
				id = self._bound["y+"]
			elseif y < 0 then
				id = self._bound["y-"]
			end

			if id then
				self._now[id] = true
				self:_onDown(id, x, y)
			end
		end
	end
end

-- Merges multiple input instances into one
local MergedInput = class("MergedInput", Input)
do
	function MergedInput:new(...)
		self.handlers = {...}
	end

	-- Adds an input handler and return its index
	function MergedInput:add(handler)
		local index = #self.handlers+1
		self.handlers[index] = handler
		return index
	end

	-- Removes an input handler
	function MergedInput:remove(handler)
		for i=1, #self.handlers do
			if self.handlers[i] == handler then
				table.remove(self.handlers, i)
				return
			end
		end
	end

	-- Clears all input handlers
	function MergedInput:clear()
		self.handlers = {}
	end

	-- Gets a handler at a set index
	function MergedInput:getHandler(index)
		return self.handlers[index]
	end

	for _, func in ipairs{ "held", "up", "down", "rep" } do
		MergedInput[func] = function(self, id)
			for i=1, #self.handlers do
				local handler = self.handlers[i]
				if handler[func](handler, id) then
					return true
				end
			end

			return false
		end
	end

	function MergedInput:axis(id)
		local value = 0
		for i=1, #self.handlers do
			value = math.max(value, self.handlers[i]:axis(id))
		end

		return value
	end

	for _, event in ipairs(eventList) do
		MergedInput[event] = function(self, ...)
			for i=#self.handlers, 1, -1 do
				local handler = self.handlers[i]
				handler[event](handler, ...)
			end
		end
	end

	function MergedInput:reset(id)
		for i=1, #self.handlers do
			self.handlers[i]:reset(id)
		end
	end

	function MergedInput:releaseInput(id)
		for i=1, #self.handlers do
			self.handlers[i]:releaseInput(id)
		end
	end

	function MergedInput:endFrame(dt)
		for i=1, #self.handlers do
			self.handlers[i]:endFrame(dt)
		end
	end

	MergedInput.bindUpEvent = Input._noBindSet
	MergedInput.bindDownEvent = Input._noBindSet
end

-- Merges GamepadButtonInput and GamepadAxisInput
local GamepadInput = class("GamepadInput", MergedInput)
do
	function GamepadInput:new(...)
		self.buttons = GamepadButtonInput(...)
		self.axes = GamepadAxisInput(...)
		self:MergedInput(self.buttons, self.axes)
	end

	GamepadInput.add        = class.null
	GamepadInput.remove     = class.null
	GamepadInput.clear      = class.null
	GamepadInput.getHandler = class.null

	function GamepadInput:bindButton(button, id)
		self.buttons:bindButton(button, id)
	end

	function GamepadInput:bindAxis(axis, idneg, idpos)
		self.axes:bindAxis(axis, idneg, idpos)
	end

	function GamepadInput:getButtonBinding(what)
		return self.buttons:getButtonBinding(what)
	end

	function GamepadInput:getAxisBinding(what)
		return self.axes:getAxisBinding(what)
	end

	function GamepadInput:bindUpEvent(id, event)
		self.buttons:bindUpEvent(id, event)
		self.axes:bindUpEvent(id, event)
	end

	function GamepadInput:bindDownEvent(id, event)
		self.buttons:bindDownEvent(id, event)
		self.axes:bindDownEvent(id, event)
	end
end

-- Binding keys to the global binding table
function input2.bindKey(scancode, id)
	boundKeys[scancode] = id
end

function input2.bindButton(button, id)
	boundButtons[button] = id
end

function input2.bindAxis(axis, idneg, idpos)
	boundAxes[axesNeg[axis]] = idneg
	boundAxes[axesPos[axis]] = idpos
end

function input2.bindMouse(action, id)
	boundMouse[action] = id
end

-- Get bindings from the global bindings table
function input2.getKeyBinding(scancode)
	return boundKeys[scancode]
end

function input2.getButtonBinding(button)
	return boundButtons[button]
end

function input2.getAxisBinding(axis)
	return boundAxes[axesNeg[axis]], boundAxes[axesPos[axis]]
end

function input2.getMouseBinding(action)
	return boundMouse[action]
end

-- Binding events to the global input
function input2.bindDownEvent(id, callback)
	downEvents[id] = callback
end

function input2.bindUpEvent(id, callback)
	upEvents[id] = callback
end

-- Axis Threshold
function input2.getAxisThreshold(value)
	return axisThreshold
end

function input2.setAxisThreshold(value)
	axisThreshold = value
end

-- Key Repeat
function input2.getRepeat()
	return repeatDelay, repeatRate
end

function input2.setRepeat(delay, rate)
	repeatDelay, repeatRate = delay, rate
end

-- Misc.
function input2.getLastType()
	return lastType
end

-- Returns a nice, readable name for a key
function input2.getKeyName(scancode)
	return keyNames[love.keyboard.getKeyFromScancode(scancode)]
end

-- Returns a nice name for a button
function input2.getButtonName(button, controller)
	return buttonNames[controller or "xinput"][button] or "None"
end

local handlerList = {}

-- Adds a handler to be updated and have its callbacks triggered
function input2.add(handler)
	for i=1, #handlerList do
		if handlerList[i] == handler then
			return
		end
	end

	handlerList[#handlerList + 1] = handler
end

-- Removes a handler from the callback list
function input2.remove(handler)
	for i=1, #handlerList do
		if handlerList[i] == handler then
			table.remove(handlerList, i)
			return
		end
	end
end

-- Updates all handlers
function input2.endFrame(dt)
	for i=#handlerList, 1, -1 do
		handlerList[i]:endFrame(dt)
	end
end

-- Callbacks
function input2.keypressed(key, scancode, isrepeat)
	for i=#handlerList, 1, -1 do
		handlerList[i]:keypressed(key, scancode, isrepeat)
	end
end

function input2.keyreleased(key, scancode)
	for i=#handlerList, 1, -1 do
		handlerList[i]:keyreleased(key, scancode)
	end
end

function input2.gamepadpressed(joystick, button)
	for i=#handlerList, 1, -1 do
		handlerList[i]:gamepadpressed(joystick, button)
	end
end

function input2.gamepadreleased(joystick, button)
	for i=#handlerList, 1, -1 do
		handlerList[i]:gamepadreleased(joystick, button)
	end
end

function input2.gamepadaxis(joystick, axis, value)
	for i=#handlerList, 1, -1 do
		handlerList[i]:gamepadaxis(joystick, axis, value)
	end
end

function input2.mousepressed(x, y, button, istouch)
	for i=#handlerList, 1, -1 do
		handlerList[i]:mousepressed(x, y, button, istouch)
	end
end

function input2.mousereleased(x, y, button, istouch)
	for i=#handlerList, 1, -1 do
		handlerList[i]:mousereleased(x, y, button, istouch)
	end
end

function input2.mousemoved(x, y, dx, dy, istouch)
	for i=#handlerList, 1, -1 do
		handlerList[i]:mousemoved(x, y, dx, dy, istouch)
	end
end

function input2.wheelmoved(x, y)
	for i=#handlerList, 1, -1 do
		handlerList[i]:wheelmoved(x, y)
	end
end

-- Global input object. Basically input2.down, input2.held etc. are just accessing this.
local globalInput = MergedInput()

function input2.getGlobalInput()
	return globalInput
end

input2.add(globalInput)

input2.KeyboardInput      = KeyboardInput
input2.GamepadAxisInput   = GamepadAxisInput
input2.GamepadButtonInput = GamepadButtonInput
input2.MouseInput         = MouseInput
input2.GamepadInput       = GamepadInput
input2.MergedInput        = MergedInput

function input2.held(id)
	return globalInput:held(id)
end

function input2.down(id)
	return globalInput:down(id)
end

function input2.up(id)
	return globalInput:up(id)
end

function input2.rep(id)
	return globalInput:rep(id)
end

function input2.axis(id)
	return globalInput:axis(id)
end

function input2.releaseInput(id)
	return globalInput:releaseInput(id)
end

function input2.reset(dt)
	return globalInput:reset(dt)
end

-- Setting callbacks
function input2.setUpKeyboard(override)
	if override then
		love.keypressed  = input2.keypressed
		love.keyreleased = input2.keyreleased
	end

	input2.keyboard = KeyboardInput(nil, downEvents, upEvents)
	globalInput:add(input2.keyboard)
end

function input2.setUpGamepads(override)
	if override then
		love.joystickadded   = input2.joystickadded
		love.joystickremoved = input2.joystickremoved
		love.gamepadpressed  = input2.gamepadpressed
		love.gamepadreleased = input2.gamepadreleased
		love.gamepadaxis     = input2.gamepadaxis
	end

	input2.gamepad = GamepadInput(nil, nil, downEvents, upEvents)
	globalInput:add(input2.gamepad)
end

function input2.setUpMouse(override)
	if override then
		love.mousepressed  = input2.mousepressed
		love.mousereleased = input2.mousereleased
		love.mousemoved    = input2.mousemoved
		love.wheelmoved    = input2.wheelmoved
	end

	input2.mouse = MouseInput(nil, downEvents, upEvents)
	globalInput:add(input2.mouse)
end

function input2.loadGameControllerDB()
	love.joystick.loadGamepadMappings(currentModule:gsub("%.", "/") .. "/gamecontrollerdb.txt")
end

-- Gets a new unique binding to be used as an ID
input2.UniqueBinding = class("UniqueBinding", {
	new = function() end
})

return input2
