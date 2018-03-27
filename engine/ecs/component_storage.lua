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

-- Allows implicitly creating 2D tables
local nextId = {
	__index = function(t, class)
		t.id = t.id + 1
		rawset(t, class, t.id)
		return t.id
	end
}

-- Creates a new ComponentStorage
function ComponentStorage:new()
	self._classId = setmetatable({ id = 0 }, nextId)
	self._components = setmetatable({}, implicit2d)

	self._needsClear = false
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
	if self:contains(component) then return component end

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
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:update(dt)
		end
	end
end

-- Post-Updates all contained components
function ComponentStorage:postUpdateAll(dt)
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:postUpdate(dt)
		end
	end
end

-- Draws all contained components
function ComponentStorage:drawAll(dt)
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:draw(dt)
		end
	end
end

-- Marks this storage needing a clear
function ComponentStorage:queueClear()
	self._needsClear = true
end

-- Clears all destroyed components out
function ComponentStorage:clearDestroyed()
	if not self._needsClear then return false end

	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			if list[j]._destroy then
				list[j]._destroyed = true
				table.remove(list, j)
			end
		end
	end

	self._needsClear = false
	return true
end

-- Gets the component list for the class of the given component
function ComponentStorage:_getValueList(value)
	return self:_getClassList(value.CLASS)
end

-- Gets the component list of the given class
function ComponentStorage:_getClassList(class)
	return self._components[self._classId[class]]
end

return ComponentStorage
