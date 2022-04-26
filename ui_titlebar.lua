-- titlebar

-- https://m3.material.io/components/top-app-bar/overview

local Bar = require 'ui_bar'

local Titlebar = {}
Titlebar.__index = Titlebar
setmetatable(Titlebar, {__index = Bar})

function Titlebar.new(o)
	o = Bar.new(o)

	o.height = _G.TITLEBARHEIGHT
	o.align = 'top'
	o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, _G.UIFONTSIZE)
	o.spacex = o.font:getWidth('M')
	o.spacey = o.font:getHeight()

	return setmetatable(o, Titlebar)
end

-- use Bar.layout

-- use Bar.update

-- use Container.draw

return Titlebar
