--[[
Hooks several objects for quick access via require
]]
local currentModule = (...):find("%.") and (...):gsub("%.[^%.]+$", "%.") or ""

-- Keys: require-parameter
-- Right: relative path
local hooks = {
	["Heartbeat::ECS"]                       = "ECS",
	["Heartbeat::ECS::Component"]            = "ECS.Component",
	["Heartbeat::ECS::ComponentStorage"]     = "ECS.ComponentStorage",
	["Heartbeat::ECS::Entity"]               = "ECS.Entity",
	["Heartbeat::ECS::EntityStorage"]        = "ECS.EntityStorage",
	["Heartbeat::ECS::Object"]               = "ECS.Object",
	["Heartbeat::ECS::Transform"]            = "ECS.Transform",
	["Heartbeat::GameState"]                 = "GameState",
	["Heartbeat::GameState::Collision"]      = "GameState.Collision",
	["Heartbeat::SubState"]                  = "GameState.SubState",
	["Heartbeat::GameState::Transformation"] = "GameState.Transformation",
	["Heartbeat::lovef"]                     = "lovef",
	["Heartbeat::lovef::graphics"]           = "lovef.graphics",
	["Heartbeat::lovef::physics"]            = "lovef.physics",
	["Heartbeat::libs"]                      = "libs",
	["Heartbeat::BehaviorTree"]              = "libs.BehaviorTree",
	["Heartbeat::BehaviorTree::Node"]        = "libs.BehaviorTree.Node",
	["Heartbeat::BehaviorTree::Task"]        = "libs.BehaviorTree.Task",
	["Heartbeat::BehaviorTree::Selector"]    = "libs.BehaviorTree.Selector",
	["Heartbeat::BehaviorTree::Sequence"]    = "libs.BehaviorTree.Sequence",
	["Heartbeat::BehaviorTree::Parallel"]    = "libs.BehaviorTree.Parallel",
	["Heartbeat::BehaviorTree::Decorator"]   = "libs.BehaviorTree.Decorator",
	["Heartbeat::input"]                     = "libs.input",
	["Heartbeat::StateMachine"]              = "libs.StateMachine",
	["Heartbeat::StateMachine::State"]       = "libs.StateMachine.State",
	["Heartbeat::StateMachine::Transition"]  = "libs.StateMachine.Transition",
	["Heartbeat::Vector2"]                   = "libs.vectors.Vector2",
	["Heartbeat::Vector3"]                   = "libs.vectors.Vector3",
	["Heartbeat::Vector4"]                   = "libs.vectors.Vector4",
	["Heartbeat::cdata"]                     = "libs.cdata",
	["Heartbeat::Color"]                     = "libs.Color",
	["Heartbeat::complex"]                   = "libs.Complex",
	["Heartbeat::Coroutine"]                 = "libs.Coroutine",
	["Heartbeat::EventStore"]                = "libs.EventStore",
	["Heartbeat::Handler"]                   = "libs.Handler",
	["Heartbeat::Material"]                  = "libs.Material",
	["Heartbeat::mathf"]                     = "libs.mathf",
	["Heartbeat::null"]                      = "libs.null",
	["Heartbeat::RequireTable"]              = "libs.RequireTable",
	["Heartbeat::Timer"]                     = "libs.Timer",
	["Heartbeat::Try"]                       = "libs.Try",
	["Heartbeat::components"]                = "components",
	["Heartbeat::entities"]                  = "entities",
	["Heartbeat::class"]                     = "class",
	["Heartbeat::heartbeat"]                 = "Heartbeat",
	["Heartbeat::Initializer"]               = "Initializer",
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
