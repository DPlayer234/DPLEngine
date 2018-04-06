local ffi = require "ffi"
local C = ffi.C

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

local complex = ffi.typeof("complex")

local methods = {
	real = function(z)
		return C.creal(z)
	end,
	imag = function(z)
		return C.cimag(z)
	end,
	abs = function(z)
		return C.cabs(z)
	end,
	arg = function(z)
		return C.carg(z)
	end,
	conj = function(z)
		return C.conj(z)
	end,
	proj = function(z)
		return C.cproj(z)
	end,
	exp = function(z)
		return C.cexp(z)
	end,
	log = function(z)
		return C.clog(z)
	end,
	pow = function(x, y)
		return C.cpow(x, y)
	end,
	sqrt = function(z)
		return C.csqrt(z)
	end,
	sin = function(z)
		return C.csin(z)
	end,
	cos = function(z)
		return C.ccos(z)
	end,
	tan = function(z)
		return C.ctan(z)
	end,
	asin = function(z)
		return C.casin(z)
	end,
	acos = function(z)
		return C.cacos(z)
	end,
	atan = function(z)
		return C.catan(z)
	end,
	sinh = function(z)
		return C.csinh(z)
	end,
	cosh = function(z)
		return C.ccosh(z)
	end,
	tanh = function(z)
		return C.ctanh(z)
	end,
	asinh = function(z)
		return C.casinh(z)
	end,
	acosh = function(z)
		return C.cacosh(z)
	end,
	atanh = function(z)
		return C.catanh(z)
	end,
	r = function(z)
		return C.creal(z)
	end,
	i = function(z)
		return C.cimag(z)
	end,
	phaseAngle = function(z)
		return C.carg(z)
	end,
	conjugate = function(z)
		return C.conj(z)
	end,
	projection = function(z)
		return C.cproj(z)
	end,
	abssqr = function(z)
		return z:real() ^ 2 + z:imag() ^ 2
	end
}

local meta = {
	-- Addition
	__add = function(x, y)
		if type(x) == "number" then
			return complex(x + y:real(), y:imag())
		elseif type(y) == "number" then
			return complex(x:real() + y, x:imag())
		else
			return complex(x:real() + y:real(), x:imag() + y:imag())
		end
	end,
	-- Subtraction
	__sub = function(x, y)
		if type(x) == "number" then
			return complex(x - y:real(), -y:imag())
		elseif type(y) == "number" then
			return complex(x:real() - y, x:imag())
		else
			return complex(x:real() - y:real(), x:imag() - y:imag())
		end
	end,
	-- Multiplication
	__mul = function(x, y)
		if type(x) == "number" then
			return complex(x * y:real(), x * y:imag())
		elseif type(y) == "number" then
			return complex(x:real() * y, x:imag() * y)
		else
			return complex(
				x:real() * y:real() - x:imag() * y:imag(),
				x:real() * y:imag() + x:imag() * y:real())
		end
	end,
	-- Division
	__div = function(x, y)
		if type(y) == "number" then
			return complex(x:real() / y, x:imag() / y)
		else
			return (x * y:conj()) / y:abssqr()
		end
	end,
	-- Power
	__pow = function(x, y)
		return x:pow(y)
	end,
	-- Unary Minus
	__unm = function(z)
		return complex(-z:real(), -z:imag())
	end,
	-- Comparison
	__eq = function(x, y)
		if not ffi.istype(complex, x) or not ffi.istype(complex, y) then return false end
		return x:real() == y:real() and x:imag() == y:imag()
	end,
	__index = methods
}

ffi.metatype(complex, meta)

return complex
