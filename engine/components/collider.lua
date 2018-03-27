--[[
A Collider for rigidbodies
]]
local physics = require "love.physics"

local Vector2 = Engine.Vector2
local Ridigbody

local Collider = class("Collider", Engine.ECS.Component)

-- Creates a new Collider
function Collider:new(shape, density)
	self:Component()

	self._shape = shape
	self._density = density
end

function Collider:initialize()
	self._rigidbody = self.entity:getComponent(Ridigbody)
	self.fixture = physics.newFixture(self._rigidbody.body, self._shape, self._density or 1)
end

Engine.callAfterInit(function()
	Ridigbody = Engine:getComponentType "Rigidbody"
end)

return Collider
