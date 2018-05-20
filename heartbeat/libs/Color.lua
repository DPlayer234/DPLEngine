--[[
Colors
]]
local math = math
local setmetatable, type = setmetatable, type
local lmath = require "love.math"

local TYPE_NAME = "Color" --#const

local meta

-- Type constructor
local Color = function(r, g, b, a)
	return setmetatable({ r or 0, g or 0, b or 0, a or 1}, meta)
end

-- Getters
local getters = {
	-- Constants
	white  = function() return Color(1, 1, 1, 1) end,
	black  = function() return Color(0, 0, 0, 1) end,
	clear  = function() return Color(0, 0, 0, 0) end,
	red    = function() return Color(1, 0, 0, 1) end,
	yellow = function() return Color(1, 1, 0, 1) end,
	green  = function() return Color(0, 1, 0, 1) end,
	cyan   = function() return Color(0, 1, 1, 1) end,
	blue   = function() return Color(0, 0, 1, 1) end,
	pink   = function() return Color(1, 0, 1, 1) end,
	random = function() return Color(lmath.random(), lmath.random(), lmath.random(), 1) end,
	-- Quick access
	r = function(c) return c[1] end,
	g = function(c) return c[2] end,
	b = function(c) return c[3] end,
	a = function(c) return c[4] end,
}

-- Explicit methods
local methods = {
	-- Copy the current color
	copy = function(self)
		return Color(self[1], self[2], self[3], self[4])
	end,
	-- Get the squared brightness of the color
	getBrightnessSqr = function(self)
		return (self.r * self.r + self.g * self.g + self.b * self.b) * self.a
	end,
	-- Get the brightness of the color
	getBrightness = function(self)
		return self:getMagnitudeSqr() ^ 0.5
	end,
	-- Returns all components in order
	unpack = function(self)
		return self[1], self[2], self[3], self[4]
	end,
	-- Type
	type = function() return TYPE_NAME end,
	typeOf = function(self, name) return name == TYPE_NAME end,
	is = function(value) return getmetatable(value) == meta end,
	-- Other constructors
	-- Expects values in the range 0-255 rather than 0-1
	fromUInt8 = function(r, g, b, a)
		return Color(r, g, b, a or 255) * (1/255)
	end,
	-- Converts a color from HSV into this format
	fromHSV = function(h, s, v, a)
		h = (h % 1) * 360
		local c = v * s
		local x = c * (1 - math.abs((h / 60) % 2 - 1))
		local m = v - c
		c = c + m
		x = x + m

		if h < 60 then
			return Color(c, x, m, a)
		elseif h < 120 then
			return Color(x, c, m, a)
		elseif h < 180 then
			return Color(m, c, x, a)
		elseif h < 240 then
			return Color(m, x, c, a)
		elseif h < 300 then
			return Color(x, m, c, a)
		else
			return Color(c, m, x, a)
		end
	end,
	-- Basically generates a gray-scale color with the given brighness
	fromBrightness = function(b, a)
		return Color(b, b, b, a)
	end
}

-- Metatable, including operators
meta = {
	-- Addition
	__add = function(a, b)
		return Color(a.r + b.r, a.g + b.g, a.b + b.b, a.a + b.a)
	end,
	-- Subtraction
	__sub = function(a, b)
		return Color(a.r - b.r, a.g - b.g, a.b - b.b, a.a - b.a)
	end,
	-- Memberwise multiplication (*)
	__mul = function(a, b)
		if type(a) == "number" then
			return Color(a * b.r, a * b.g, a * b.b, a * b.a)
		elseif type(b) == "number" then
			return Color(a.r * b, a.g * b, a.b * b, a.a * b)
		end
		return Color(a.r * b.r, a.g * b.g, a.b * b.b, a.a * b.a)
	end,
	-- Memberwise division (/)
	__div = function(a, b)
		if type(b) == "number" then
			return Color(a.r / b, a.g / b, a.b / b, a.a / b)
		end
		return Color(a.r / b.r, a.g / b.g, a.b / b.b, a.a / b.a)
	end,
	-- Memberwise exponent (^)
	_pow = function(a, b)
		if type(b) == "number" then
			return Color(a.r ^ b, a.g ^ b, a.b ^ b, a.a ^ b)
		end
		return Color(a.r ^ b.r, a.g ^ b.g, a.b ^ b.b, a.a ^ b.a)
	end,
	-- Memberwise modulo (%)
	_mod = function(a, b)
		if type(b) == "number" then
			return Color(a.r % b, a.g % b, a.b % b, a.a % b)
		end
		return Color(a.r % b.r, a.g % b.g, a.b % b.b, a.a % b.a)
	end,
	-- Unary minus
	__unm = function(a)
		return Color(-a.r, -a.g, -a.b, -a.a)
	end,
	-- Equality
	__eq = function(a, b)
		if methods.is(a) ~= methods.is(b) then return false end
		return a.r == b.r and a.g == b.g and a.b == b.b and a.a == b.a
	end,
	-- Nicer string format
	__tostring = function(self)
		return ("Color: #%02x%02x%02x%02x"):format(self.r * 255, self.g * 255, self.b * 255, self.a * 255)
	end,
	-- Indexer
	__index = function(self, key)
		if getters[key] then
			return getters[key](self)
		end
		return methods[key]
	end
}

return setmetatable({}, {
	__call = function(self, r, g, b, a)
		return Color(r, g, b, a)
	end,
	__index = meta.__index
})
