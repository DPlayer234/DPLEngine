--[[
Create color objects, which can be added, multiplied and whatnot as 4D-vectors.
col = colors(r, g, b [, a]) -- Range: 0.0-1.0 for Löve >= 0.11, otherwise 0-255
col = colors.new(r, g, b [, a]) -- Range: 0-255 (rgba8 mode)
col = colors.vec4(r, g, b [, a]) -- Range: 0.0-1.0 (vec4 mode)
r, g, b, a = col(rm, gm, bm, am) -- Multiplies all values of col by the given values and returns them
r, g, b, a = colors.mix(col_a, col_b, dist) -- Mixes two colors and returns the RGBA values.
col.r, col.g, col.b and col.a can also be accessed and written to correctly and expect/are 0-255.
col.x, col.y, col.z and col.w work similarly but expect/are 0.0-1.0 instead.
+, -, *, /, ^ operators supported with colors (considered as values 0.0-1.0 always) and numbers.

colors {name={r, g, b, a}, ...}
	Will load all given colors into the colors table.
	Add __rgba8=true or __vec4=true into it to use the respective modes.
]]
local FORCE_NORMAL = false
-- Forcibly enables Löve 0.11/vector mode

local type, pairs, setm, getm = type, pairs, setmetatable, getmetatable
local min, max = math.min, math.max

local colors = {}

local newColor, meta

local function arithmeticError(a, b)
	local invalidType = getm(a) == meta and type(b) or type(a)
	return error("attempt to perform arithmetic on a "..invalidType.." value (with color)", 2)
end

meta = {
	-- __index, __newindex, __add, __sub, __div, __pow and __tostring are version-dependent
	__index = nil, __newindex = nil, __tostring = nil, __add = nil, __sub = nil, __div = nil, __pow = nil,
	__call = function(self, r, g, b, a)
		return self[1]*r, self[2]*g, self[3]*b, self[4]*a
	end,
	__unm = function(a)
		return setm({ -a[1], -a[2], -a[3], -a[4] }, meta)
	end,
	__eq = function(a, b)
		return a[1]==b[1] and a[2]==b[2] and a[3]==b[3] and a[4]==b[4]
	end
}

function colors:__call(r, g, b, a)
	if type(r) == "table" then
		local const = r.__vec4 and self.vec4 or r.__rgba8 and self.new or newColor
		for k,v in pairs(r) do
			if not k:find("__") then
				self[k] = const(v[1], v[2], v[3], v[4])
			end
		end
		return self
	else
		return newColor(r, g, b, a)
	end
end

function colors.mix(a, b, w)
	return b[1]*w+a[1]*(1-w), b[2]*w+a[2]*(1-w), b[3]*w+a[3]*(1-w), b[4]*w+a[4]*(1-w)
end

function colors.newMixed(a, b, w)
	return newColor(colors.mix(a, b, w))
end

function colors.hsv(h, s, v)
	h = (h % 1) * 360
	local c = v * s
	local x = c * (1 - math.abs((h / 60) % 2 - 1))
	local m = v - c
	c = c + m
	x = x + m

	if h < 60 then
		return colors.vec4(c, x, m)
	elseif h < 120 then
		return colors.vec4(x, c, m)
	elseif h < 180 then
		return colors.vec4(m, c, x)
	elseif h < 240 then
		return colors.vec4(m, x, c)
	elseif h < 300 then
		return colors.vec4(x, m, c)
	else
		return colors.vec4(c, m, x)
	end
end

local major, minor = love.getVersion()

if FORCE_NORMAL or major > 0 or minor > 10 then
	print("[Colors]", "Using normalized color values (0.0-1.0)")

	function meta:__index(k)
		if     k == "r" then return self[1] * 255
		elseif k == "g" then return self[2] * 255
		elseif k == "b" then return self[3] * 255
		elseif k == "a" then return self[4] * 255
		elseif k == "x" then return self[1]
		elseif k == "y" then return self[2]
		elseif k == "z" then return self[3]
		elseif k == "w" then return self[4]
		end
	end
	function meta:__newindex(k, v)
		if     k == "r" then self[1] = v / 255
		elseif k == "g" then self[2] = v / 255
		elseif k == "b" then self[3] = v / 255
		elseif k == "a" then self[4] = v / 255
		elseif k == "x" then self[1] = v
		elseif k == "y" then self[2] = v
		elseif k == "z" then self[3] = v
		elseif k == "w" then self[4] = v
		else error("cannot assign new values to colors", 2)
		end
	end

	function meta.__add(a, b)
		if     type(a) == "number" then return setm({ b[1]+a, b[2]+a, b[3]+a, b[4]+a }, meta)
		elseif type(b) == "number" then return setm({ a[1]+b, a[2]+b, a[3]+b, a[4]+b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]+b[1]), (a[2]+b[2]), (a[3]+b[3]), (a[4]+b[4]) }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__sub(a, b)
		if     type(a) == "number" then return setm({ a-b[1], a-b[2], a-b[3], a-b[4] }, meta)
		elseif type(b) == "number" then return setm({ a[1]-b, a[2]-b, a[3]-b, a[4]-b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]-b[1]), (a[2]-b[2]), (a[3]-b[3]), (a[4]-b[4]) }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__mul(a, b)
		if     type(a) == "number" then return setm({ b[1]*a, b[2]*a, b[3]*a, b[4]*a }, meta)
		elseif type(b) == "number" then return setm({ a[1]*b, a[2]*b, a[3]*b, a[4]*b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]*b[1]), (a[2]*b[2]), (a[3]*b[3]), (a[4]*b[4]) }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__div(a, b)
		if     type(a) == "number" then return setm({ a/b[1], a/b[2], a/b[3], a/b[4] }, meta)
		elseif type(b) == "number" then return setm({ a[1]/b, a[2]/b, a[3]/b, a[4]/b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]/b[1]), (a[2]/b[2]), (a[3]/b[3]), (a[4]/b[4]) }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__pow(a, b)
		if     type(a) == "number" then return setm({ a^b[1], a^b[2], a^b[3], a^b[4] }, meta)
		elseif type(b) == "number" then return setm({ a[1]^b, a[2]^b, a[3]^b, a[4]^b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]^b[1]), (a[2]^b[2]), (a[3]^b[3]), (a[4]^b[4]) }, meta)
		else arithmeticError(a, b)
		end
	end

	function meta:__tostring()
		return ("# %02X %02X %02X %02X"):format(max(0, min(self[1]*255, 255)), max(0, min(self[2]*255, 255)), max(0, min(self[3]*255, 255)), max(0, min(self[4]*255, 255)))
	end

	function newColor(r, g, b, a)
		return setm({(r or 1.0), (g or 1.0), (b or 1.0), (a or 1.0)}, meta)
	end

	function colors.new(r, g, b, a)
		return setm({ (r or 255)/255, (g or 255)/255, (b or 255)/255, (a or 255)/255 }, meta)
	end

	colors.vec4 = newColor

	colors.max = 1.0
else
	print("[Colors]", "Using integer color values (0-255)")

	function meta:__index(k)
		if     k == "r" then return self[1]
		elseif k == "g" then return self[2]
		elseif k == "b" then return self[3]
		elseif k == "a" then return self[4]
		elseif k == "x" then return self[1] / 255
		elseif k == "y" then return self[2] / 255
		elseif k == "z" then return self[3] / 255
		elseif k == "w" then return self[4] / 255
		end
	end
	function meta:__newindex(k, v)
		if     k == "r" then self[1] = v
		elseif k == "g" then self[2] = v
		elseif k == "b" then self[3] = v
		elseif k == "a" then self[4] = v
		elseif k == "x" then self[1] = v * 255
		elseif k == "y" then self[2] = v * 255
		elseif k == "z" then self[3] = v * 255
		elseif k == "w" then self[4] = v * 255
		else error("cannot assign new values to colors", 2)
		end
	end

	function meta.__add(a, b)
		if     type(a) == "number" then return setm({ b[1]+a*255, b[2]+a*255, b[3]+a*255, b[4]+a*255 }, meta)
		elseif type(b) == "number" then return setm({ a[1]+b*255, a[2]+b*255, a[3]+b*255, a[4]+b*255 }, meta)
		elseif getm(a) == getm(b)  then return setm({ a[1]+b[1],  a[2]+b[2],  a[3]+b[3],  a[4]+b[4]  }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__sub(a, b)
		if     type(a) == "number" then return setm({ a*255-b[1], a*255-b[2], a*255-b[3], a*255-b[4] }, meta)
		elseif type(b) == "number" then return setm({ a[1]-b*255, a[2]-b*255, a[3]-b*255, a[4]-b*255 }, meta)
		elseif getm(a) == getm(b)  then return setm({ a[1]-b[1],  a[2]-b[2],  a[3]-b[3],  a[4]-b[4]  }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__mul(a, b)
		if     type(a) == "number" then return setm({ b[1]*a, b[2]*a, b[3]*a, b[4]*a }, meta)
		elseif type(b) == "number" then return setm({ a[1]*b, a[2]*b, a[3]*b, a[4]*b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]*b[1])/255, (a[2]*b[2])/255, (a[3]*b[3])/255, (a[4]*b[4])/255 }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__div(a, b)
		if     type(a) == "number" then return setm({ (a/b[1])*65025, (a/b[2])*65025, (a/b[3])*65025, (a/b[4])*65025 }, meta)
		elseif type(b) == "number" then return setm({ a[1]/b, a[2]/b, a[3]/b, a[4]/b }, meta)
		elseif getm(a) == getm(b)  then return setm({ (a[1]/b[1])*255, (a[2]/b[2])*255, (a[3]/b[3])*255, (a[4]/b[4])*255 }, meta)
		else arithmeticError(a, b)
		end
	end
	function meta.__pow(a, b) -- Holy $#!%.
		if     type(a) == "number" then return setm({ (a^(b[1]/255))*255, (a^(b[2]/255))*255, (a^(b[3]/255))*255, (a^(b[4]/255))*255 }, meta)
		elseif type(b) == "number" then return setm({ ((a[1]/255)^b)*255, ((a[2]/255)^b)*255, ((a[3]/255)^b)*255, ((a[4]/255)^b)*255 }, meta)
		elseif getm(a) == getm(b)  then return setm({ ((a[1]/255)^(b[1]/255))*255, ((a[2]/255)^(b[2]/255))*255, ((a[3]/255)^(b[3]/255))*255, ((a[4]/255)^(b[4]/255))*255 }, meta)
		else arithmeticError(a, b)
		end
	end

	function meta:__tostring()
		return ("# %02X %02X %02X %02X"):format(max(0, min(self[1], 255)), max(0, min(self[2], 255)), max(0, min(self[3], 255)), max(0, min(self[4], 255)))
	end

	function newColor(r, g, b, a)
		return setm({(r or 255), (g or 255), (b or 255), (a or 255)}, meta)
	end

	colors.new = newColor

	function colors.vec4(r, g, b, a)
		return setm({(r or 1)*255, (g or 1)*255, (b or 1)*255, (a or 1)*255}, meta)
	end

	colors.max = 255
end

colors.__index = colors

colors = setm({}, colors)

return colors
