-- Key Name constants
return setmetatable({
	space = "Space",
	kp0 = "Num0",
	kp1 = "Num1", kp2 = "Num2", kp3 = "Num3",
	kp4 = "Num4", kp5 = "Num5", kp6 = "Num6",
	kp7 = "Num7", kp8 = "Num8", kp9 = "Num9",
	["kp."] = "Num.", ["kp,"] = "Num,", ["kp/"] = "Num/",
	["kp*"] = "Num*", ["kp-"] = "Num-", ["kp+"] = "Num+",
	kpenter = "NumEnter", ["kp="] = "Num=",
	up = "Up", down = "Down",
	left = "Left", right = "Right",
	home = "Home", ["end"] = "End",
	pageup = "Page Up", pagedown = "Page Down",
	insert = "Insert", delete = "Delete",
	backspace = "Backspace", ["return"] = "Return", tab = "Tab",
	clear = "Clear",
	numlock = "Num-Lock", capslock = "Caps-Lock", scrolllock = "Scroll-Lock",
	rshift = "R.Shift", lshift = "L.Shift",
	rctrl = "R.Ctrl", lctrl = "L.Ctrl",
	ralt = "R.Alt", lalt = "L.Alt",
	rgui = "R.Cmd", lgui = "L.Cmd",
	mode = "Mode",
	pause = "Pause",
	escape = "Esc.",
	help = "Help",
	printscreen = "Print",
	menu = "Menu",
	currencyunit = "$",
	undo = "Undo",
	unknown = "???"
}, {
	__index = function(self, key)
		local name = key:upper()
		self[key] = name
		return name
	end
})
