--[[
Convenient access to component classes
]]
local RequireTable = require "Heartbeat::RequireTable"
return RequireTable((...):gsub("%.init$", ""))
