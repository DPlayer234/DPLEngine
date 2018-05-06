--[[
Quick loading the engine itself
]]
local currentModule = (...):gsub("%.init$", "")

-- Hooking require
require(currentModule .. "._preload")

return require "Heartbeat::Heartbeat"
