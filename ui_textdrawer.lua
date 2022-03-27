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
	o.y = _G.TITLEBARHEIGHT -- below titlebar
	o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, _G.UIFONTSIZE)
	o.spacex = o.font:getHeight('_')
	o.spacey = o.font:getHeight('!')
	o.widgets = {}

	o:layout()	-- instantiates .height

	return setmetatable(o, TextDrawer)
end

return TextDrawer
