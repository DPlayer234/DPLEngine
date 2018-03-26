--[[
Copyright (c) 2017-2018 Darius "DPlay" K.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
]]
-- Custom GameJolt API for use in Lua
local string, table, tostring, type, setmetatable, ipairs, pairs, assert = string, table, tostring, type, setmetatable, ipairs, pairs, assert

local md5 = require "libs.md5"
local json = require "libs.json"
local http = require "socket.http"

local gj = {}

-- Do not end with '/'
local BASE_URL = "http://gamejolt.com/api/game/v1" --#const

local gameId, gameKey

-- Generates a signature
local function generateSignature(url)
	return md5.sumhexa(url .. gameKey)
end

-- Escaping characters for safe use within an URL
local escapeHttp
do
	local function escapeHttpReplacer(a)
		return string.format("%%%02X", string.byte(a))
	end

	function escapeHttp(a)
		return tostring(a):gsub("([^%w%-%.%_])", escapeHttpReplacer)
	end
end

-- Safely turns an array into a comma separated string
local function toCommaList(list)
	local comma = {}

	for i,v in ipairs(list) do
		comma[#comma] = escapeHttp(v)
	end

	return table.concat(comma, ",")
end

-- Serializes the HTTP args table
local function serializeHttpArgs(args)
	local ser = {}

	for k,v in pairs(args) do
		if k == "user" then
			ser[#ser+1] = "username=" .. tostring(v.username) .. "&user_token=" .. tostring(v.token)
		elseif type(v) == "table" then
			ser[#ser+1] = tostring(k) .. "=" .. toCommaList(v)
		else
			ser[#ser+1] = tostring(k) .. "=" .. escapeHttp(v)
		end
	end

	return table.concat(ser, "&")
end

-- Gets a request table
local function getRequest(requestType)
	return setmetatable({}, {
		__index = function(t, k)
			local sub = getRequest(requestType .. "/" .. (k:gsub("_", "-")))
			t[k] = sub
			return sub
		end,
		__call = function(t, args, post)
			local url =
				BASE_URL .. requestType .. "/?game_id=" .. gameId ..
				"&format=json&" .. serializeHttpArgs(args)
			url = url .. "&signature=" .. generateSignature(url)

			local value = assert(http.request(url, post))
			return json.decode(value).response
		end
	})
end

-- Request from API in section [key]
local request = getRequest("")

-- Returns whether this is a session
local function isSession(self)
	return type(self) == "table" and self.username and self.token
end

-- Checks that this is a session
local function assertSession(self)
	return assert(isSession(self), "This is not a session.")
end

-- Returns whether a response was successful
local function getSuccess(response)
	return response.success == "true"
end

-- Makes sure you actually get a table
local function validateTable(t)
	return t == "" and {} or t
end

-- Initializes the GJ system
function gj.init(id, key)
	gameId = id
	gameKey = key
end

-- Creates a returns new session object
function gj.newSession(username, token)
	if type(username) ~= "string" or type(token) ~= "string" then
		error("Username and Token need to be strings!")
	end

	local session = setmetatable({
		username = username,
		token = token
	}, gj)

	if session:auth() then
		return session
	else
		return nil, "Failed to authenticate user. Invalid information?"
	end
end

-- Checks whether the login information is valid
function gj:auth()
	assertSession(self)

	return getSuccess(request.users.auth({
		user = self
	}))
end

-- Fetches a user/users by name (string) or ID (number); may be an array of either
function gj:fetchUser()
	if isSession(self) then self = self.username end

	local isTable = type(self) == "table"
	local isId = type(isTable and self[1] or self) == "number"

	local users = validateTable(
		isId and
		request.users.fetch({
			user_id = self
		}).users
		or
		request.users.fetch({
			username = self
		}).users
	)

	return users and (isTable and users or users[1]) or nil
end

-- Opens an online session.
function gj:openSession()
	assertSession(self)

	return getSuccess(request.sessions.open({
		user = self
	}))
end

-- Pings a session to make it stay online
function gj:pingSession(status)
	assertSession(self)

	return getSuccess(request.sessions.ping({
		user = self,
		status = status
	}))
end

-- Closes an online session.
function gj:closeSession()
	assertSession(self)

	return getSuccess(request.sessions.close({
		user = self
	}))
end

-- Fetches a single trophy by ID
function gj:fetchTrophy(id)
	assertSession(self)

	local trophies = validateTable(request.trophies({
		user = self,
		trophy_id = id
	}).trophies)

	return trophies and trophies[1] or nil
end

-- Fetches trophies.
-- No arg = All trophies
-- true/false = By achieved status
-- table = Trophies with ids
function gj:fetchTrophies(trophy)
	assertSession(self)

	if type(trophy) == "table" then
		return validateTable(request.trophies({
			user = self,
			trophy_id = trophy
		}).trophies)
	else
		return validateTable(request.trophies({
			user = self,
			achieved = trophy
		}).trophies)
	end
end

-- Sets a trophy as achieved
function gj:giveTrophy(id)
	assertSession(self)

	return getSuccess(request.trophies.add_achieved({
		user = self,
		trophy_id = id
	}))
end

-- Fetches scores
-- If called from a session object via ':' syntax, only returns sessions for that user
function gj:fetchScores(tableId, limit)
	if not isSession(self) then
		self, tableId, limit = nil, self, tableId
	end

	return validateTable(request.scores({
		user = self,
		table_id = tableId,
		limti = limit
	}).scores)
end

-- Adds a score.
-- Either as displayed on a session or
-- gj.addScore(guest_name, score, sort, [tableId, extraData])
function gj:addScore(score, sort, tableId, extraData)
	local guest
	if not isSession(self) then
		guest, self = self, nil
	end

	return getSuccess(request.scores.add({
		user = self,
		guest = guest,
		score = score,
		sort = sort,
		table_id = tableId,
		extra_data = extraData
	}))
end

-- Returns a list of score tables
function gj.fetchScoreTables()
	return validateTable(request.scores.tables({}).tables)
end

-- Gets data from the storage.
-- If called from a session, user keys, otherwise global ones
function gj:getData(key)
	if not isSession(self) then
		self, key = nil, self
	end

	local response = request.data_store({
		user = self,
		key = key
	})

	return response.data
end

-- Sets data
-- Uses POST requests when data size is above 255 bytes
function gj:setData(key, data)
	if not isSession(self) then
		self, key, data = nil, self, key
	end

	local largeData = #data > 255 and "data="..escapeHttp(data) or nil
	if largeData ~= nil then data = nil end

	return getSuccess(request.data_store.set({
		user = self,
		key = key,
		data = data
	}, largeData))
end

-- Updates data (arithmetic)
function gj:updateData(key, operation, value)
	if not isSession(self) then
		self, key, operation, value = nil, self, key, operation
	end

	local response = request.data_store.set({
		user = self,
		key = key,
		operation = operation,
		value = value
	})

	return response.data
end

-- Removes data from the storage.
function gj:removeData(key)
	if not isSession(self) then
		self, key = nil, self
	end

	return getSuccess(request.data_store.remove({
		user = self,
		key = key
	}))
end

-- Fetches all available data keys
function gj:fetchKeys()
	if not isSession(self) then self = nil end

	local keys = validateTable(request.data_store.get_keys({
		user = self
	}).keys)

	if keys then
		local t = {}
		for i,v in ipairs(keys) do
			t[i] = v.key
		end
		return t
	end
end

-- Make a raw request to the API using the information given to gj.init
gj.request = request

gj.__index = gj

return gj
