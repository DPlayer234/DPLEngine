--[[
Hooks several objects for quick access via require
]]
local currentModule = miscMod.getModule(..., false)

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["ECS"]       = ".ecs",
	["Entity"]    = ".ecs.entity",
	["Component"] = ".ecs.component",
	["Vector2"]   = ".libs.vector2",
	["Rotation"]  = ".libs.rotation",
	["Transform"] = ".libs.transform",
	["GameState"] = ".game_state",
	["Engine"]    = "",
	["Preload"]   = ".preload"
}

-- Hooking into package.preload
local require = require

local function hook(to, from)
	package.preload[to] = function()
		return require(from)
	end
end

for to, from in pairs(hooks) do
	hook(to, currentModule .. from)
end

-- Return the hooking function
return hook
