-- textwidget

local Widget = require 'ui_widget'
local Util = require 'util'

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
	local x, y = self.parent.x + self.x, self.parent.y + self.y
	love.graphics.setFont(self.parent.font)
	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			love.graphics.setColor(1,1,1,1)
			if love.mouse.isDown(1) then
				x = x + 2
				y = y + 2
			end
		else
			love.graphics.setColor(0.9,0.9,0.9,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end
	love.graphics.print(self.text, x, y)
end

return TextWidget
