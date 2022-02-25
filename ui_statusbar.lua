-- statusbar

local Bar = require 'ui_bar'

local Statusbar = {}
Statusbar.__index = Statusbar
setmetatable(Statusbar, {__index = Bar})

function Statusbar.new(o)
	o = Bar.new(o)

	o.height = 24
	o.align = 'bottom'
	o.font = love.graphics.newFont('assets/fonts/Roboto-Medium.ttf', 14)
	o.spacex = o.font:getWidth('_')

	return setmetatable(o, Statusbar)
end

-- use Bar.layout

-- use Bar.update

-- use Container.draw

return Statusbar
