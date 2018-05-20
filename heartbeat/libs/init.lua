--[[
Loads all libs and returns them
]]
return {
	BehaviorTree = require "Heartbeat::BehaviorTree",
	input        = require "Heartbeat::input",
	Vector2      = require "Heartbeat::Vector2",
	Vector3      = require "Heartbeat::Vector3",
	Vector4      = require "Heartbeat::Vector4",
	cdata        = require "Heartbeat::cdata",
	Color        = require "Heartbeat::Color",
	complex      = require "Heartbeat::complex",
	Coroutine    = require "Heartbeat::Coroutine",
	EventStore   = require "Heartbeat::EventStore",
	Handler      = require "Heartbeat::Handler",
	Material     = require "Heartbeat::Material",
	mathf        = require "Heartbeat::mathf",
	null         = require "Heartbeat::null",
	RequireTable = require "Heartbeat::RequireTable",
	Timer        = require "Heartbeat::Timer",
	Try          = require "Heartbeat::Try"
}
