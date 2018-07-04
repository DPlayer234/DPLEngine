--[[
A wrapper for Löve-graphics
]]
local RequireTable = require "Heartbeat::RequireTable"
local lgraphics = require "love.graphics"

local assert = assert

local graphics = {}

graphics.push = lgraphics.push
graphics.pop = lgraphics.pop

-- Applies a Heartbeat transform's transformation
function graphics.useTransform(transform, center)
	local x,  y  = transform:getPosition():unpack()
	local sx, sy = transform:getScale():unpack()
	local cx, cy = 0, 0

	if center then cx, cy = center:unpack() end

	lgraphics.translate(x, y)
	lgraphics.rotate(transform:getAngle())
	lgraphics.translate(-cx, -cy)
	lgraphics.scale(sx, sy)
end

-- Sets the color via Color-object
function graphics.setColor(color)
	assert(color:typeOf("Color"), "Expected a Color.")
	return lgraphics.setColor(color[1], color[2], color[3], color[4])
end

-- Load submodules
local submoduleLoader = RequireTable((...):gsub("%.init$", ""))

submoduleLoader:loadInto(graphics, "drawable")
submoduleLoader:loadInto(graphics, "loading")
submoduleLoader:loadInto(graphics, "printing")

return graphics
