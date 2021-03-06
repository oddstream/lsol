-- bar

local Container = require 'ui_container'

local Bar = {}
Bar.__index = Bar
setmetatable(Bar, {__index = Container})

function Bar.new(o)
	o = Container.new(o)
	return setmetatable(o, Bar)
end

function Bar:hidden()
	return false
end

function Bar:update(dt_seconds)
	-- nothing to do
end

function Bar:layout()
	self.x = _G.UI_SAFEX
	if self.align == 'top' then
		self.y = _G.UI_SAFEY
	elseif self.align == 'bottom' then
		self.y = _G.UI_SAFEY + _G.UI_SAFEH - self.height
	end
	self.width = _G.UI_SAFEW
	-- height set by subclass

	local nextLeft = self.spacex
	local nextRight = self.width - self.spacex

	for _, wgt in ipairs(self.widgets) do
		if wgt.img then
			wgt.width = wgt.imgWidth
			wgt.height = wgt.imgHeight
		elseif wgt.text then
			wgt.width = self.font:getWidth(wgt.text)
			wgt.height = self.font:getHeight()
		end
		if wgt.align == 'left' then
			wgt.x = nextLeft
			nextLeft = nextLeft + wgt.width + self.spacex
		elseif wgt.align == 'center' then
			wgt.x = (self.width - wgt.width) / 2
		elseif wgt.align == 'right' then
			wgt.x = nextRight - wgt.width
			nextRight = wgt.x - self.spacex
		end
		wgt.y = (self.height - wgt.height) / 2
	end
end

return Bar
