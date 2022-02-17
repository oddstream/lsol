-- bar

local log = require 'log'

local Bar = {}
Bar.__index = Bar

function Bar.new()
	local o = {}
	setmetatable(o, Bar)
	return o
end

function Bar:screenRect()
	return self.x, self.y, self.width, self.height -- bar is not scrollable, so baize == screen pos
end

function Bar:update(dt)
	-- nothing to do
end

function Bar:layout()
	local w, h, _ = love.window.getMode()

	self.x = 0
	if self.align == 'top' then
		self.y = 0
	elseif self.align == 'bottom' then
		self.y = h - self.height
	end
	self.width = w
	-- height set by subclass

	local nextLeft = self.x + self.spacex
	local nextRight = self.width - self.spacex

	for i, wgt in ipairs(self.widgets) do
		-- icon
		-- text
		-- icon text
		if wgt.img then
			wgt.width = wgt.imgWidth
			wgt.height = wgt.imgHeight
		elseif wgt.text then
			wgt.width = self.font:getWidth(wgt.text)
			wgt.height = self.font:getHeight(wgt.text)
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
		-- log.trace(i, wgt.text or wgt.icon, wgt.align, wgt.x, wgt.y, wgt.width, wgt.height)
	end
end

function Bar:draw()
	love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	for _, w in ipairs(self.widgets) do
		w:draw()
	end
end

return Bar
