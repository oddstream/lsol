-- menudrawer

local Drawer = require 'ui_drawer'

local MenuDrawer = {}
MenuDrawer.__index = MenuDrawer
setmetatable(MenuDrawer, {__index = Drawer})

function MenuDrawer.new(o)
	o = Drawer.new(o)
	o.width = o.width or 256

	o.aniState = 'stop'
	o.x = -(o.width + _G.UI_SAFEX) -- starts hidden
	o.y = _G.UI_SAFEY + _G.TITLEBARHEIGHT -- below titlebar
	o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, _G.UIFONTSIZE)
	o.spacex = o.font:getHeight('M')
	o.spacey = o.font:getHeight('M')
	o.widgets = {}

	o:layout()	-- instantiates .height

	return setmetatable(o, MenuDrawer)
end

return MenuDrawer
