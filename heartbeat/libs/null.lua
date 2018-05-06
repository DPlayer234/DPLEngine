--[[
'null', aka explicit nil
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
