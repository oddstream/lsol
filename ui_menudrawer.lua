-- menudrawer

local Drawer = require 'ui_drawer'

local MenuDrawer = {}
MenuDrawer.__index = MenuDrawer
setmetatable(MenuDrawer, {__index = Drawer})

function MenuDrawer.new()
	local o = {}
	setmetatable(o, MenuDrawer)

	o.aniState = 'stop'

	o.x = -256 -- starts hidden
	o.y = 48 -- below titlebar
	o.width = 256

	o.font = love.graphics.newFont('assets/Roboto-Medium.ttf', 24)
	o.spacex = o.font:getHeight('_')
	o.spacey = o.font:getHeight('!')
	o.widgets = {}

	o:layout()

	return o
end

return MenuDrawer
