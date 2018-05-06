--[[
Quickly create customized C-structs
]]
local ffi = require "ffi"

local cdata = {}

-- C-Types
cdata.Int = ffi.typeof("int")
cdata.Float = ffi.typeof("float")
cdata.Double = ffi.typeof("double")

local structId = 0

-- Creates and returns a new struct type
function cdata.newStruct(name, proto, op)
	-- Generate the C-struct data type
	local structName = ("struct %s_%d"):format(name, structId)
	structId = structId + 1

	ffi.cdef(structName .. "{" .. proto .. "}")

	local ctype = ffi.typeof(structName)
	local array = ffi.typeof(structName .. "[?]")

	if op.meta == nil then op.meta = {} end
	if op.methods == nil then op.methods = {} end
	if op.getters == nil then op.getters = {} end
	if op.setters == nil then op.setters = {} end

	local meta, methods, getters, setters = op.meta, op.methods, op.getters, op.setters

	-- Meta-function modifier
	meta.__index = function(self, key)
		if getters[key] then
			return getters[key](self)
		end
		return methods[key]
	end

	meta.__newindex = function(self, key, value)
		if setters[key] then
			return setters[key](self, value)
		end
		error("struct '" .. name .. "' has no member named '" .. tostring(key) .. "'")
	end

	-- Additional methods
	function methods.is(value)
		return ffi.istype(ctype, value)
	end

	function methods:type()
		return name
	end

	function methods:typeOf(typeName)
		return name == typeName
	end

	function methods.newArray(length)
		return array(length)
	end

	-- Assign metatable
	ffi.metatype(ctype, meta)

	return ctype
end

return cdata
