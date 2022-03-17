-- textdrawer

local Drawer = require 'ui_drawer'

local TextDrawer = {}
TextDrawer.__index = TextDrawer
setmetatable(TextDrawer, {__index = Drawer})

function TextDrawer.new(o)
	o = Drawer.new(o)
	o.width = o.width or 256

	o.aniState = 'stop'
	o.x = -o.width -- starts hidden
	o.y = 48 -- below titlebar
	o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, 24)
	o.spacex = o.font:getHeight('_')
	o.spacey = o.font:getHeight('!')
	o.widgets = {}

	o:layout()	-- instantiates .height

	return setmetatable(o, TextDrawer)
end

return TextDrawer
