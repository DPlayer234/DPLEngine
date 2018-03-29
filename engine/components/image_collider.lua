--[[
Generates a shape from an image and creates a collider based off of that.
Any blue pixel is considered to be part of the shape
There must be exactly one green pixel denoting the beginning of the shape.
There may be one red pixel denoting the end of the shape. This is not necessary if the shape loops.
If the shape does loop, it's insides should filled. Otherwise there may be artifacts.
To be considered part of the shape, a pixel must directly connect to other pixels of the shape.
Corner-connections are ignored.
]]
local ffi = require "ffi"
local physics = require "love.physics"
local Vector2 = require "Engine.Vector2"

local Collider = require("Engine.components").Collider
local ImageCollider = class("ImageCollider", Collider)

-- Image-Color-Components must have at least this value to be considered
local DETECTION_THRESHOLD = 50 --#const

-- Creates a new collider
-- > ImageCollider(imageData, [strip, density])
-- > ImageCollider(imageData, offset, [strip, density])
-- 'strip' is the strip-off threshold. 0.71 (~sqrt(2)/2) is the default works well for most cases.
-- Center default to half the width and height of the image
function ImageCollider:new(a, b, c, d)
	local imageData, offset, strip, density
	if ffi.istype(Vector2, b) then
		imageData, offset, strip, density = a, b, c, d
	else
		imageData, offset, strip, density = a, Vector2(a:getDimensions()) * 0.5, b, c
	end

	self._data = imageData
	self._strip = strip or 0.71
	self._offset = offset
	self._width, self._height = self._data:getDimensions()

	self:_findSolidPixels()
	self:_findEdge()
	self:_createShape()

	self._edgeCount = #self._edge - 1
	self:Collider(self._shape, density)

	self:_clearData()
end

-- Returns the amount of edges in the shape
function ImageCollider:getEdgeCount()
	return self._edgeCount
end

-- Returns the image offset
function ImageCollider:getOffset()
	return self._offset:copy()
end

-- Assigns a flattened 2D-array of booleans, defining whether the given pixel is solid.
-- Also finds the beginning and end-pixels of the shape
function ImageCollider:_findSolidPixels()
	self._solid = ffi.new("bool[?]", self._width * self._height)

	self._data:mapPixel(function(x, y, r, g, b, a)
		self._solid[self:_getIndex(x, y)] =
			b > DETECTION_THRESHOLD or
			r > DETECTION_THRESHOLD or
			g > DETECTION_THRESHOLD

		if g > DETECTION_THRESHOLD then
			if self._first then error("More than one beginning pixel!") end
			self._first = Vector2(x, y)
		elseif r > DETECTION_THRESHOLD then
			if self._first then error("More than one ending pixel!") end
			self._last = Vector2(x, y)
		end

		return r, g, b, a
	end)

	assert(self._first, "There is no beginning pixel.")
end

-- Find and defines the edge
function ImageCollider:_findEdge()
	self._edge = { self._first }

	repeat
		self._edge[#self._edge + 1] = self:_getNextPoint()
	until self:_getLastPoint(0) == self._last or self:_getLastPoint(0) == self._first

	self._loop = self:_getLastPoint(0) == self._first

	self:_stripEdge()
end

-- Returns the next valid edge point
function ImageCollider:_getNextPoint()
	local l0 = self:_getLastPoint(0)
	local l1 = self:_getLastPoint(1)

	for i, v in ipairs {
		Vector2(l0.x, l0.y - 1),
		Vector2(l0.x - 1, l0.y),
		Vector2(l0.x + 1, l0.y),
		Vector2(l0.x, l0.y + 1),
	} do
		if v ~= l1 and self:_isEdgePoint(v.x, v.y) then
			return v
		end
	end
	error("Cannot find Edge continuation? Make sure the image shape never ends in a single-pixel lines.")
end

-- Returns whether the given pixel is a valid edge point
function ImageCollider:_isEdgePoint(x, y)
	if not self:_isSolid(x, y) then return false end

	for x_ = x - 1, x + 1 do
		for y_ = y - 1, y + 1 do
			if not self:_isSolid(x_, y_) then
				return true
			end
		end
	end
	return false
end

-- Reverse-indexing _edge
function ImageCollider:_getLastPoint(i)
	return self._edge[#self._edge - i]
end

-- Returns whether the given pixel is solid
function ImageCollider:_isSolid(x, y)
	if x < 0 or x >= self._width or y < 0 or y >= self._height then
		return false
	end
	return self._solid[self:_getIndex(x, y)]
end

-- Strips the edge points to reduce the amount of points needed
function ImageCollider:_stripEdge()
	for i = #self._edge - 1, 2, -1 do
		local l1 = self._edge[i + 1]
		local l2 = self._edge[i - 1]
		local p  = self._edge[i]

		if self:_closeToLine(p, l1, l2) then
			table.remove(self._edge, i)
		end
	end

	if self._loop then
		table.remove(self._edge, #self._edge)
	end
end

-- Returns whether the point is too close to the line defined by l1 and l2
function ImageCollider:_closeToLine(p, l1, l2)
	local lv = l2 - l1
	local r = l1 - p
	local distance = Vector2.cross(lv, r) / lv:getMagnitude()
	return distance < self._strip
end

-- Creates the shape from the _edge
function ImageCollider:_createShape()
	local pointTable = {}
	for i=1, #self._edge do
		local point = self._edge[i] - self._offset
		pointTable[i*2-1] = point.x
		pointTable[i * 2] = point.y
	end

	self._shape = physics.newChainShape(self._loop, pointTable)
end

-- Gets the index for the _solid array
function ImageCollider:_getIndex(x, y)
	return x + y * self._width
end

-- Clears out data no longer needed after initialization
function ImageCollider:_clearData()
	self._data, self._width, self._height,
	self._solid, self._edge, self._first, self._last,
	self._loop, self._strip = nil
end

return ImageCollider
