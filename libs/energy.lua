--[[
Easily get, store and retrieve "energy" of music
]]
local love = love
local min, max, floor = math.min, math.max, math.floor
local char, byte = string.char, string.byte
local concat = table.concat

local rate = 60 -- Decides how many averages per second are generated/expected.
local energy = {}

function energy.parse(path, samples)
	local sound = love.sound.newSoundData(path)

	local data = {}

	local channels = sound:getChannels()
	local stepSize = sound:getSampleRate() * channels / rate
	local maxSample = sound:getSampleCount() * channels - 1

	for i=0, maxSample, stepSize do
		local s = 0
		for p = max(0, i), min(i + samples * channels - 1, maxSample) do
			local t = sound:getSample(p)
			s = s + t * t
		end
		data[#data+1] = s / (samples * channels)
	end

	return data
end

function energy.write(from, to, samples)
	local data = energy.parse(from, samples)
	local chars = {}
	for i=1, #data do
		local value = data[i] * 65535
		chars[i*2-1] = char(floor(value / 255))
		chars[i * 2] = char(floor(value % 255))
	end
	return love.filesystem.write(to, concat(chars))
end

function energy.read(from)
	local rawData = love.filesystem.read(from)
	local data = {}
	for i=1, #rawData/2 do
		local l, u = byte(rawData, i*2-1, i*2)
		data[i] = (l * 255 + u) / 65535
	end
	return data
end

function energy.readOrParse(file)
	if love.filesystem.isFile(file..".energy") then
		return energy.read(file..".energy")
	else
		return energy.parse(file, 2048)
	end
end

function energy.getAt(data, t)
	-- t in seconds.
	local p = t * rate
	local n = p % 1
	return (data[ floor(p + 1) ] or 0) * (1-n) + (data[ floor(p + 2) ] or 0) * n
end

return energy
