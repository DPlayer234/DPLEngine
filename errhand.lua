--[[
Error handler mostly by 0x25a0:
https://love2d.org/forums/viewtopic.php?f=5&t=83881
]]

local love = love
local format, gsub = string.format, string.gsub
local traceback = debug.traceback

function love.errhand(error_message)
	local app_name = _game.title
	local version = _game.version
	local github_url = "https://www.github.com/DPlayer234/dpparkour2"
	local email = "dplayer.235@gmail.com"
	local edition = love.system.getOS()

	local tableFlip = "(╯°□°）╯︵ ┻━┻"

	local dialog_message = [[
%s crashed with the following error message:

%s

Would you like to report this crash so that it can be fixed?]]
	local title = tableFlip
	local full_error = traceback(error_message or "", 2)
	local message = format(dialog_message, app_name, full_error)
	local buttons = {
		"Yes, on GitHub",
		"Yes, by email",
		"No",
		_arg.debug and tableFlip or nil --#exclude line
	}

	local pressedbutton = love.window.showMessageBox(title, message, buttons)

	local function url_encode(text)
		-- This is not complete. Depending on your issue text, you might need to expand it!
		text = gsub(text, "\n", "%%0A")
		text = gsub(text, " ", "%%20")
		text = gsub(text, "#", "%%23")
		return text
	end

	local issuebody = [[
%s crashed with the following error message:

%s

[If you can, describe what you've been doing when the error occurred]

---
Version: %s
Edition: %s]]

	if pressedbutton == 1 then
		-- Surround traceback in ``` to get a Markdown code block
		full_error = "```\n" .. full_error .. "\n```"
		issuebody = format(issuebody, app_name, full_error, version, edition)
		issuebody = url_encode(issuebody)

		local subject = format("Crash in %s %s", app_name, version)
		local url = format("%s/issues/new?title=%s&body=%s", github_url, subject, issuebody)
		love.system.openURL(url)
	elseif pressedbutton == 2 then
		issuebody = format(issuebody, app_name, full_error, version, edition)
		issuebody = url_encode(issuebody)

		local subject = format("Crash in %s %s", app_name, version)
		local url = format("mailto:%s?subject=%s&body=%s", email, subject, issuebody)
		love.system.openURL(url)
	--#exclude start
	elseif pressedbutton == 4 then
		local s, r = pcall(function()
			love.graphics.reset()
			return require("debugger").errhand(error_message, 5)
		end)
		if s then return r else return debug.debug() end
	--#exclude end
	end

	pcall(love.quit)
end
