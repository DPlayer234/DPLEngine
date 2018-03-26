--[[
Rewritten Sound Wrapper for easier handling of Sound Effects (SFX) and their position
as well as the handling of Music and loading those.
]]
local class = require "libs.class"

local audio, thread = love.audio, love.thread
local pairs, rawget, type = pairs, rawget, type
local remove = table.remove

local sounds2 = {}

local weakTable = { __mode = "kv" }
local allSFX = setmetatable({}, weakTable)

local sfxVolume = 1
local musicVolume = 1
local currentMusic, currentMusicSource, nextMusic
local fadingMusic = {}

local areaScale = 1
local listenerX, listenerY = 0, 0

local musicLoader

-- Internal. Setting a source's position
local function setPosition(source, x, y)
	return source:setPosition(x * areaScale, y * areaScale)
end

-- Internal. Setting a source's volume as SFX
local function setSFXVolume(source, volume)
	return source:setVolume(volume * sfxVolume)
end

-- Internal. Setting a source's volume as Music
local function setMusicVolume(source, volume)
	return source:setVolume(volume * musicVolume)
end

local SFX = {}
do
	-- Initializes a new instance of the SFX class
	function SFX:new(path, volume, meta)
		self.source = audio.newSource(path, "static")
		self.source:setVolume(volume)
		self.volume = volume

		self.nextX = false
		self.nextY = false
		self.nextVolume = false
		self.nextEffect = false

		self.copies = {}

		if meta ~= nil then
			for k, v in pairs(meta) do
				local selfV = rawget(self, k)
				if selfV == nil or type(selfV) == type(v) then
					self[k] = v
				end
			end
		end

		allSFX[#allSFX+1] = self
	end

	-- Plays the sound
	function SFX:play()
		local source
		for i=1, #self.copies do
			local s = self.copies[i]
			if s:isStopped() then
				source = s
				break
			end
		end

		if source == nil then
			source = self.source:clone()
			self.copies[#self.copies + 1] = source
		end

		if self.nextX and self.nextY then
			setPosition(source, self.nextX, self.nextY)
			self.nextX, self.nextY = false, false
		else
			setPosition(source, listenerX, listenerY)
		end

		if self.nextVolume then
			setSFXVolume(source, self.volume * self.nextVolume)
			self.nextVolume = false
		else
			setSFXVolume(source, self.volume)
		end

		if self.nextEffect then
			source:setEffect(self.nextEffect)
			self.nextEffect = false
		end

		return source:play()
	end

	-- Stops all instances of this SFX
	function SFX:stop()
		for i=1, #self.copies do
			self.copies[i]:stop()
		end
	end

	-- Sets the next position the SFX is played at and returns it
	function SFX:at(x, y)
		self.nextX = x
		self.nextY = y

		return self
	end

	-- Sets the next volume the SFX is played at and returns it
	function SFX:vol(volume)
		self.nextVolume = volume

		return self
	end

	-- Sets the next effect the SFX is played with and returns it
	function SFX:with(effect)
		self.nextEffect = effect

		return self
	end

	-- Sets the SFX volume
	function SFX:setVolume(newVolume)
		self.volume = newVolume
		return setSFXVolume(self.source, newVolume)
	end

	-- Gets the SFX volume
	function SFX:getVolume()
		return self.volume
	end

	SFX = class("SFX", SFX)
end

local RandomSFX = {}
do
	local random = love.math.newRandomGenerator(love.math.random(0, 0xffffffff), love.math.random(0, 0xffffffff))

	-- A list of several SFXs
	function RandomSFX:new(...)
		self.sounds = {...}

		self.nextX = false
		self.nextY = false
		self.nextVolume = false
		self.nextEffect = false
	end

	-- Plays a random sound
	function RandomSFX:play()
		local sound = self.sounds[random:random(1, #self.sounds)]

		sound.nextX, sound.nextY = self.nextX, self.nextY
		sound.nextVolume = self.nextVolume
		sound.nextEffect = self.nextEffect

		return sound:play()
	end

	-- Stops all instances of this SFX
	function RandomSFX:stop()
		for i=1, #self.sounds do
			self.sounds[i]:stop()
		end
	end

	-- Sets the next position the SFX is played at and returns it
	function RandomSFX:at(x, y)
		self.nextX = x
		self.nextY = y

		return self
	end

	-- Sets the next volume the SFX is played at and returns it
	function RandomSFX:vol(volume)
		self.nextVolume = volume

		return self
	end

	-- Sets the next effect the SFX is played with and returns it
	function RandomSFX:with(effect)
		self.nextEffect = effect

		return self
	end

	RandomSFX.setVolume = class.null
	RandomSFX.getVolume = class.null

	RandomSFX = class("RandomSFX", RandomSFX, SFX)
end

local NoSFX = {}
do
	-- No SFX
	function NoSFX:new() end
	function NoSFX:play() end
	function NoSFX:stop()  end
	function NoSFX:at() return self end
	function NoSFX:vol() return self end
	function NoSFX:with() return self end

	NoSFX.setVolume = class.null
	NoSFX.getVolume = class.null

	NoSFX = class("NoSFX", NoSFX, SFX)
end

local Music = {}
do
	-- Initializes a new instance of the Music class
	function Music:new(path, volume, meta)
		self.path = path
		self.volume = volume

		self.seekPoint = false

		if meta ~= nil then
			for k, v in pairs(meta) do
				local selfV = rawget(self, k)
				if selfV == nil or type(selfV) == type(v) then
					self[k] = v
				end
			end
		end
	end

	-- Plays the music and stops all others
	-- Music is loaded in a separate thread
	function Music:play()
		nextMusic = self

		return musicLoader.toThread:push(self.path)
	end

	-- Stops this music
	function Music:stop()
		if self:isCurrentMusic() then
			return sounds2.stopMusic()
		end
	end

	-- Sets the Music volume
	function Music:setVolume(newVolume)
		self.volume = newVolume
		if self:isCurrentMusic() then
			return setMusicVolume(curretMusicSource, newVolume)
		end
	end

	-- Gets the Music volume
	function Music:getVolume()
		return self.volume
	end

	-- Gets how far the music has progressed
	function Music:tell(unit)
		if self:isCurrentMusic() then
			return currentMusicSource:tell(unit)
		else
			return 0
		end
	end

	-- Jumps to a certain point in the music
	function Music:seek(offset, unit)
		if self:isCurrentMusic() then
			return currentMusicSource:seek(offset, unit)
		else
			self.seekPoint = {
				offset = offset,
				unity = unit
			}
		end
	end

	-- Whether this is the currently playing music
	function Music:isCurrentMusic()
		return self == currentMusic
	end

	-- Whether it is already playing
	function Music:isPlaying()
		return self:isCurrentMusic() and currentMusicSource:isPlaying()
	end

	Music = class("Music", Music)
end

sounds2.SFX = SFX
sounds2.RandomSFX = RandomSFX
sounds2.NoSFX = NoSFX
sounds2.Music = Music

-- Alias for sounds2.SFX(...)
function sounds2.newSFX(...)
	return SFX(...)
end

-- Alias for sounds2.RandomSFX(...)
function sounds2.newRandomSFX(...)
	return RandomSFX(...)
end

-- Alias for sounds2.NoSFX(...)
function sounds2.newNoSFX(...)
	return NoSFX(...)
end

-- Alias for sounds2.Music(...)
function sounds2.newMusic(...)
	return Music(...)
end

-- Sets the global SFX Volume multiplier
function sounds2.setSFXVolume(newVolume)
	sfxVolume = newVolume

	for k, sfx in pairs(allSFX) do
		local thisVolume = sfx.volume
		setSFXVolume(sfx.source, thisVolume)
		for i=1, #sfx.copies do
			setSFXVolume(sfx.copies[i], thisVolume)
		end
	end
end

-- Gets the global SFX Volume multiplier
function sounds2.getSFXVolume()
	return sfxVolume
end

-- Sets the global Music Volume multiplier
function sounds2.setMusicVolume(newVolume)
	musicVolume = newVolume

	if currentMusicSource ~= nil then
		return currentMusicSource:setVolume(newVolume * currentMusic.volume)
	end
end

-- Gets the global Music Volume multiplier
function sounds2.getMusicVolume()
	return musicVolume
end

-- Stops all SFX
function sounds2.stopSFX()
	for k, sfx in pairs(allSFX) do
		sfx:stop()
	end
end

-- Stops the current music
function sounds2.stopMusic()
	if currentMusicSource ~= nil then
		sounds2.fadeMusic()

		currentMusic = nil
		currentMusicSource = nil
	end
end

-- Starts fading out Music
function sounds2.fadeMusic()
	if currentMusicSource ~= nil then
		fadingMusic[#fadingMusic + 1] = {
			source = currentMusicSource,
			volume = currentMusic.volume,
			time = 1
		}
	end
end

-- Gets the currently playing music
function sounds2.getCurrentMusic()
	return currentMusic, currentMusicSource
end

-- Clears all SFX copies from memory
function sounds2.clearSFXCopies()
	for k, sfx in pairs(allSFX) do
		sfx.copies = {}
	end
end

-- Sets the position of the listener
function sounds2.setPosition(x, y)
	listenerX, listenerY = x, y
	return audio.setPosition(x * areaScale, y * areaScale, -1.4)
end

-- Gets the position of the listener
function sounds2.getPosition()
	return listenerX, listenerY
end

-- Sets the scale at which sound positions are scaled
function sounds2.setAreaScale(n)
	areaScale = 1 / n
end

-- Gets the area scale
function sounds2.getAreaScale()
	return 1 / areaScale
end

-- Fades out music and checks the secondary thread for loaded music sources
function sounds2.update(dt)
	-- Fade out
	for i=#fadingMusic, 1, -1 do
		local m = fadingMusic[i]

		m.time = m.time - dt
		if m.time < 0 then
			m.source:stop()
			m.source = nil
			remove(fadingMusic, i)
		else
			setMusicVolume(m.source, m.volume * m.time)
		end
	end

	-- Loop Music
	if currentMusic and currentMusic.loopStart and currentMusic.loopEnd and currentMusicSource:tell() > currentMusic.loopEnd then
		currentMusicSource:seek(currentMusic.loopStart + currentMusicSource:tell() - currentMusic.loopEnd)
	end

	-- Music loading
	local response
	while musicLoader.toMain:getCount() ~= 0 do
		response = musicLoader.toMain:pop()
	end
	if response ~= nil then
		sounds2.fadeMusic()

		-- False = Error, Otherwise a source
		if response then
			-- New Music!
			currentMusic = nextMusic

			currentMusicSource = response
			setMusicVolume(currentMusicSource, currentMusic.volume)

			if currentMusic.seekPoint then
				currentMusicSource:seek(currentMusic.seekPoint.offset, currentMusic.seekPoint.unit)
				currentMusic.seekPoint = false
			end

			currentMusicSource:play()
		end
	end
end

-- Setup loader thread
do
	local toMain = thread.newChannel()
	local toThread = thread.newChannel()

	-- I don't really like block-strings...
	-- Better than another file though
	local thread = thread.newThread [[
		local toMain, toThread = ...

		local pcall = pcall
		local sound = require "love.sound"
		local audio = require "love.audio"

		local function loop()
			local response = toThread:demand()
			while toThread:getCount() ~= 0 do
				response = toThread:pop()
			end

			local sourceOk, source = pcall(audio.newSource, response, "stream")
			if sourceOk then
				if toThread:getCount() ~= 0 then
					return loop()
				else
					if source:getChannels() == 1 then
						source:setRelative(true)
					end
					source:setLooping(true)

					return toMain:push(source)
				end
			else
				print("[Sounds2.MusicLoader]", source)
				return toMain:push(false)
			end
		end

		while true do
			loop()
			collectgarbage()
		end
	]]

	thread:start(toMain, toThread)

	musicLoader = {
		toMain = toMain,
		toThread = toThread,
		thread = thread
	}
end

return sounds2
