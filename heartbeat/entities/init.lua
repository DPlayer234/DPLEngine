--[[
Convenient access to entity classes
]]
local RequireTable = require "Heartbeat.RequireTable"
return RequireTable((...):gsub("%.init$", ""))
