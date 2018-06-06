--[[
Aligns objects relative to the screen
]]
local lgraphics = require "love.graphics"
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"

local Alignment = class("Alignment", require "Heartbeat::ECS::Component")

-- Creates a new aligner
function Alignment:new()
	self:Component()

	self._used = false
	self._alignment = self:_getDefaults()
end

-- Sets the alignment
function Alignment:set(args)
	if args == nil then
		self._alignment = self:_getDefaults()
		self._used = false
		return
	end

	self._used = true

	self._alignment.offset = args.offset or Vector2.zero
	self._alignment.anchor = args.anchor or self._alignment.anchor
end

-- Returns the alignment parameters
function Alignment:get()
	if not self._used then
		return nil
	end

	return {
		offset = self._alignment.offset,
		anchor = self._alignment.anchor
	}
end

-- Updates the position
function Alignment:postUpdate()
	if self._used then
		-- Screen size
		local screen = Vector2(lgraphics.getDimensions())
		local position = self.ecs.transformation:inverseTransformPoint(Vector2.multiply(screen, self._alignment.anchor) + self._alignment.offset)
		self.transform:setPosition(position)
	end
end

-- Gets the default alignment
function Alignment:_getDefaults()
	return {
		offset = Vector2.zero,
		anchor = Vector2.zero
	}
end

return Alignment
