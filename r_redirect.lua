--[[
The purpose of this file to set force certain files to be required instead of a possible
other one to prevent user-code execution.
Basically, to make sure stuff like 'require "mod_path"' actually load 'mod_path/init.lua' etc.
Also means that 'require "mod_path"' and 'require "mod_path.init"' are functionally identical.
]]
local package, require = package, require

for i,f in ipairs {
	-- List of directories to redirect to *.init
	"dev",
	"heartbeat",
	"heartbeat.components",
	"heartbeat.ecs",
	"heartbeat.entities",
	"heartbeat.game_state",
	"heartbeat.libs.input",
	-- End of list
} do
	-- Setup the redirection
	local fi = f .. ".init"
	package.preload[f] = function()
		return require(fi)
	end
end
