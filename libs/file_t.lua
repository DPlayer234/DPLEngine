--[[
Load Tables stored in plain-text
... or modify tables.
... or load Lua files safely.
]]
local fsread, fsload = love.filesystem.read, love.filesystem.load
local assert, tonumber, pairs, type, getmetatable = assert, tonumber, pairs, type, getmetatable
local gmatch = string.gmatch

-- Faster Replacement for love.filesystem.lines (mostly when unpacked) for complete files
-- Might be slower when trying to get an early index in a list.
local fslines = function(path)
	local content = assert(fsread(path))

	return gmatch(content, "[^\n\r]+")
end

local fileT = {}

-- All the parsers for the file types
local loadData = {
	string = function(s) return s:gsub("\\n", "\n") end,
	number = function(n) return tonumber(n) end,
	bool   = function(b) return (b ~= "0" and b ~= "false") end,
	any    = function(v)
		if (v:find("^\".*\"$")) then
			return v:sub(2, #v-1):gsub("\\n", "\n")
		elseif tonumber(v) then
			return tonumber(v)
		elseif v == "true" then
			return true
		elseif v == "false" then
			return false
		end
	end
}

-- List of all types (nil == invalid, true == single, false == list)
local allTypes = {}
for k,v in pairs(loadData) do
	allTypes[k] = true
	allTypes["list:"..k] = false
end

-- Loads a table from a file
function fileT.load(file, tvalue)
	if allTypes[tvalue] == nil then
		error("Invalid value type: "..tostring(tvalue), 2)
	elseif allTypes[tvalue] then
		local loadThis = loadData[tvalue]

		local t = {}
		for line in fslines(file) do
			local k, v = line:match("^(.-)%s*=%s*(.-)$")
			if k and v then
				t[k] = loadThis(v)
			end
		end
		return t
	else
		local loadThis = loadData[tvalue:match("^list:(.*)$")]

		local t = {}
		for line in fslines(file) do
			t[#t+1] = loadThis(line)
		end
		return t
	end
end

-- Gets a single value from a table on disk
function fileT.get(file, tvalue, key)
	if allTypes[tvalue] == nil then
		error("Invalid value type: "..tostring(tvalue), 2)
	elseif allTypes[tvalue] then
		local value = ("\n"..fsread(file).."\n"):match("[\r\n]"..key.."%s*=%s*(.-)[\r\n]")
		if value then
			return loadData[tvalue](value)
		end
	elseif type(key) == "number" and key > 0 and key % 1 == 0 then
		local loadThis = loadData[tvalue:match("^list:(.*)$")]

		local i = 0
		for line in fslines(file) do
			i = i + 1
			if i == key then
				return loadThis(line)
			end
		end
	end
end

-- Loads a table from disk or the given table if applicable
local function loadFromTable(file, tvalue, table)
	if not table[tvalue] then
		return
	elseif table[tvalue][file] then
		return table[tvalue][file]
	else
		local t = fileT.load(file, tvalue)
		table[tvalue][file] = t
		return t
	end
end

local required = {}

-- Requires a file-- Table will stay in memory
function fileT.require(file, tvalue)
	if required[tvalue] == nil then
		required[tvalue] = {}
	end
	return loadFromTable(file, tvalue, required)
end

-- Requires a file and gets a key
function fileT.getRequire(file, tvalue, key)
	return fileT.require(file, tvalue)[key]
end

local weakTable = {__mode="v"}
local needed = {}

-- Needs a file-- Table will not be loaded from disk again until it is not in memory anymore
function fileT.need(file, tvalue)
	if needed[tvalue] == nil then
		needed[tvalue] = setmetatable({}, weakTable)
	end
	return loadFromTable(file, tvalue, needed)
end

-- Needs a file and gets a key
function fileT.getNeed(file, tvalue, key)
	return fileT.need(file, tvalue)[key]
end

do
	local indexed
	-- Helper function for deep copies of tables
	local function deepCopy(table)
		local copy = {}
		indexed[table] = copy
		for k,v in pairs(table) do
			if type(v) ~= "table" or getmetatable(v) then
				copy[k] = v
			else
				copy[k] = indexed[v] or deepCopy(v)
			end
		end
		return copy
	end

	-- Deep copies a table. (Entire structure is replicated, including recursion.)
	-- Anything with a metatable is considered an object and only its reference is copied.
	function fileT.deepCopy(table)
		indexed = {}
		return deepCopy(table)
	end
end

-- Returns a flat copy
function fileT.flatCopy(table)
	local copy = {}
	for k,v in pairs(table) do
		copy[k] = v
	end
	return copy
end

-- Swaps the references (contents and metatable) of two tables
function fileT.swapReferences(a, b)
	local t = {}

	setmetatable(t, getmetatable(a))
	for k,v in pairs(a) do
		t[k] = v
		a[k] = nil
	end

	setmetatable(a, getmetatable(b))
	for k,v in pairs(b) do
		a[k] = v
		b[k] = nil
	end

	setmetatable(b, getmetatable(t))
	for k,v in pairs(t) do
		b[k] = v
	end
end

-- Merges the content of table a into table b, overriding overlapping content (flat copy)
function fileT.mergeInto(a, b)
	local ameta = getmetatable(a)
	if ameta then setmetatable(b, ameta) end
	for k,v in pairs(a) do
		b[k] = v
	end
end

-- Returns a copy of b, with the content of a merged over it
function fileT.mergeCopy(a, b)
	local res = fileT.flatCopy(b)
	fileT.mergeInto(a, res)
	return res
end

-- Loads and executes Lua code and returns its return values
function fileT.loadLua(path, ...)
	return assert(fsload(path))(...)
end

return fileT
