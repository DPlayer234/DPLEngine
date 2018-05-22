--[[
Stores and updates animations
]]
local math = math
local assert, type, rawget, setmetatable = assert, type, rawget, setmetatable
local lgraphics = require "love.graphics"
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"

local getQuad, framesMeta

local Animator = class("Animator", require "Heartbeat::ECS::Component")
local Animation = class("Animation")

function Animator:new(entity, texture, width, height)
	self:Component(entity)

	assert(texture and texture:typeOf("Texture"), "Every Animator needs a texture!")
	assert(type(width) == "number" and type(height) == "number", "You must define the size of the quads used.")

	self._texture = texture

	self._sheet = {
		_totalSize = Vector2(texture:getDimensions()),
		_frameSize = Vector2(width, height)
	}

	self._animations = {}

	self._animation = nil
	self:setTime(0)
end

-- Gets the used texture
function Animator:getTexture()
	return self._texture
end

-- Sets the used texture
function Animator:setTexture(value)
	if self._totalSize.x ~= value:getWidth() or self._totalSize.y ~= value:getHeight() then
		error("Dimensions of the new and old texture must match!")
	end

	self._texture = value
end

-- Gets the quad of the current animation frame
function Animator:getFrame()
	if self:getAnimation() == nil then return getQuad(self._sheet, 0, 0) end
	return self:getAnimation():getFrame(self:getTime())
end

-- Gets the timing of the animation
function Animator:getTime()
	return self._time
end

-- Sets the timing of the animation
function Animator:setTime(time)
	self._time = time
end

-- Gets the currently active animation or an animation by name
function Animator:getAnimation(name)
	return self._animations[name] or self._animation
end

-- Switches to the specified animation either by reference or name
function Animator:setAnimation(value)
	if self._animations[value] then
		value = self._animations[value]
	elseif value._sheet ~= self._sheet then
		error("The Animator's and Animation's Sprite Sheets don't match!")
	end

	self:setTime(0)
	self._animation = value
end

-- Creates a new animation and returns it
function Animator:newAnimation(name)
	local animation = Animation(self, name)
	self._animations[name] = animation
	return animation
end

-- Returns whether the current animation is finished
function Animator:isFinished()
	return self:getAnimation():isFinished(self:getTime())
end

function Animator:postUpdate()
	self:setTime(self:getTime() + self.ecs.deltaTime)
end

--[[
Animation
]]
-- Creates a new animation
function Animation:new(animator, name)
	self._name = name
	self._sheet = animator._sheet

	self._rate = 10

	self._frames = setmetatable({
		_loop = false
	}, framesMeta)
end

-- Returns the animation's name
function Animation:getName()
	return self._name
end

-- Returns whether the animation loops
function Animation:getLoop()
	return self._frames._loop
end

-- Sets the animation to loop or not
function Animation:setLoop(value)
	self._frames._loop = value
	return self
end

-- Gets the rate of the animation
function Animation:getRate()
	return self._rate
end

-- Sets the rate of the animation
function Animation:setRate(value)
	self._rate = value
	return self
end

-- Adds a frame to the animation.
-- X and Y are 0-indexed!
function Animation:addFrame(x, y)
	self._frames[#self._frames + 1] = getQuad(self._sheet, x, y)
	return self
end

-- Adds several consecutive frames to the animation.
-- Adds 'count' frames, starting at 'x, y' adding 'xd, yd' every step.
-- 'xd, yd' defaults to '1, 0'
function Animation:addFrames(count, x, y, xd, yd)
	if xd == nil then xd = 1 end
	if yd == nil then yd = 0 end

	for i=1, count do
		self:addFrame(x, y)
		x = x + xd
		y = y + yd
	end
	return self
end

-- Gets the current frame of the animation
function Animation:getFrame(time)
	return self._frames[time * self._rate] or self._frames[#self._frames]
end

-- Returns whether the animation is finished
function Animation:isFinished(time)
	return self._frames[time * self._rate] == nil
end

-- Gets a quad from a sheet
getQuad = function(sheet, x, y)
	local field = ("%f;%f"):format(x, y)

	if sheet[field] == nil then
		sheet[field] = lgraphics.newQuad(
			sheet._frameSize.x * x, sheet._frameSize.y * y,
			sheet._frameSize.x, sheet._frameSize.y,
			sheet._totalSize.x, sheet._totalSize.y
		)
	end
	return sheet[field]
end

-- The metatable for the frame-array
framesMeta = {
	__index = function(t, k)
		k = math.floor(k) + 1
		if rawget(t, "_loop") then
			return rawget(t, (k - 1) % #t + 1)
		end
		return rawget(t, k)
	end
}

return Animator
