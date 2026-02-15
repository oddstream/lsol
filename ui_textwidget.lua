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
	-- TODO could set width, height here
	-- rather than in parent:layout
	return setmetatable(o, TextWidget)
end

function TextWidget:draw()
	local _, cy, _, ch = self.parent:screenRect()
	local wx, wy, ww, wh = self:screenRect()

	if wy < cy then
		return
	end
	if wy + wh > cy + ch then
		return
	end

	if self.backColor then
		Util.setColorFromName(self.backColor)
		local x, _, w, _ = self.parent:screenRect()
		local _, y, _, h = self:screenRect()
		-- widgets are vertically at 36 pixel intervals
		local iconSize = 36 * _G.UI_SCALE
		y = y - (iconSize - h) / 2
		h = h + (iconSize - h)
		love.graphics.rectangle('fill', x, y, w, h)
	end

	local textColor = self.textColor or 'UiForeground'

	love.graphics.setFont(self.font or self.parent.font)
	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			Util.setColorFromName(textColor)
			if love.mouse.isDown(1) then
				wx = wx + 2
				wy = wy + 2
			end
		else
			Util.setColorFromName(textColor)
		end
	else
		Util.setColorFromName('UiGrayedOut')
	end
	love.graphics.print(self.text, wx, wy)

	if _G.SETTINGS.debug then
		Util.setColorFromName('UiGrayedOut')
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line', wx, wy, ww, wh)
	end

end

return TextWidget
