--[[
The class implementation used by Heartbeat.
]]
local type, tostring = type, tostring
local setmetatable, getmetatable = setmetatable, getmetatable
local rawget, rawset, rawequal = rawget, rawset, rawequal
local pairs, next = pairs, next

-- This value can be replaced with another constant if need be
local null = require "Heartbeat::null"

local class = setmetatable({}, {
	__call = function(self, ...)
		return self.new(...)
	end
})

local weakTable = { __mode = "kv" }
local defaultFalse = { __index = function() return false end }

-- Class System Main
-- For creation of new classes and the Default class.
local noNew, noNewFields, metaNew, classMeta, reservedClassFields, Default

function noNew(self)
	error("Cannot instantiate object of type "..self.CLASS.NAME..": It has no 'new' field.", 3)
end

function noNewFields()
	error("Cannot directly add new fields to class bases.", 2)
end

function metaNew(base, self, ...)
	if base.new == nil then error("Cannot call '"..base.CLASS.NAME.."': The super-class has no such method.", 2) end
	return base.new(self, ...)
end

reservedClassFields = {
	CLASS = true,
	__index = true
}

classMeta = {
	__index = function(self, k)
		local v = rawget(classMeta, k)
		if v ~= nil then
			return v
		else
			return rawget(self.BASE, k)
		end
	end,
	__tostring = function(self)
		if self.PARENT == nil then
			return "class "..tostring(self.NAME)
		end
		return "class "..tostring(self.NAME).." : "..tostring(self.PARENT.NAME)
	end,
	new = function(self, ...)
		local obj = setmetatable({}, self.BASE)
		self.NEW(obj, ...)
		return obj
	end,
	extend = function(self, k, v)
		self:extendExact(k, v)
		self.OVERRIDE[k] = true

		for _, cls in pairs(self.CHILDREN) do
			cls:extendByParent(k, v, self)
		end
	end,
	extendByParent = function(self, k, v, parent)
		if not self.OVERRIDE[k] then
			self:extendExact(k, v)

			for _, cls in pairs(self.CHILDREN) do
				cls:extendByParent(k, v, parent)
			end
		end
	end,
	extendExact = function(self, k, v)
		if reservedClassFields[k] then
			error("Field '"..tostring(k).."' is reserved in classes.", 3)
		else
			if k == "new" then
				rawset(self, "NEW", v == nil and (self.PARENT and self.PARENT.NEW or noNew) or v)
			end
			rawset(self.BASE, k, v)
		end
	end
}
classMeta.__call = classMeta.new
classMeta.__newindex = classMeta.extend

-- Creates a new class.
function class.new(name, rawbase, parent)
	if (class.is(rawbase) or rawequal(rawbase, null)) and parent == nil then
		parent = rawbase
		rawbase = {}
	end

	if rawequal(parent, nil) then
		parent = Default
	elseif rawequal(parent, null) then
		parent = nil
	elseif not class.is(parent) then
		error("Cannot extend a something that is not a class!", 2)
	end

	if type(name) ~= "string" then error("Class name has to be of type string!", 2) end
	if rawbase == nil then rawbase = {} end

	local base = {}
	local override = {}

	local typeOf = setmetatable({ [name] = true }, defaultFalse)

	-- Copying parent fields
	if parent then
		for k,v in pairs(parent.BASE) do
			base[k] = v
		end

		for k,v in pairs(parent.TYPEOF) do
			typeOf[k] = v
		end
	end

	-- Copying new base fields
	for k,v in pairs(rawbase) do
		override[k] = true
		base[k] = v
	end

	base[name] = base

	-- Metatable
	local bmeta = {
		__newindex = noNewFields,
		__call = metaNew
	}

	base.__index = base
	setmetatable(base, bmeta)

	-- Creating the class
	local cls = setmetatable({
		BASE = base,
		NEW = base.new or parent and parent.NEW or noNew,
		NAME = name,
		CHILDREN = setmetatable({}, weakTable),
		PARENT = parent,
		OVERRIDE = override,
		TYPEOF = typeOf
	}, classMeta)

	rawset(cls, "CLASS", cls)
	rawset(base, "CLASS", cls)

	if parent and parent.CHILDREN then
		parent.CHILDREN[#parent.CHILDREN+1] = cls
	end

	if parent and parent.__inherited then
		parent:__inherited(cls)
	end

	return cls
end

-- Returns whether the object in question is a class
function class.is(cls)
	return getmetatable(cls) == classMeta
end

-- Default class. Everything inherits from this.
Default = class("Default", {
	type = function(self)
		return self.CLASS.NAME
	end,
	typeOf = function(self, comp)
		return self.CLASS.TYPEOF[comp]
	end,
	instantiate = function(self)
		local obj = {}
		for k,v in pairs(self) do
			obj[k] = v
		end
		return setmetatable(obj, getmetatable(self))
	end,
	__call = function(self, arg)
		for k,v in pairs(arg) do
			self[k] = v
		end
		return self
	end,
	__tostring = function(self)
		return self:type()
	end
})

class.Default = Default

return class
