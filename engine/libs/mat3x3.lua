--[[
3x3 Matrices
]]
local ffi = require "ffi"

ffi.cdef [[
typedef struct {
	double x;
	double y;
	double z;
} Engine_Mat3Row
]]

ffi.cdef [[
typedef struct {
	Engine_Mat3Row a;
	Engine_Mat3Row b;
	Engine_Mat3Row c;
} Engine_Mat3x3
]]
--[[
Mat x y z
  a 1 0 0
  b 0 1 0
  c 0 0 1
]]

local Mat3Row = ffi.typeof("Engine_Mat3Row")
local Mat3x3 = ffi.typeof("Engine_Mat3x3")

local row = function(row)
	return ("%.2f, %.2f, %.2f"):format(row.x, row.y, row.z)
end

-- Effectively a Vector3
ffi.metatype(Mat3Row, {
	__mul = function(a, b)
		return a.x * b.x + a.y * b.y + a.z * b.z
	end,
	__tostring = function(self)
		return ("Mat3Row: %s"):format(row(self))
	end
})

-- 3x3 Matrix
ffi.metatype(Mat3x3, {
	__mul = function(a, b)
		return Mat3x3(
			Mat3Row(a.a * b.x, a.a * b.y, a.a * b.z),
			Mat3Row(a.b * b.x, a.b * b.y, a.b * b.z),
			Mat3Row(a.c * b.x, a.c * b.y, a.c * b.z)
		)
	end,
	__index = function(self, k)
		return Mat3Row(self.a[k], self.b[k], self.c[k])
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
			Mat3Row(a, 0, 0),
			Mat3Row(0, a, 0),
			Mat3Row(0, 0, a)
		)
	elseif d then
		return Mat3x3(
			Mat3Row(a, b, c),
			Mat3Row(d, e, f),
			Mat3Row(g, h, i)
		)
	else
		return Mat3x3(a, b, c)
	end
end
