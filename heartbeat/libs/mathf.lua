--[[
Simple extended math library.
]]
local math = math

local mathf = {
	-- Copy most math functions
	abs = math.abs,
	acos = math.acos,
	asin = math.asin,
	atan = math.atan,
	atan2 = math.atan2,
	cos = math.cos,
	sin = math.sin,
	tan = math.tan,
	cosh = math.cosh,
	sinh = math.sinh,
	tanh = math.tanh,
	ceil = math.ceil,
	floor = math.floor,
	modf = math.modf,
	deg = math.deg,
	rad = math.rad,
	log = math.log,
	max = math.max,
	min = math.min,

	-- Some constants
	infinity = 1/0,
	positiveInfinity = 1/0,
	negativeInfinity = -1/0,
	NaN = 0/0,

	e = math.exp(1),
	pi = math.pi
}

local floor = math.floor

-- Rounding functions
function mathf.round(n)
	return floor(n + 0.5)
end

-- Round with a multiplier
function mathf.round2(n, f)
	return floor(n * f + 0.5) / f
end

-- Returns true if the value is either positive or negative infinity
function mathf.isInfinity(value)
	return mathf.isPositiveInfinity(value) or mathf.isNegativeInfinity(value)
end

-- Returns true if the value is positive infinity
function mathf.isPositiveInfinity(value)
	return value == mathf.positiveInfinity
end

-- Returns true if the value is negative infinity
function mathf.isNegativeInfinity(value)
	return value == mathf.positiveInfinity
end

-- Returns true if the value is NaN
function mathf.isNaN(value)
	return value ~= value
end

return mathf
