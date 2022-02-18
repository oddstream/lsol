-- textwidget

local Widget = require 'ui_widget'

local TextWidget = {
	-- text
	-- font
	-- baizeCmd and optional param
}
TextWidget.__index = TextWidget
setmetatable(TextWidget, {__index = Widget})

function TextWidget.new(o)
	setmetatable(o, TextWidget)
	o.enabled = true
	return o
end

function TextWidget:draw()
	love.graphics.setFont(self.parent.font)
	if self.enabled then
		love.graphics.setColor(1,1,1,1)
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end
	love.graphics.print(self.text, self.parent.x + self.x, self.parent.y + self.y)
end

return TextWidget
