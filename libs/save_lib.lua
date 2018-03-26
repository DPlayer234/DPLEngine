--[[
Stores and loads data (Lua-tables) in a relatively human-unreadable format.
Also compresses and decompresses data if possible.

	success, error = saveLib.write(path, data)
	data, error = saveLib.read(path)

For the love of whatever, don't read this code.
]]
local love = love
local pairs,pcall,type,tostring,tonumber,assert = pairs,pcall,type,tostring,tonumber,assert
local format,char,byte = string.format,string.char,string.byte
local huge = math.huge

local saveLib = {}

saveLib._format = "zlib"

saveLib._write = love.filesystem.write
saveLib._read = love.filesystem.read

function saveLib._compress(d)
	local s,n = pcall(love.math and love.math.compress,d,saveLib._format)
	if s then
		return n:getString()
	else
		print("[SAVE]","Could not compress data")
		return d
	end
end

function saveLib._decompress(d)
	local s,n = pcall(love.math and love.math.decompress,d,saveLib._format)
	if s then
		return n
	else
		print("[SAVE]","Could not decompress data")
		return d
	end
end

local encodedata,writetable

function encodedata(v)
	local t = type(v)
	local d,dt
	if t == "table" then
	-- TABLES
		d = writetable(v)
		if d == nil then
			return nil
		else
			dt = "\000"
			local d2 = format("%x",#d)
			local dl = char(#d2)
			if byte(dl) == #d2 then
				return dt..dl..d2..d
			else
				return nil
			end
		end
	elseif t == "number" then
	-- NUMBERS
		if v == huge then
			d = "+!"
			dt = "\001"
		elseif v == -huge then
			d = "-!"
			dt = "\001"
		else
			local int = v%1 == 0
			local as = int and tostring(v) or format("%.14f",v):gsub("0*$","")
			local n = false
			if as:find("^%-") then
				n = true
				as = as:gsub("^%-","")
			end
			if not int then
				d = as
				dt = "\001"
			elseif as == "nan" then
				d = "nan"
				dt = "\001"
			else
				d = format("%s%x",n and "-" or "",v)
				dt = "\002"
			end
		end
	elseif t == "string" then
	-- STRINGS
		d = v
		dt = "\003"
	elseif t == "boolean" then
	-- BOOLEANS
		if v then
			d = "\001"
		else
			d = "\000"
		end
		dt = "\004"
	else
	-- INVALID
		d = "\000\255"..t
		dt = "\005"
		print("[SAVE][WRITE]","Invalid value "..tostring(v).." of type "..t)
	end
	local dl = char(#d)
	if byte(dl) == #d then
		return dt..dl..d
	else
		return nil
	end
end

function writetable(data)
	local out = ""
	for k,v in pairs(data) do
		local ks = encodedata(k)
		local vs = encodedata(v)
		if vs == nil or ks == nil then return nil end
		out = out .. ks .. vs
	end
	return out
end

function saveLib.write(path,data,use)
	local data,err = saveLib.encode(data,use)
	if data then
		return saveLib._write(path,data)
	else
		return data,err
	end
end

function saveLib.encode(data,use)
	use = use and use.."\0" or ""
	local suc,output = pcall(writetable,data)

	if suc and output then
		return saveLib._compress(use..output)
	else
		return nil,output or "Over-sized element! (>255 bytes)"
	end
end

local readtable
local typedecode = {
	["\000"] = "table",
	["\001"] = "double",
	["\002"] = "integer",
	["\003"] = "string",
	["\004"] = "boolean",
	["\005"] = "invalid",
}

function readtable(data)
	local out = {}
	local b,e = 0,0
	while true do
		local v = {}
		for i=1,2 do
			local e_ = e
			b,e = data:find("[%z\001\002\003\004\005]",e+1)
			if b and e then
				assert(b == e_+1,"Unused bytes?")
				local t = typedecode[data:sub(b,e)]

				local d
				if t == "table" then
					local dl = byte(data:sub(b+1,e+1))
					local d2 = tonumber(data:sub(e+2,e+1+dl),16)
					d = readtable(data:sub(e+2+dl,e+1+dl+d2))

					e = e+1+dl+d2
				else
					local dl = byte(data:sub(b+1,e+1))
					d = data:sub(e+2,e+1+dl)

					e = e+1+dl

					if t == "double" then
						if d == "+!" then
							d = huge
						elseif d == "-!" then
							d = -huge
						elseif d == "nan" then
							d = 0/0
						else
							d = tonumber(d)
						end
					elseif t == "integer" then
						if d:find("^%-") then
							d = -tonumber(d,16)
						else
							d = tonumber(d,16)
						end
					elseif t == "boolean" then
						if d == "\000" then
							d = false
						else
							d = true
						end
					elseif t == "invalid" then
						print("[SAVE][READ]","Invalid element loaded")
					end
				end
				if i == 1 then
					v.k = d
				else
					v.v = d
				end
			else
				assert(e_ == #data,"Final element not EOF")
				return out
			end
		end
		out[v.k] = v.v
	end
end

function saveLib.read(path,use)
	return saveLib.decode(saveLib._read(path),use)
end

function saveLib.decode(data,use)
	local input = saveLib._decompress(data)

	if use then
		use = use.."\0"
		if input:sub(1, #use) ~= use then
			return nil,"Data use does not match!"
		end
		input = input:sub(#use+1, #input)
	end
	local suc,output = pcall(readtable,input)

	if suc then
		return output
	else
		return nil,output
	end
end

return saveLib
