-- drawer

local Container = require 'ui_container'

local Util = require('util')

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
	Util.play('menushow')
	self.dragOffset = {x=0, y=0}
	self.aniState = 'right'
end

function Drawer:hide()
	-- Util.play('menuhide')
	self.aniState = 'left'
end

function Drawer:update()
	if self.aniState == 'left' then
		if self.x <= -self.width then
			self.x = -self.width
			self.aniState = 'stop'
		else
			self.x = self.x - (16 * _G.UISCALE)
		end
	elseif self.aniState == 'right' then
		if self.x >= 0 then
			self.x = 0
			self.aniState = 'stop'
		else
			self.x = self.x + (16 * _G.UISCALE)
		end
	end
end

function Drawer:layout()
	local _, h, _ = love.window.getMode()

	-- x set dynamically
	self.y = _G.TITLEBARHEIGHT -- below titlebar
	-- width set when created
	self.height = h - _G.TITLEBARHEIGHT - _G.STATUSBARHEIGHT	-- does not cover title or status bars

	local nexty = self.spacey

	local iconSize = 36 * _G.UISCALE

	for _, wgt in ipairs(self.widgets) do

		if wgt.img and wgt.text then
			wgt.width = iconSize + iconSize + self.font:getWidth(wgt.text)
			wgt.height = iconSize
		elseif wgt.img then
			wgt.width = iconSize
			wgt.height = iconSize
		elseif wgt.text then
			wgt.width = self.font:getWidth(wgt.text)
			wgt.height = self.font:getHeight(wgt.text)
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

return Drawer
