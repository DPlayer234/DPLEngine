--[[
'null', aka explicit nil
]]
local rawequal = rawequal

local ffi = require "ffi"

ffi.cdef [[
struct Heartbeat_null {};
]]

local null_ct = ffi.typeof("struct Heartbeat_null")

local null = null_ct()

ffi.metatype(null_ct, {
	__eq = function(a, b) return rawequal(a, nil) or rawequal(b, nil) or rawequal(a, b) end,
	__tostring = function() return "null" end
})

return null
