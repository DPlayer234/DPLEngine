--[[
Entity Transform
]]
local currentModule = miscMod.getModule(..., false)
local math = math

local TYPE_NAME = "Transform" --#const

local Vector2 = require(currentModule .. ".vector2")

-- Explicit methods
local methods = {
	-- Applies the velocity given the time passed
	applyVelocity = function(self, dt)
		self.position = self.position + self.velocity * dt
		self.angle = self.angle + self.angularVelocity * dt
	end,
	-- Flips the scaling horizontally
	flipHorizontal = function(self)
		self.scale = Vector2(-self.scale.x, self.scale.y)
	end,
	-- Flips the scaling vertically
	flipVertical = function(self)
		self.scale = Vector2(self.scale.x, -self.scale.y)
	end,
	-- Hook
	hookBody = function(self, body)
		if self:isHookedToBody() then error("Transform is already hooked to a Body!") end

		rawset(self, "position", nil)
		rawset(self, "velocity", nil)
		rawset(self, "angle", nil)
		rawset(self, "angularVelocity", nil)

		self._body = body
	end,
	unhookBody = function(self)
		if not self:isHookedToBody() then error("Transform isn't hooked to a Body!") end

		rawset(self, "position", self.position)
		rawset(self, "velocity", self.velocity)
		rawset(self, "angle", self.angle)
		rawset(self, "angularVelocity", self.angularVelocity)

		self._body = nil
	end,
	isHookedToBody = function(self)
		return self._hook and true
	end,
	-- Type
	type = function() return TYPE_NAME end,
	typeOf = function(self, name) return name == TYPE_NAME end
}

-- Value getter
local getter = {
	position = function(self)
		return Vector2(self._body:getPosition())
	end,
	velocity = function(self)
		return Vector2(self._body:getLinearVelocity())
	end,
	angle = function(self)
		return self._body:getAngle()
	end,
	angularVelocity = function(self)
		return self._body:getAngularVelocity()
	end,
}

-- Value setter
local setter = {
	position = function(self, value)
		return self._body:setPosition(value:unpack())
	end,
	velocity = function(self, value)
		return self._body:setLinearVelocity(value:unpack())
	end,
	angle = function(self, value)
		return self._body:setAngle(value)
	end,
	angularVelocity = function(self, value)
		return self._body:setAngularVelocity(value)
	end,
}

-- Metatable, including operators
local meta = {
	-- Nicer string format
	__tostring = function(self)
		return ("Transform: Pos. %.3f, %.3f"):format(self.position:unpack())
	end,
	__index = function(self, k)
		if getter[k] then
			return getter[k](self)
		end
		return methods[k]
	end,
	__newindex = function(self, k, v)
		if setter[k] then
			return setter[k](self, v)
		end
		return rawset(self, k, v)
	end
}

-- Creates a new transform object
local function Transform()
	return setmetatable({
		position = Vector2(),
		velocity = Vector2(),
		angle = 0,
		angularVelocity = 0,
		scale = Vector2(1, 1)
	}, meta)
end

return Transform
