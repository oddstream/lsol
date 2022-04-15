-- ui_modaldialog

local log = require 'log'

local TextWidget = require('ui_textwidget')
local Util = require 'util'

local ModalDialog = {}
ModalDialog.__index = ModalDialog

function ModalDialog.new(o)
	assert(o.text)
	assert(o.buttons)
	assert(o.font)
	-- work out width and height from text

	o.tw = o.font:getWidth(o.text)
	o.th = o.font:getHeight(o.text)
	o.width = o.tw + (o.font:getWidth('M') * 4)
	o.height = o.th * 6	-- two lines (space line, text, space line, space line, buttons, space line = 6 lines high)

	o.widgets = {}
	for _, btn in ipairs(o.buttons) do
		local wgt = TextWidget.new({parent=o, text=btn})
		table.insert(o.widgets, wgt)
	end

	o.dragOffset = {x=0, y=0}

	return setmetatable(o, ModalDialog)
end

function ModalDialog:screenRect()
	return self.x, self.y, self.width, self.height
end

function ModalDialog:startDrag(x, y)
	-- can't drag a ModalDialog
end

function ModalDialog:dragBy(dx, dy)
	-- can't drag a ModalDialog
end

function ModalDialog:stopDrag(x, y)
	-- can't drag a ModalDialog
end

function ModalDialog:layout()
	self.x = _G.UI_SAFEX + (_G.UI_SAFEW - self.width) / 2
	self.y = _G.UI_SAFEY + (_G.UI_SAFEH - self.height) / 2 - _G.STATUSBARHEIGHT

	local bgap = self.width / (#self.widgets + 1)
	local bx = 0
	local by = 0 + self.th + self.th + self.th + self.th
	for _, btn in ipairs(self.widgets) do
		bx = bx + bgap
		btn.x = bx
		btn.y = by
	end
end

function ModalDialog:draw()
	love.graphics.setFont(self.font)
	Util.setColorFromName('UiBackground')
	local x = _G.UI_SAFEX + (_G.UI_SAFEW - self.width) / 2
	local y = _G.UI_SAFEY + ((_G.UI_SAFEH - self.height) / 2)
	love.graphics.rectangle('fill', x, y, self.width, self.height)
	Util.setColorFromName('UiForeground')
	love.graphics.print(self.text, _G.UI_SAFEX + (_G.UI_SAFEW - self.tw) / 2, y + self.th)

	-- one button: (1) centered at center
	-- two buttons: (1) at one third, (2) at two thirds
	-- three buttons: (1) at one quarter, (2) at two quarters, (3) at three quarters
	-- four buttons: (1) at one fifth, (2) two fifths, (3) three fifths, (4) four fifths

	--[[
	local function drawButtonCenteredAt(btntext, btnx, btny)
		local bw = self.font:getWidth(btntext)
		local bh = self.font:getHeight(btntext)
		love.graphics.print(btntext, btnx - (bw / 2), btny - (bh / 2))
	end
	-- divide width by (number of buttons + 1)
	local bgap = self.width / (#self.buttons + 1)
	local bx = x
	local by = y + self.th + self.th + self.th + self.th
	for _, btn in ipairs(self.buttons) do
		bx = bx + bgap
		drawButtonCenteredAt(btn, bx, by)
	end
	]]
	for _, btn in ipairs(self.widgets) do
		love.graphics.print(btn.text, x + btn.x, y + btn.y)
	end
end

return ModalDialog
