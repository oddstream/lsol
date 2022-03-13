-- textwidget

local Widget = require 'ui_widget'
local Util = require 'util'

local TextWidget = {
	-- text
	-- baizeCmd and optional param
}
TextWidget.__index = TextWidget
setmetatable(TextWidget, {__index = Widget})

function TextWidget.new(o)
	o.enabled = true
	return setmetatable(o, TextWidget)
end

function TextWidget:draw()
	local cx, cy, cw, ch = self.parent:screenRect()
	local wx, wy, ww, wh = self:screenRect()

	if wy < cy then
		return
	end
	if wy + wh > cy + ch then
		return
	end

	love.graphics.setFont(self.parent.font)
	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			love.graphics.setColor(1,1,1,1)
			if love.mouse.isDown(1) then
				wx = wx + 2
				wy = wy + 2
			end
		else
			love.graphics.setColor(1,1,1,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end
	love.graphics.print(self.text, wx, wy)

	if _G.BAIZE.settings.debug then
		love.graphics.rectangle('line', wx, wy, ww, wh)
	end

end

return TextWidget
