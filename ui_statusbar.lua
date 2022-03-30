-- statusbar

local Bar = require 'ui_bar'

local Statusbar = {}
Statusbar.__index = Statusbar
setmetatable(Statusbar, {__index = Bar})

function Statusbar.new(o)
	o = Bar.new(o)

	o.height = _G.STATUSBARHEIGHT
	o.align = 'bottom'
	o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, _G.UIFONTSIZE_SMALL)
	o.spacex = o.font:getWidth('M')
	o.spacey = o.font:getHeight('M')

	return setmetatable(o, Statusbar)
end

-- use Bar.layout

-- use Bar.update

-- use Container.draw

return Statusbar
