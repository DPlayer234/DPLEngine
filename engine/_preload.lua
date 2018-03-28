--[[
Hooks several objects for quick access via require
]]
local currentModule = (...):gsub("%.[^%.]+$", "")

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["Engine.ECS"]                  = ".ecs",
	["Engine.ECS.ComponentStorage"] = ".ecs.component_storage",
	["Engine.ECS.Component"]        = ".ecs.component",
	["Engine.ECS.EntityStorage"]    = ".ecs.entity_storage",
	["Engine.ECS.Entity"]           = ".ecs.entity",
	["Engine.ECS.Object"]           = ".ecs.object",
	["Engine.Editor"]               = ".editor",
	["Engine.GameState"]            = ".game_state",
	["Engine.GameState.Collision"]  = ".game_state.collision",
	["Engine.input"]                = ".libs.input",
	["Engine.Mat3x3"]               = ".libs.mat3x3",
	["Engine.Material"]             = ".libs.material",
	["Engine.Transform"]            = ".libs.transform",
	["Engine.Transformation"]       = ".libs.transformation",
	["Engine.Vector2"]              = ".libs.vector2",
	["Engine.Initializer"]          = ".initializer",
	["Engine.components"]           = ".components",
	["Engine.entities"]             = ".entities",
	["Engine"]                      = ".engine"
}

-- Hooking into package.preload
local require = require

local function hook(to, from)
	package.preload[to] = function()
		return require(from)
	end
end

hook("Engine._preload", ...)

for to, from in pairs(hooks) do
	hook(to, currentModule .. from)
end

-- Return the hooking function
return hook
