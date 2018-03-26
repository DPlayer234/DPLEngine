--[[
Contains shapes...
Really, just a rectangle and a point, but whatever.
]]
local rt0 = function() return 0 end

-- Base shape class
local Shape = class("Shape", {
	getArea   = rt0,
	getLeft   = rt0,
	getRight  = rt0,
	getTop    = rt0,
	getBottom = rt0,
})

local Rectangle, Point

-- Simple rectangle class
Rectangle = class("Rectangle", {
	new = function(self, leftX, topY, width, height)
		self.x, self.y, self.width, self.height = leftX, topY, width, height
	end,
	-- Intersection with another rectangle
	intersects = function(self, other)
		return
			self.x + self.width > other.x and
			self.y + self.height > other.y and
			other.x + other.width > self.x and
			other.y + other.height > self.y
	end,
	-- Area
	getArea = function(self)
		return self.width * self.height
	end,
	-- Bounds
	getLeft   = function(self) return self.x end,
	getRight  = function(self) return self.x + self.width end,
	getTop    = function(self) return self.y end,
	getBottom = function(self) return self.y + self.height end,
	-- ToStringing
	__tostring = function(self) return ("Rectangle: %d, %d: %d x %d"):format(self.x, self.y, self.width, self.height) end,

	-- Packs rectangles into a small square space.
	-- Returns the size (width/height) and the list of new rectangles.
	packSquare = function(rectangles)
		local math, table = math, table

		-- Copy rectangles
		local rectOrder = {}
		for k,v in pairs(rectangles) do
			local n = #rectOrder + 1
			rectOrder[n] = v:instantiate()
			rectOrder[n].index = k
		end

		-- Sort rectangles; large to small
		table.sort(rectOrder, function(a, b)
			return a:getArea() > b:getArea()
		end)

		-- Align rectangles somewhat optimally
		local packing = {
			size = 0,
			valids = {
				Point(0, 0)
			},
			filled = {}
		}

		local newRects = {}

		for i=1, #rectOrder do
			local rect = rectOrder[i]

			local next
			local extendingBy = math.huge

			-- Check for optimal valid position
			for n=1, #packing.valids do
				local valid = packing.valids[n]
				local wouldBe = Rectangle(valid.x, valid.y, rect.width, rect.height)

				local newSize = math.max(wouldBe:getRight(), wouldBe:getBottom())
				local thisExtendingBy = newSize * newSize - packing.size * packing.size

				if thisExtendingBy < extendingBy then
					-- Causes less rectangle extension
					local canBeHere = true
					for p=1, #packing.filled do
						if wouldBe:intersects(packing.filled[p]) then
							canBeHere = false
							break
						end
					end

					if canBeHere then
						extendingBy = thisExtendingBy
						next = n
					end
				end
			end

			local position = table.remove(packing.valids, next)

			-- Set the position as filled
			local filling = Rectangle(position.x, position.y, rect.width, rect.height)
			packing.filled[i] = filling

			-- Add two of the corners as valid positions
			packing.valids[#packing.valids + 1] = Point(filling:getLeft(), filling:getBottom())
			packing.valids[#packing.valids + 1] = Point(filling:getRight(), filling:getTop())

			-- Extend the packing area as needed
			packing.size = math.max(packing.size, filling:getRight(), filling:getBottom())

			-- Define the new rectangle positions
			newRects[rect.index] = filling
		end

		return packing.size, newRects
	end
}, Shape)

-- Point class
Point = class("Point", {
	new = function(self, x, y)
		self.x, self.y = x, y
	end,
	-- """"Bounds""""
	getLeft   = function(self) return self.x end,
	getRight  = function(self) return self.x end,
	getTop    = function(self) return self.y end,
	getBottom = function(self) return self.y end,
	-- ToStringing
	__tostring = function(self) return ("Point: %d, %d"):format(self.x, self.y) end,
}, Shape)

return {
	Rectangle = Rectangle,
	Point     = Point
}
