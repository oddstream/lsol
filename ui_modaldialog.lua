-- ui_modaldialog

local log = require 'log'

local Util = require 'util'

local ModalDialog = {}
ModalDialog.__index = ModalDialog

function ModalDialog.new(o)
	assert(o.title)
	assert(o.text)
	assert(o.buttons)
	assert(o.font)
	-- work out width and height from text

	local mw = o.font:getWidth(o.text)
	local mh = o.font:getHeight(o.text)
	o.width = mw + o.font:getWidth('M') * 2
	o.height = (mh + o.font:getHeight('M') * 2) * 3	-- three lines

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
	self.x = (_G.UI_SAFEX + _G.UI_SAFEW) - (self.width * 1.5)
	self.y = (_G.UI_SAFEY + _G.UI_SAFEH) - (self.height * 1.5) - _G.STATUSBARHEIGHT
end

function ModalDialog:draw()
	local mw = self.font:getWidth(self.text)
	local mh = self.font:getHeight(self.text)

	love.graphics.setFont(self.font)
	Util.setColorFromName('UiBackground')
	love.graphics.rectangle('fill', _G.UI_SAFEX + (_G.UI_SAFEW - self.width) / 2, _G.UI_SAFEY + ((_G.UI_SAFEH - self.height) / 2), self.width, self.height, _G.BAIZE.cardRadius, _G.BAIZE.cardRadius)
	Util.setColorFromName('UiForeground')
	love.graphics.print(self.text, _G.UI_SAFEX + (_G.UI_SAFEW - mw) / 2, _G.UI_SAFEY + ((_G.UI_SAFEH - mh) / 2))
end

return ModalDialog
