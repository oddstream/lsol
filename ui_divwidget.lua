-- divwidget

local Widget = require 'ui_widget'

local DivWidget = {
}
DivWidget.__index = DivWidget
setmetatable(DivWidget, {__index = Widget})

function DivWidget.new(o)
	o.enabled = false
	o.height = 0
	return setmetatable(o, DivWidget)
end

function DivWidget:draw()
	local x, y = self.parent.x, self.parent.y + self.y
	love.graphics.setColor(0.5,0.5,0.5,1)
	love.graphics.line(x, y, x + self.width, y)
end

return DivWidget
