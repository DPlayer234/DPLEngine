--[[
Hooks several objects for quick access via require
]]
local currentModule = miscMod.getModule(..., false)

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["Engine.ECS"]           = ".ecs",
	["Engine.ECS.Entity"]    = ".ecs.entity",
	["Engine.ECS.Component"] = ".ecs.component",
	["Engine.Vector2"]       = ".libs.vector2",
	["Engine.Transform"]     = ".libs.transform",
	["Engine.GameState"]     = ".game_state",
	["Engine"]               = ".engine"
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
