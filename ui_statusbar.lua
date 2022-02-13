-- statusbar

local Bar = require 'ui_bar'

local Statusbar = {}
Statusbar.__index = Statusbar
setmetatable(Statusbar, {__index = Bar})

function Statusbar.new()
	local o = {}
	setmetatable(o, Statusbar)

	o.widgets = {}

	return o
end

function Statusbar:layout()
	local w, h, _ = love.window.getMode()

	self.x = 0
	self.y = h - 24
	self.width = w
	self.height = 24

	for _, wgt in ipairs(self.widgets) do
		wgt:layout()
	end
end

-- use Bar.update

-- use Bar.draw

return Statusbar
