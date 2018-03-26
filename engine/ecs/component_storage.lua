--[[
Stores components
]]
local ComponentStorage = class("ComponentStorage")

-- Allows implicitly creating 2D tables
local implicit2d = {
	__index = function(t, k)
		local v = {}
		rawset(t, k, v)
		return v
	end
}

-- Creates a new ComponentStorage
function ComponentStorage:new()
	self._components = setmetatable({}, implicit2d)
end

-- Returns whether the storage contains the component
function ComponentStorage:contains(component)
	local list = self:_getValueList(component)
	for i=1, #list do
		if list[i] == component then
			return true
		end
	end
	return false
end

-- Adds a component to the storage
function ComponentStorage:add(component)
	if self:contains(component) then return end

	local list = self:_getValueList(component)
	list[#list + 1] = component

	return component
end

-- Removes a component from the storage
function ComponentStorage:remove(component)
	local list = self:_getValueList(component)
	for i=1, #list do
		if list[i] == component then
			table.remove(list, i)
			return true
		end
	end
	return false
end

-- Gets a component of the given type. Which one is undefined.
function ComponentStorage:get(class)
	local component = self:getExact(class)
	if component then return component end

	for _, child in pairs(class.CHILDREN) do
		local component = self:get(child)
		if component then return component end
	end
end

-- Gets a component of exactly the given class
function ComponentStorage:getExact(class)
	return self:_getClassList(class)[1]
end

-- Gets all components of the given type. The order is undefined.
function ComponentStorage:getAll(class)
	local components = self:getAllExact(class)

	for _, child in pairs(class.CHILDREN) do
		for _, component in ipairs(self:getAll(child)) do
			components[#components + 1] = component
		end
	end
	return components
end

-- Gets all components of exactly the given class
function ComponentStorage:getAllExact(class)
	return { unpack(self:_getClassList(class)) }
end

-- Updates all contained components
function ComponentStorage:updateAll(dt)
	for class, list in pairs(self._components) do
		for i=1, #list do
			list[i]:update(dt)
		end
	end
end

-- Clears all destroyed components out
function ComponentStorage:clearDestroyed()
	for class, list in pairs(self._components) do
		for i=#list, 1, -1 do
			if list[i]._destroy then
				list[i]._destroyed = true
				table.remove(list, i)
			end
		end
	end
end

-- Gets the component list for the class of the given component
function ComponentStorage:_getValueList(value)
	return self:_getClassList(value.CLASS)
end

-- Gets the component list of the given class
function ComponentStorage:_getClassList(class)
	return self._components[class]
end

return ComponentStorage
