-- titlebar

-- https://m3.material.io/components/top-app-bar/overview

local Bar = require 'ui_bar'

local Titlebar = {}
Titlebar.__index = Titlebar
setmetatable(Titlebar, {__index = Bar})

function Titlebar.new()
	local o = {}
	setmetatable(o, Titlebar)

	o.widgets = {}

	return o
end

function Titlebar:layout()
	local w, _, _ = love.window.getMode()

	self.x = 0
	self.y = 0
	self.width = w
	self.height = 48

	for _, wgt in ipairs(self.widgets) do
		wgt:layout()
	end
end

-- use Bar.update

-- use Bar.draw

return Titlebar
