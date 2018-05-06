--[[
Requiring this file allows you to use complex numbers in Lua code (with LuaJIT) and returns
a table containing the methods (named 'complex' here).
LuaJIT allows the suffix 'i' to numbers (e.g. 3i) to indicate a purely imaginary number,
however, it does not provide operators in Lua to work with these by default. This library
adds the operators to the type and loads all other functions to be used as complex.<name>(z).
The real and imaginary components of a complex number can be accessed via z.real and z.imag.
]]
local ffi = require "ffi"
local C = ffi.C
local math, type = math, type

-- Load the complex methods
ffi.cdef [[
double creal(complex);
double cimag(complex);
double cabs(complex);
double carg(complex);
complex conj(complex);
double cproj(complex);
complex cexp(complex);
complex clog(complex);
complex cpow(complex, complex);
complex csqrt(complex);
complex csin(complex);
complex ccos(complex);
complex ctan(complex);
complex casin(complex);
complex cacos(complex);
complex catan(complex);
complex csinh(complex);
complex ccosh(complex);
complex ctanh(complex);
complex casinh(complex);
complex cacosh(complex);
complex catanh(complex);
]]

-- Get the C-type
local Complex = ffi.typeof("complex")

-- Wrap all methods
local complex
complex = {
	real  = function(z) return C.creal(z) end,
	imag  = function(z) return C.cimag(z) end,
	abs   = function(z) return C.cabs(z) end,
	arg   = function(z) return C.carg(z) end,
	conj  = function(z) return C.conj(z) end,
	proj  = function(z) return C.cproj(z) end,
	exp   = function(z) return C.cexp(z) end,
	log   = function(z) return C.clog(z) end,
	pow   = function(x, y) return C.cpow(x, y) end,
	sqrt  = function(z) return C.csqrt(z) end,
	sin   = function(z) return C.csin(z) end,
	cos   = function(z) return C.ccos(z) end,
	tan   = function(z) return C.ctan(z) end,
	asin  = function(z) return C.casin(z) end,
	acos  = function(z) return C.cacos(z) end,
	atan  = function(z) return C.catan(z) end,
	sinh  = function(z) return C.csinh(z) end,
	cosh  = function(z) return C.ccosh(z) end,
	tanh  = function(z) return C.ctanh(z) end,
	asinh = function(z) return C.casinh(z) end,
	acosh = function(z) return C.cacosh(z) end,
	atanh = function(z) return C.catanh(z) end,
	phaseAngle = function(z) return C.carg(z) end,
	conjugate = function(z) return C.conj(z) end,
	projection = function(z) return C.cproj(z) end,
	abssqr = function(z)
		if complex.is(z) then
			return z.real ^ 2 + z.imag ^ 2
		else
			return z * z
		end
	end,
	-- Check whether the value is a complex number
	is = function(value) return ffi.istype(Complex, value) end,

	-- Convert the given value (real and imaginary, the latter optional) into a complex
	-- number. Returns nil if this fails.
	tocomplex = function(a, b)
		if b == nil then
			if complex.is(a) then
				return a
			end

			a = tonumber(a)
			if a == nil then return end
			return Complex(a, 0)
		end

		a = tonumber(a)
		b = tonumber(b)
		if a == nil or b == nil then return end
		return Complex(a, b)
	end,

	-- Some constants
	i = Complex(0, 1),
	infinity = Complex(1/0, 1/0),
	positiveInfinity = Complex(1/0, 1/0),
	negativeInfinity = Complex(-1/0, -1/0),
	NaN = Complex(0/0, 0/0),
}

-- Indexer
local indexer = {
	real = complex.real,
	imag = complex.imag,
}

local samesigns = function(x, y)
	local xa, xb = x.real, x.imag
	local ya, yb = y.real, y.imag
	return
		(xa > 0 and ya > 0 or xa < 0 and ya < 0 or xa == 0 or ya == 0) and
		(xb > 0 and yb > 0 or xb < 0 and yb < 0 or xb == 0 or yb == 0)
end

local submod = function(m, n, divround)
	local r = m - divround * n
	if samesigns(r, n) then return r end
end

local meta = {
	-- Addition
	__add = function(x, y)
		if type(x) == "number" then
			return Complex(x + y.real, y.imag)
		elseif type(y) == "number" then
			return Complex(x.real + y, x.imag)
		else
			return Complex(x.real + y.real, x.imag + y.imag)
		end
	end,
	-- Subtraction
	__sub = function(x, y)
		if type(x) == "number" then
			return Complex(x - y.real, -y.imag)
		elseif type(y) == "number" then
			return Complex(x.real - y, x.imag)
		else
			return Complex(x.real - y.real, x.imag - y.imag)
		end
	end,
	-- Multiplication
	__mul = function(x, y)
		if type(x) == "number" then
			return Complex(x * y.real, x * y.imag)
		elseif type(y) == "number" then
			return Complex(x.real * y, x.imag * y)
		else
			return Complex(
				x.real * y.real - x.imag * y.imag,
				x.real * y.imag + x.imag * y.real)
		end
	end,
	-- Division
	__div = function(x, y)
		if type(y) == "number" then
			return Complex(x.real / y, x.imag / y)
		else
			return (x * complex.conj(y)) / complex.abssqr(y)
		end
	end,
	-- Power via C implementaion
	__pow = function(x, y)
		return complex.pow(x, y)
	end,
	-- Modulo; Trust me, it somehow makes sense
	__mod = function(m, n)
		local div = m / n
		if type(n) == "number" then n = Complex(n, 0) end
		return
			submod(m, n, Complex(math.floor(div.real), math.floor(div.imag))) or
			submod(m, n, Complex(math.floor(div.real), math.ceil(div.imag))) or
			submod(m, n, Complex(math.ceil(div.real), math.floor(div.imag))) or
			submod(m, n, Complex(math.ceil(div.real), math.ceil(div.imag)))
	end,
	-- Unary Minus
	__unm = function(z)
		return Complex(-z.real, -z.imag)
	end,
	-- Comparison
	__eq = function(x, y)
		if type(x) == "number" and complex.is(y) then
			return x == y.real and y.imag == 0
		elseif complex.is(x) and type(y) == "number" then
			return x.real == y and x.imag == 0
		end
		if complex.is(x) ~= complex.is(y) then return false end
		return x.real == y.real and x.imag == y.imag
	end,
	__index = function(z, k)
		if indexer[k] then
			return indexer[k](z)
		end
		return error("'complex' has no member named '" .. tostring(k) .. "'.")
	end,
	__newindex = function(z, k)
		return error("Cannot set members of 'complex'.")
	end
}

ffi.metatype(Complex, meta)

return complex
