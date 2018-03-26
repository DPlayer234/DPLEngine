--[[
Library for sprite-sheet animations
]]
-- Uh, too long of a list of functions... Just read the code and try to get it.
-- Dependencies:
local floor, max = math.floor, math.max
local tostring, tonumber, type, ipairs, assert = tostring, tonumber, type, ipairs, assert
local setmetatable = setmetatable
local newQuad, draw = love.graphics.newQuad, love.graphics.draw

-- Module:
local anim2 = {}

--[==[
Regular Animation Header (Single Simultaneous Animation):
]==]
local header = {}
header.__index = header

function header:reg(id, tx, ty, l, sp, loop, dx, dy)
	if dx == nil then dx = 1 end
	if dy == nil then dy = 0 end

	local fquads = {}
	for i=0, l-1 do
		fquads[i] = self:getQuad(tx, ty)

		tx = tx + dx
		ty = ty + dy
	end

	self:addAnimation(id, fquads, sp, loop)

	return self
end

function header:spc(id, all, sp, loop)
	local fquads = {}
	for i=0, floor(#all/2)-1 do
		fquads[i] = self:getQuad(all[i*2+1], all[i*2+2])
	end

	self:addAnimation(id, fquads, sp, loop)

	return self
end

function header:addAnimation(id, fquads, sp, loop)
	assert(id ~= nil, "Animation ID may not be nil!")

	local lp
	if type(loop) == "number" then
		lp = (loop - 1) / sp
		loop = true
	end
	local l = #fquads + 1

	local new = {
		s = sp, l = l, r = loop, p = lp,
		f = fquads
	}

	self.anims[id] = new
end

function header:trs(from, to, id)
	if not self.trans[from] then self.trans[from] = {} end
	self.trans[from][to] = id

	return self
end

function header:copy(orig, new)
	self.anims[new] = self.anims[orig]

	return self
end

function header:getQuad(tx, ty)
	local index = ("%d,%d"):format(tx, ty)
	if not self.sheet[index] then
		self.sheet[index] = newQuad(
			(tx-1)*(self.tx + self.spacing - (tx <= 0 and self.spacing or 0)),
			(ty-1)*(self.ty + self.spacing - (ty <= 0 and self.spacing or 0)),
			self.tx, self.ty, self.texture:getDimensions()
		)
	end
	return self.sheet[index]
end

function header:setQuad(tx, ty, w, h)
	local index = ("%d,%d"):format(tx, ty)

	local x, y, w, h =
		(tx-1)*(self.tx + self.spacing - (tx <= 0 and self.spacing or 0)),
		(ty-1)*(self.ty + self.spacing - (ty <= 0 and self.spacing or 0)),
		w * self.tx, h * self.ty

	if not self.sheet[index] then
		self.sheet[index] = newQuad(x, y, w, h, self.texture:getDimensions())
	else
		self.sheet[index]:setViewport(x, y, w, h)
	end

	return self
end

function header:set(next)
	if self.anim ~= next and (self.next == false or self.next ~= next) then
		local transit = self.trans[self.anim]
		local transTo = transit and transit[next]
		if transTo then
			self.anim = transTo
			self.next = next
		else
			self.anim = next
			self.next = false
		end
		self.time = 0
		self.loops = 0
	end

	return self
end

function header:reset()
	self.time = 0
	self.loops = 0
	return self
end

function header:update(dt)
	local anim = self.anims[self.anim]
	if anim then
		self.time = self.time + dt
		local f = floor(self.time * anim.s)

		if f > anim.l - 1 then
			if anim.r then
				self.time = self.time % (anim.l / anim.s)
				if anim.p then self.time = self.time + anim.p end
				f = floor(self.time * anim.s)
				self.loops = self.loops + 1
			else
				if self.next then
					self.anim = self.next
					self.next = false
					local overtime = self.time % (anim.l / anim.s)
					self.time = 0
					return self:update(overtime)
				else
					if anim.f[anim.l - 1] then
						self.frame = anim.f[anim.l - 1]
					end
					return true
				end
			end
		elseif f < 0 then
			if anim.r then
				self.time = (anim.l / anim.s) + self.time
				f = floor(self.time * anim.s)
				self.loops = self.loops - 1
			else
				if anim.f[0] then
					self.frame = anim.f[0]
				end
				return false
			end
		end

		if anim.f[f] then
			self.frame = anim.f[f]
		end
		return false
	else
		return true
	end
end

function header:draw(x, y, r, sx, sy, ox, oy, kx, ky)
	draw(self.texture, self.frame, x, y, r, sx, sy, ox, oy, kx, ky)
end

function header:getTexture()
	return self.texture
end

function header:setTexture(tex)
	self.texture = anim2.setTexProp(tex, self.arg)
end

function header:__tostring()
	if self.__address then
		return ("AnimHeader: 0x%x"):format(self.__address)
	else
		return "AnimHeader: nil"
	end
end

function header:clone()
	-- All cloned headers and the original are interlinked!
	-- Animations and the Sheet will be shared, no matter what!
	local new = {
		texture = self.texture, tx = self.tx, ty = self.ty, arg = self.arg,
		anims = self.anims, trans = self.trans, sheet = self.sheet, spacing = self.spacing,
		anim = nil, time = 0, loops = 0, next = false
	}
	new.__address = tonumber(tostring(new):match("^table: 0x([0-9a-f]*)$"), 16)

	setmetatable(new, header)
	new.frame = new:getQuad(1, 1)

	return new
end

-- Constructor:
function anim2.newHeader(texture, tx, ty, arg)
	local new = {
		texture = texture, tx = tx, ty = ty, arg = arg,
		anims = {}, trans = {}, sheet = {}, spacing = 0,
		anim = nil, time = 0, loops = 0, next = false
	}
	new.__address = tonumber(tostring(new):match("^table: 0x([0-9a-f]*)$"), 16)

	if arg then
		if arg.spacing then
			new.spacing = arg.spacing
			new.max = floor((texture:getWidth()+new.spacing)/(tx+new.spacing))
		end

		anim2.setTexProp(texture, arg)
	end

	setmetatable(new, header)
	new.frame = new:getQuad(1, 1)

	return new
end

--[==[
Multi-Animation Header (Multiple Simultaneous Animations):
Useful for animated tile sets.
]==]
local mheader = {}
mheader.__index = mheader

function mheader:reg(tx, ty, l, sp, dx, dy)
	if dx == nil then dx = 1 end
	if dy == nil then dy = 0 end

	local fquads = {}
	for i=0, l-1 do
		fquads[i] = self:getQuad(tx, ty)

		tx = tx + dx
		ty = ty + dy
	end

	return self:addAnimation(fquads, sp)
end

function mheader:spc(all, sp)
	local fquads = {}
	for i=0, floor(#all/2)-1 do
		fquads[i] = self:getQuad(all[i*2+1], all[i*2+2])
	end

	return self:addAnimation(fquads, sp)
end

function mheader:addAnimation(fquads, sp)
	local l = #fquads + 1

	local new = {
		s = sp, l = l,
		f = fquads, t = 0
	}

	new.quad = new.f[1]
	self.anims[#self.anims+1] = new

	return new
end

mheader.getQuad = header.getQuad
mheader.setQuad = header.setQuad

function mheader:update(dt)
	for i,anim in ipairs(self.anims) do
		anim.t = anim.t + dt
		local f = floor(anim.t * anim.s)

		if f > anim.l - 1 or f < 0 then
			anim.t = anim.t % (anim.l / anim.s)
			f = floor(anim.t * anim.s)
		end

		if anim.f[f] then
			anim.quad = anim.f[f]
		end
	end
end

mheader.getTexture = header.getTexture
mheader.setTexture = header.setTexture

function mheader:__tostring()
	if self.__address then
		return ("MultiHeader: 0x%x"):format(self.__address)
	else
		return "MultiHeader: nil"
	end
end

-- Constructor:
function anim2.newMultiHeader(texture, tx, ty, arg)
	local max = floor(texture:getWidth()/tx)

	local new = {
		texture = texture, tx = tx, ty = ty, max = max, arg = arg,
		anims = {}, sheet = {}, spacing = 0,
	}
	new.__address = tonumber(tostring(new):match("^table: 0x([0-9a-f]*)$"), 16)

	if arg then
		if arg.spacing then
			new.spacing = arg.spacing
			new.max = floor((texture:getWidth()+new.spacing)/(tx+new.spacing))
		end

		anim2.setTexProp(texture, arg)
	end

	setmetatable(new, mheader)

	return new
end

-- Adjusts the texture properties to match the args
function anim2.setTexProp(texture, arg)
	if arg then
		if arg.mirror then
			texture:setWrap("mirroredrepeat", "mirroredrepeat")
		end
	end

	return texture
end

return anim2
