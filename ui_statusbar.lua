-- statusbar

local Bar = require 'ui_bar'

local Statusbar = {}
Statusbar.__index = Statusbar
setmetatable(Statusbar, {__index = Bar})

function Statusbar.new()
	local o = {}
	setmetatable(o, Statusbar)

	o.height = 24
	o.align = 'bottom'
	o.font = love.graphics.newFont('assets/fonts/Roboto-Medium.ttf', 14)
	o.spacex = o.font:getWidth('_')
	o.widgets = {}

	return o
end

-- use Bar.layout

-- use Bar.update

-- use Bar.draw

return Statusbar
