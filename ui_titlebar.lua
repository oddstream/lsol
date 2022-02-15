-- titlebar

-- https://m3.material.io/components/top-app-bar/overview

local Bar = require 'ui_bar'

local Titlebar = {}
Titlebar.__index = Titlebar
setmetatable(Titlebar, {__index = Bar})

function Titlebar.new()
	local o = {}
	setmetatable(o, Titlebar)

	o.height = 48
	o.align = 'top'
	o.font = love.graphics.newFont('assets/Roboto-Medium.ttf', 24)
	o.spacex = o.font:getWidth('_')
	o.widgets = {}

	return o
end

-- use Bar.layout

-- use Bar.update

-- use Bar.draw

return Titlebar
