--[[
A wrapper for Löve-graphics
Loading objects into memory.
]]
local assert = assert
local lgraphics = require "love.graphics"
local Vector2 = require "Heartbeat::Vector2"

local graphics = {}

-- Alternative calls to look like class-instantiation.
graphics.Font = lgraphics.newFont
graphics.Image = lgraphics.newImage
graphics.ImageFont = lgraphics.newImageFont
graphics.Mesh = lgraphics.newMesh
graphics.Quad = lgraphics.newQuad
graphics.Text = lgraphics.newText

return graphics
