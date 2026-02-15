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
	-- very important!: reset color before drawing to canvas to have colors properly displayed
	--[[
	local cx, cy, cw, ch = self.parent:screenRect()
	local wx, wy, ww, wh = self:screenRect()

	if wy < cy then
		return
	end
	if wy + wh > cy + ch then
		return
	end

	love.graphics.setColor(0.1,0.1,0.1,1)
	love.graphics.line(wx - self.parent.spacex, wy, ww, wy)
	]]
end

return DivWidget
