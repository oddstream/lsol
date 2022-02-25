-- titlebar

-- https://m3.material.io/components/top-app-bar/overview

local Bar = require 'ui_bar'

local Titlebar = {}
Titlebar.__index = Titlebar
setmetatable(Titlebar, {__index = Bar})

function Titlebar.new(o)
	o = Bar.new(o)

	o.height = 48
	o.align = 'top'
	o.font = love.graphics.newFont('assets/fonts/Roboto-Medium.ttf', 24)
	o.spacex = o.font:getWidth('_')

	return setmetatable(o, Titlebar)
end

-- use Bar.layout

-- use Bar.update

-- use Container.draw

return Titlebar
