--[[
Hooks several objects for quick access via require
]]
local currentModule = (...):gsub("%.[^%.]+$", "")

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["Heartbeat.ECS"]                      = ".ECS",
	["Heartbeat.ECS.Component"]            = ".ECS.Component",
	["Heartbeat.ECS.ComponentStorage"]     = ".ECS.ComponentStorage",
	["Heartbeat.ECS.Entity"]               = ".ECS.Entity",
	["Heartbeat.ECS.EntityStorage"]        = ".ECS.EntityStorage",
	["Heartbeat.ECS.Object"]               = ".ECS.Object",
	["Heartbeat.ECS.Transform"]            = ".ECS.Transform",
	["Heartbeat.GameState"]                = ".GameState",
	["Heartbeat.GameState.Collision"]      = ".GameState.Collision",
	["Heartbeat.SubState"]                 = ".GameState.SubState",
	["Heartbeat.GameState.Transformation"] = ".GameState.Transformation",
	["Heartbeat.input"]                    = ".libs.input",
	["Heartbeat.Vector2"]                  = ".libs.vector.Vector2",
	["Heartbeat.Vector3"]                  = ".libs.vector.Vector3",
	["Heartbeat.Vector4"]                  = ".libs.vector.Vector4",
	["Heartbeat.cdata"]                    = ".libs.cdata",
	["Heartbeat.class"]                    = ".libs.class",
	["Heartbeat.Color"]                    = ".libs.Color",
	["Heartbeat.complex"]                  = ".libs.Complex",
	["Heartbeat.Coroutine"]                = ".libs.Coroutine",
	["Heartbeat.EventStore"]               = ".libs.EventStore",
	["Heartbeat.Handler"]                  = ".libs.Handler",
	["Heartbeat.Material"]                 = ".libs.Material",
	["Heartbeat.mathf"]                    = ".libs.mathf",
	["Heartbeat.null"]                     = ".libs.null",
	["Heartbeat.RequireTable"]             = ".libs.RequireTable",
	["Heartbeat.Timer"]                    = ".libs.Timer",
	["Heartbeat.Initializer"]              = ".Initializer",
	["Heartbeat.components"]               = ".components",
	["Heartbeat.entities"]                 = ".entities",
	["Heartbeat"]                          = ".Heartbeat"
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
