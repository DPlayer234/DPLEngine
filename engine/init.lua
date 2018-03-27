--[[
Quick loading the engine itself
]]
local currentModule = miscMod.getModule(..., true)

-- Hooking require
require(currentModule .. ".preload")

return require(currentModule .. ".engine")
