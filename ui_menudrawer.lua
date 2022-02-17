-- menudrawer

local Drawer = require 'ui_drawer'

local MenuDrawer = {}
MenuDrawer.__index = MenuDrawer
setmetatable(MenuDrawer, {__index = Drawer})

function MenuDrawer.new(o)
	o = o or {}
	if not o.width then
		o.width = 256
	end
	setmetatable(o, MenuDrawer)

	o.aniState = 'stop'

	o.x = -o.width -- starts hidden
	o.y = 48 -- below titlebar

	o.font = love.graphics.newFont('assets/Roboto-Medium.ttf', 24)
	o.spacex = o.font:getHeight('_')
	o.spacey = o.font:getHeight('!')
	o.widgets = {}

	o:layout()	-- instantiates .height

	return o
end

return MenuDrawer
