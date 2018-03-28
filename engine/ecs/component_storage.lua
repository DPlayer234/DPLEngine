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

-- Automatically extends the definitions in the table by the class's children
local autoExtendClass = {
	__newindex = function(t, name, class)
		rawset(t, name, class)
		if class.PARENT then
			t[class.PARENT.NAME] = class.PARENT
		end
	end
}

-- Makes the table automatically assign IDs
local autoIds = {
	__index = function(t, k)
		t._id = t._id + 1
		rawset(t, k, t._id)
		return t._id
	end
}

-- Creates a new ComponentStorage
function ComponentStorage:new()
	self._classes = setmetatable({}, autoExtendClass)
	self._types   = setmetatable({ _id = 0 }, autoIds)

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
	if not component:typeOf("Component") then error("Can only add objects of type 'Component' to a ComponentStorage.") end
	if self:contains(component) then return component end

	local list = self:_getValueList(component)
	list[#list + 1] = component

	return component
end

-- Gets a component of the given type. Which one is undefined.
function ComponentStorage:get(typeName)
	local component = self:getExact(typeName)
	if component then return component end

	local class = self:_getClass(typeName)
	if class then
		for _, child in pairs(class.CHILDREN) do
			local component = self:get(child.NAME)
			if component then return component end
		end
	end
end

-- Gets a component of exactly the given class
function ComponentStorage:getExact(typeName)
	return self:_getTypeList(typeName)[1]
end

-- Gets all components of the given type. The order is undefined.
function ComponentStorage:getAll(typeName)
	local components = self:getAllExact(typeName)

	local class = self:_getClass(typeName)
	if class then
		for _, child in pairs(class.CHILDREN) do
			for _, component in ipairs(self:getAll(child.NAME)) do
				components[#components + 1] = component
			end
		end
	end
	return components
end

-- Gets all components of exactly the given class
function ComponentStorage:getAllExact(typeName)
	return { unpack(self:_getTypeList(typeName)) }
end

-- Updates all contained components
function ComponentStorage:updateAll()
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:update()
		end
	end
end

-- Post-Updates all contained components
function ComponentStorage:postUpdateAll()
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:postUpdate()
		end
	end
end

-- Draws all contained components
function ComponentStorage:drawAll()
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:draw()
		end
	end
end

-- Destroys all contained components
function ComponentStorage:destroyAll()
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			list[j]:destroy()
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
		for j=#list, 1, -1 do
			if list[j]._destroy then
				if not list[j]._destroyed then
					list[j]._destroyed = true
					list[j]:onDestroy()
				end
				table.remove(list, j)
			end
		end
	end

	self._needsClear = false
	return true
end

-- Gets the component list for the class of the given component
function ComponentStorage:_getValueList(value)
	local typeName = value.CLASS.NAME
	if not self._classes[typeName] then
		self._classes[typeName] = value.CLASS
	end

	return self:_getTypeList(typeName)
end

-- Gets the component list of the given class
function ComponentStorage:_getTypeList(typeName)
	return self._components[self._types[typeName]]
end

-- Returns the class based on the type name or nil if it isn't known in this context
function ComponentStorage:_getClass(typeName)
	return self._classes[typeName]
end

return ComponentStorage
