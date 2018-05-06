--[[
A Collider for rigidbodies (Fixture)
]]
local ffi = require "ffi"
local physics = require "love.physics"
local class = require "Heartbeat::class"
local Vector2 = require "Heartbeat::Vector2"

local Collider = class("Collider", require "Heartbeat::ECS::Component")

-- Creates a new Collider
--[[
> Collider("Rectangle", dimensions, [density])
> Collider("Rectangle", position, dimensions, [angle, density])
> Collider("Circle", radius, [density])
> Collider("Circle", position, radius, [density])
> Collider("Polygon", vertices, [density])
> Collider("Chain", loop, points, [density])
> Collider(<any>, shape, [density])
]]
function Collider:new(shapeType, a, b, c, d)
	self:Component()

	if shapeType == "Rectangle" then
		if Vector2.is(b) then
			self:_init(physics.newRectangleShape(a.x, a.y, b.x, b.y, c), d)
		else
			self:_init(physics.newRectangleShape(a.x, a.y), b)
		end
	elseif shapeType == "Circle" then
		if Vector2.is(a) then
			self:_init(physics.newCircleShape(a.x, a.y, b), c)
		else
			self:_init(physics.newCircleShape(a), b)
		end
	elseif shapeType == "Polygon" then
		if Vector2.is(a[1]) then
			a = self:_vectorToNumberList(a)
		end
		self:_init(physics.newPolygonShape(a), b)
	elseif shapeType == "Chain" then
		if Vector2.is(b[1]) then
			b = self:_vectorToNumberList(b)
		end
		self:_init(physics.newChainShape(a, b), c)
	else
		self:_init(a, b)
	end

	self._type = shapeType
end

function Collider:initialize()
	self._rigidbody = assert(self.entity:getComponent("Rigidbody"), "Colliders require a Rigidbody.")

	self._fixture = physics.newFixture(self._rigidbody:getLBody(), self._shape, self._density or 1)
	self._fixture:setUserData(self)

	self:setMaterial(self._rigidbody:getMaterial())
end

-- Returns the collider type
function Collider:getType()
	return self._type
end

-- Returns the rigidbody
function Collider:getRigidbody()
	return self._rigidbody
end

-- Returns the Löve fixture
function Collider:getLFixture()
	return self._fixture
end

-- Returns the Löve shape used to construct the fixture
function Collider:getLShape()
	return self._shape
end

-- Gets the Material of the collider
function Collider:getMaterial()
	return self._material:instantiate()
end

-- Sets the Material of the collider
function Collider:setMaterial(value)
	if not value:typeOf("Material") then error("Can only set Materials!") end
	self._material = value:instantiate()

	self:getLFixture():setFriction(value.friction)
	self:getLFixture():setRestitution(value.bounciness)
end

-- Gets this collider's sensor state
function Collider:isSensor()
	return self:getLFixture():isSensor()
end

-- Sets this collider's sensor state
function Collider:setSensor(value)
	return self:getLFixture():setSensor(value)
end

function Collider:onDestroy()
	if not self._rigidbody:isDestroyed() then
		self._fixture:destroy()
	end
end

-- Sets the data
function Collider:_init(shape, density)
	self._shape = shape
	self._density = density
end

-- Converts a list of Vector2s to numbers
function Collider:_vectorToNumberList(vpoints)
	local points = {}
	for i=1, #vpoints do
		points[i*2-1] = vpoints[i].x
		points[i * 2] = vpoints[i].y
	end
	return points
end

return Collider
