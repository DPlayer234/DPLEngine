--[[
Stores components
]]
local ComponentStorage = class("ComponentStorage")

-- Automatically extends the definitions in the table by the class's children
-- _classes
local classesMeta = {
	__newindex = function(t, name, class)
		rawset(t, name, class)
		if class.PARENT then
			t[class.PARENT.NAME] = class.PARENT
		end
	end
}

-- Makes the table automatically assign IDs
-- _typeIds
local typeIdsMeta = {
	__index = function(t, k)
		t.id = t.id + 1
		rawset(t, k, t.id)
		t.self._components[t.id].name = k
		return t.id
	end
}

-- Allows implicitly creating 2D tables
-- _components
local componentsMeta = {
	__index = function(t, k)
		local v = {}
		rawset(t, k, v)
		t.self._needsSort = true
		return v
	end
}

-- Creates a new ComponentStorage
function ComponentStorage:new()
	self._classes = setmetatable({ self = self }, classesMeta)
	self._typeIds = setmetatable({ self = self, id = 0 }, typeIdsMeta)

	self._components = setmetatable({ self = self }, componentsMeta)

	self._needsSort  = false
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
	list.priority = component.priority

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

-- Calls the named function on every component, if the component has the function
function ComponentStorage:callAll(funcName, ...)
	for i=1, #self._components do
		local list = self._components[i]
		if self._classes[list.name][funcName] then
			for j=1, #list do
				local component = list[j]
				component[funcName](component, ...)
			end
		end
	end
end

-- Calls the named function on every component
function ComponentStorage:callAllAnyways(funcName, ...)
	for i=1, #self._components do
		local list = self._components[i]
		for j=1, #list do
			local component = list[j]
			component[funcName](component, ...)
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

-- Handles internal stuff
function ComponentStorage:handle()
	if self._needsSort then
		self:_sort()
	end

	if self._needsClear then
		self:_clearDestroyed()
	end
end

-- Sorting callback
local sort = function(a, b)
	return a.priority > b.priority
end

-- Sorts the component storage
function ComponentStorage:_sort()
	local typeIds = { self = self }

	-- Remove unused tables
	for i=#self._components, 1, -1 do
		if #self._components[i] < 1 then
			table.remove(self._components, i)
		end
	end

	table.sort(self._components, sort)

	-- Update type IDs
	for i=1, #self._components do
		typeIds[self._components[i].name] = i
	end

	typeIds.id = #self._components

	self._typeIds = setmetatable(typeIds, typeIdsMeta)

	self._needsSort = false
end

-- Clears all destroyed components out
function ComponentStorage:_clearDestroyed()
	self._needsClear = false

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
	return self._components[self._typeIds[typeName]]
end

-- Returns the class based on the type name or nil if it isn't known in this context
function ComponentStorage:_getClass(typeName)
	return self._classes[typeName]
end

return ComponentStorage
