--[[
Button, which triggers events upon clicking it
]]
local Vector2 = require "Heartbeat.Vector2"
local EventStore = require "Heartbeat.EventStore"

local Button = class("Button", require("Heartbeat.entities").UiElement)

-- Creates a new button
function Button:new()
	self:UiElement()
	self.onClick = EventStore { type = "handler" }
end

function Button:onUp()
	return self:onClick()
end

return Button
