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
	NaN = 0/0,

	e = math.exp(1),
	pi = math.pi
}

-- Rounding functions
function mathf.round(n)
	return n + 0.5 - (n + 0.5) % 1
end

-- Round with a multiplier
function mathf.round2(n, f)
	n = n + 0.5 / f
	return n - n % (1 / f)
end

-- Returns true if the value is either positive or negative infinity
function mathf.isInfinity(value)
	return value == mathf.infinity or value == -mathf.infinity
end

-- Returns true if the value is NaN
function mathf.isNaN(value)
	return value ~= value
end

return mathf
