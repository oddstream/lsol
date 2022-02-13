-- textwidget

local Widget = require 'ui_widget'

local TextWidget = {
	-- text
	-- font
	-- some form of command callback thingy
}
TextWidget.__index = TextWidget
setmetatable(TextWidget, {__index = Widget})

function TextWidget.new(o)
	setmetatable(o, TextWidget)
	return o
end

function TextWidget:layout()
	assert(self.parent)
	assert(self.parent.width)
	assert(self.parent.height)
	self.width = self.font:getWidth(self.text)
	self.height = self.font:getHeight(self.text)

	local spacex = self.font:getWidth('_')

	if self.align == -1 then
		self.x = self.parent.x + spacex
		self.y = (self.parent.height - self.height) / 2
	elseif self.align == 0 then
		self.x = (self.parent.width - self.width) / 2
		self.y = (self.parent.height - self.height) / 2
	elseif self.align == 1 then
		self.x = self.parent.width - self.width - spacex
		self.y = (self.parent.height - self.height) / 2
	end
end

function TextWidget:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(1,1,1)
	love.graphics.print(self.text, self.parent.x + self.x, self.parent.y + self.y)
end

return TextWidget
