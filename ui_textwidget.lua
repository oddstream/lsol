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
	return o
end

function TextWidget:draw()
	love.graphics.setFont(self.parent.font)
	love.graphics.setColor(1,1,1,1)
	love.graphics.print(self.text, self.parent.x + self.x, self.parent.y + self.y)
end

return TextWidget
