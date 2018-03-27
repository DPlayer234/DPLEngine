--[[
Entity Transform
]]
local currentModule = miscMod.getModule(..., false)
local math = math

local Vector2  = require(currentModule .. ".vector2")

-- Explicit methods
local methods = {
	-- Applies the velocity given the time passed
	applyVelocity = function(self, dt)
		self.position = self.position + self.velocity * dt
	end,
	-- Hook
	hook = function(self, hook)
		self._hook = hook
	end
}

-- Value getter
local getter = {
	position = function(self)
		if self._hook then
			return Vector2(self._hook:getPosition())
		else
			return self._position
		end
	end,
	rotation = function(self)
		if self._hook then
			return self._hook:getAngle()
		else
			return self._rotation
		end
	end
}

-- Value setter
local setter = {
	position = function(self, value)
		if self._hook then
			self._hook:setPosition(value:unpack())
		else
			self._position = value
		end
	end,
	rotation = function(self, value)
		if self._hook then
			self._hook:setAngle(value)
		else
			self._rotation = value
		end
	end
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
local function Transform(position, rotation, scale)
	return setmetatable({
		_position = position or Vector2(),
		_rotation = rotation or 0,
		scale = scale or Vector2(1, 1)
	}, meta)
end

return Transform
