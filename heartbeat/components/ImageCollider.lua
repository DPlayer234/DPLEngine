--[[
Generates a shape from an image and creates a collider based off of that.
The general shape is defined by a blue line or blue filled shape. The pixels
of this line/shape have to connect to each other horizontally or vertically.
A green pixel defines the first vertex of the shape.
Red pixels define any additional vertices.
]]
local ffi = require "ffi"
local physics = require "love.physics"
local class = require "Heartbeat.class"
local Vector2 = require "Heartbeat.Vector2"

local Collider = require("Heartbeat.components").Collider
local ImageCollider = class("ImageCollider", Collider)

-- Image-Color-Components must have at least this value to be considered
local DETECTION_THRESHOLD = 0.4 --#const

-- Creates a new collider
-- > ImageCollider(imageData, [offset, scale, density])
-- 'offset' and 'scale' are Vector2s and default to half the image dimensions and (1, 1).
function ImageCollider:new(imageData, offset, scale, density)
	self._data = imageData
	self._offset = offset or Vector2(imageData:getDimensions()) * 0.5
	self._scale = scale or Vector2.one
	self._width, self._height = self._data:getDimensions()

	self:_findSolidPixels()
	self:_findEdge()
	self:_createShape()

	self._vertexCount = #self._vertices
	self._edgeCount = self._vertexCount - (self._loop and 0 or 1)
	self:Collider("Image", self._shape, density)

	self:_clearData()
end

-- Returns the amount of edges in the shape
function ImageCollider:getEdgeCount()
	return self._edgeCount
end

-- Returns the amount of vertices in the shape
function ImageCollider:getVertexCount()
	return self._vertexCount
end

-- Returns the image offset
function ImageCollider:getOffset()
	return self._offset:copy()
end

-- Returns whether the collider edges loop
function ImageCollider:isLooping()
	return self._loop
end

-- Assigns a flattened 2D-array of bytes, defining whether the given pixel is a connection, a vertex or empty.
-- Also finds the _first pixel of the shape.
function ImageCollider:_findSolidPixels()
	self._solid = ffi.new("uint8_t[?]", self._width * self._height)

	local verts = 0

	self._data:mapPixel(function(x, y, r, g, b, a)
		self._solid[self:_getIndex(x, y)] =
			b > DETECTION_THRESHOLD and 1 or
			r > DETECTION_THRESHOLD and 2 or
			g > DETECTION_THRESHOLD and 2 or 0

		if g > DETECTION_THRESHOLD then
			self._first = Vector2(x, y)
			verts = verts + 1
		elseif r > DETECTION_THRESHOLD then
			verts = verts + 1
		end

		return r, g, b, a
	end)

	assert(self._first, "There is no red pixel to indicate the beginning")
	assert(verts >= 3, "There need to be at least 3 vertices.")
end

-- Find and defines the edge
function ImageCollider:_findEdge()
	self._vertices = { self._first }

	repeat
		local point = self:_getNextPoint()
		self._vertices[#self._vertices + 1] = point
	until point == self._first or point == nil

	self._loop = self:_getLastPoint(0) == self._first

	if self._loop then
		table.remove(self._vertices, #self._vertices)
	end
end

-- Returns the next valid edge point
function ImageCollider:_getNextPoint()
	local pos = self:_getPointHelper {
		Vector2( 1, 0), Vector2( 0, 1),
		Vector2(-1, 0), Vector2( 0,-1),
	}

	if pos ~= self:_getLastPoint(1) then return pos end

	local pos = self:_getPointHelper {
		Vector2(-1, 0), Vector2( 0,-1),
		Vector2( 1, 0), Vector2( 0, 1),
	}

	if pos == self:_getLastPoint(1) then return nil end

	return pos
end

-- Sub-routine for finding a point
function ImageCollider:_getPointHelper(offsetList)
	local pos = self:_getLastPoint(0)
	local lpos = pos
	repeat
		for _, v in ipairs(offsetList) do
			v = pos + v
			if v ~= lpos and self:_isEdgePoint(v.x, v.y) then
				lpos = pos
				pos = v
				break
			end
		end
	until self:_getPixel(pos.x, pos.y) == 2

	return pos
end

-- Returns whether the given pixel is a valid edge point
function ImageCollider:_isEdgePoint(x, y)
	if self:_getPixel(x, y) == 0 then return false end

	for x_ = x - 1, x + 1 do
		for y_ = y - 1, y + 1 do
			if self:_getPixel(x_, y_) == 0 then
				return true
			end
		end
	end
	return false
end

-- Reverse-indexing _vertices
function ImageCollider:_getLastPoint(i)
	return self._vertices[#self._vertices - i]
end

-- Returns whether the given pixel is solid
function ImageCollider:_getPixel(x, y)
	if x < 0 or x >= self._width or y < 0 or y >= self._height then
		return 0
	end
	return self._solid[self:_getIndex(x, y)]
end

-- Creates the shape from the _vertices
function ImageCollider:_createShape()
	local pointTable = {}
	for i=1, #self._vertices do
		local point = Vector2.multiply((self._vertices[i] - self._offset), self._scale)
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
	self._data, self._width, self._height, self._solid, self._vertices, self._first = nil
end

return ImageCollider
