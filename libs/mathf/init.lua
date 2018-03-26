--[[
Simple extended math library.
]]
local currentModule = (...):gsub("%.init$", "")
local mathf = {}

-- Loads the Vector2 sub-module
require(currentModule .. ".vector2")(mathf)

-- Regular math
local floor = math.floor

-- Rounding functions
function mathf.round(n)
	return floor(n + 0.5)
end

-- Round with a multiplier
function mathf.roundn(n, f)
	return floor(n * f + 0.5) / f
end

return mathf
