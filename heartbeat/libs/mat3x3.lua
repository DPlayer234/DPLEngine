--[[
3x3 Matrices
]]
local ffi = require "ffi"

local Vector3 = require "Heartbeat.Vector3"

ffi.cdef [[
typedef struct {
	Heartbeat_Vector3 a;
	Heartbeat_Vector3 b;
	Heartbeat_Vector3 c;
} Heartbeat_Mat3x3
]]
--[[
Mat x y z
  a 1 0 0
  b 0 1 0
  c 0 0 1
]]

local Mat3x3 = ffi.typeof("Heartbeat_Mat3x3")

local row = function(row)
	return ("%.2f, %.2f, %.2f"):format(row.x, row.y, row.z)
end

-- 3x3 Matrix
ffi.metatype(Mat3x3, {
	__mul = function(a, b)
		return Mat3x3(
			Vector3(a.a * b.x, a.a * b.y, a.a * b.z),
			Vector3(a.b * b.x, a.b * b.y, a.b * b.z),
			Vector3(a.c * b.x, a.c * b.y, a.c * b.z)
		)
	end,
	__index = function(self, k)
		return Vector3(self.a[k], self.b[k], self.c[k])
	end,
	__tostring = function(self)
		return ("Mat3x3: (%s)(%s)(%s)"):format(row(self.a), row(self.b), row(self.c))
	end
})

-- Constructor
return function(a, b, c, d, e, f, g, h, i)
	if a == nil then
		return Mat3x3()
	elseif a and b == nil then
		return Mat3x3(
			Vector3(a, 0, 0),
			Vector3(0, a, 0),
			Vector3(0, 0, a)
		)
	elseif d then
		return Mat3x3(
			Vector3(a, b, c),
			Vector3(d, e, f),
			Vector3(g, h, i)
		)
	else
		return Mat3x3(a, b, c)
	end
end
