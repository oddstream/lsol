-- drawer

local Container = require 'ui_container'

local Util = require('util')

local Drawer = {}
Drawer.__index = Drawer
setmetatable(Drawer, {__index = Container})

function Drawer.new(o)
	o = Container.new(o)

	o.width = o.width or 256
	o.aniState = 'stop'
	o.x = -(o.width + _G.UI_SAFEX) -- starts hidden
	if not o.font then o.font = love.graphics.newFont(_G.UI_MEDIUM_FONT, _G.UIFONTSIZE) end
	o.spacex = o.font:getWidth('M')
	o.spacey = o.font:getHeight()
	o.vscroll = true
	o.widgets = {}

	Drawer.layout(o)	-- instantiates .y, .height

	return setmetatable(o, Drawer)
end

function Drawer:isOpen()
	return self.x == _G.UI_SAFEX
end

function Drawer:hidden()
	local closedx = _G.UI_SAFEX - self.width
	return self.x <= closedx
end

function Drawer:show()
	Util.play('menushow')
	self.dragOffset = {x=0, y=0}
	self.aniState = 'right'
end

function Drawer:hide()
	-- Util.play('menuhide')
	self.aniState = 'left'
end

function Drawer:update(dt_seconds)
	if self.aniState == 'left' then
		-- draw is fully closed when x == left edge of safe area - width
		local closedx = _G.UI_SAFEX - self.width
		if self.x <= closedx then
			self.x = closedx
			self.aniState = 'stop'
		else
			self.x = self.x - (16 * _G.UI_SCALE)
		end
	elseif self.aniState == 'right' then
		-- draw is fully open when x == left edge of safe area
		if self.x >= _G.UI_SAFEX then
			self.x = _G.UI_SAFEX
			self.aniState = 'stop'
		else
			self.x = self.x + (16 * _G.UI_SCALE)
		end
	end
end

function Drawer:layout()
	-- x set dynamically
	self.y = _G.UI_SAFEY + _G.TITLEBARHEIGHT -- below titlebar
	-- width set when created
	self.height = _G.UI_SAFEH - _G.TITLEBARHEIGHT - _G.STATUSBARHEIGHT	-- does not cover title or status bars

	local nexty = self.spacey

	local iconSize = 36 * _G.UI_SCALE

	for _, wgt in ipairs(self.widgets) do

		if wgt.img and wgt.text then
			wgt.width = iconSize + iconSize + self.font:getWidth(wgt.text)
			wgt.height = iconSize
		elseif wgt.img then
			wgt.width = iconSize
			wgt.height = iconSize
		elseif wgt.text then
			wgt.width = self.font:getWidth(wgt.text)
			wgt.height = self.font:getHeight()
		end

		if (not wgt.img) and (not wgt.text) then
			-- DivWidget
			wgt.width = self.width
			wgt.height = 0
		end

		wgt.x = self.spacex
		wgt.y = nexty

		nexty = wgt.y + wgt.height + self.spacey
	end
end

-- Drawer:draw() is done by Container:draw()

return Drawer
