--[[
'null', aka explicit nil
It behaves a little bit different than nil:
It is considered truthy and, unlike nil, it does not return true when compared against FFI null-pointers.
It should also not be explicitly compared against (e.g. myvar == null).
]]
local rawequal = rawequal

local ffi = require "ffi"

ffi.cdef [[
struct Heartbeat_null_t {};
]]

local null_t = ffi.typeof("struct Heartbeat_null_t")

local null = null_t()

ffi.metatype(null_t, {
	__eq = function(a, b) return rawequal(a, nil) or rawequal(b, nil) or rawequal(a, b) end,
	__tostring = function() return "null" end
})

return null
