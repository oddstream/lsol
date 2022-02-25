-- drawer

local Container = require 'ui_container'

local Drawer = {}
Drawer.__index = Drawer
setmetatable(Drawer, {__index = Container})

function Drawer.new(o)
	o = Container.new(o)
	return setmetatable(o, Drawer)
end

function Drawer:isOpen()
	return self.x == 0
end

function Drawer:hidden()
	return self.x == -self.width
end

function Drawer:show()
	self.dragOffset = {x=0, y=0}
	self.aniState = 'right'
end

function Drawer:hide()
	self.aniState = 'left'
end

function Drawer:update()
	if self.aniState == 'left' then
		if self.x <= -self.width then
			self.x = -self.width
			self.aniState = 'stop'
		else
			self.x = self.x - 16
		end
	elseif self.aniState == 'right' then
		if self.x >= 0 then
			self.x = 0
			self.aniState = 'stop'
		else
			self.x = self.x + 16
		end
	end
end

function Drawer:layout()
	local _, h, _ = love.window.getMode()

	-- x set dynamically
	self.y = 48 -- below titlebar
	-- width set when created
	self.height = h - 48 - 24	-- does not cover title or status bars

	local nexty = self.spacey

	for _, wgt in ipairs(self.widgets) do
		if wgt.text then
			-- TextWidget, Checkbox
			wgt.width = self.font:getWidth(wgt.text)
			wgt.height = self.font:getHeight(wgt.text)
		else
			-- DivWidget
			wgt.width = self.width
			-- wgt.height = 36
		end
		wgt.x = self.spacex
		wgt.y = nexty

		nexty = wgt.y + wgt.height + self.spacey
	end
end

return Drawer
