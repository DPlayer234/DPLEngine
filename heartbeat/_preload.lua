--[[
Hooks several objects for quick access via require
]]
local currentModule = (...):gsub("%.[^%.]+$", "")

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["Heartbeat.ECS"]                      = ".ecs",
	["Heartbeat.ECS.ComponentStorage"]     = ".ecs.component_storage",
	["Heartbeat.ECS.Component"]            = ".ecs.component",
	["Heartbeat.ECS.EntityStorage"]        = ".ecs.entity_storage",
	["Heartbeat.ECS.Entity"]               = ".ecs.entity",
	["Heartbeat.ECS.Object"]               = ".ecs.object",
	["Heartbeat.ECS.Transform"]            = ".ecs.transform",
	["Heartbeat.GameState"]                = ".game_state",
	["Heartbeat.GameState.Collision"]      = ".game_state.collision",
	["Heartbeat.GameState.Transformation"] = ".game_state.transformation",
	["Heartbeat.input"]                    = ".libs.input",
	["Heartbeat.class"]                    = ".libs.class",
	["Heartbeat.Color"]                    = ".libs.Color",
	["Heartbeat.complex"]                  = ".libs.complex",
	["Heartbeat.EventStore"]               = ".libs.event_store",
	["Heartbeat.Material"]                 = ".libs.material",
	["Heartbeat.mathf"]                    = ".libs.mathf",
	["Heartbeat.Timer"]                    = ".libs.timer",
	["Heartbeat.Vector2"]                  = ".libs.vector2",
	["Heartbeat.Vector3"]                  = ".libs.vector3",
	["Heartbeat.Vector4"]                  = ".libs.vector4",
	["Heartbeat.Initializer"]              = ".initializer",
	["Heartbeat.components"]               = ".components",
	["Heartbeat.entities"]                 = ".entities",
	["Heartbeat"]                          = ".heartbeat"
}

-- Hooking into package.preload
local require = require

local function hook(to, from)
	package.preload[to] = function()
		return require(from)
	end
end

hook("Heartbeat._preload", ...)

for to, from in pairs(hooks) do
	hook(to, currentModule .. from)
end

-- Return the hooking function
return hook
