-- drawer

local Drawer = {}
Drawer.__index = Drawer

function Drawer.new()
	local o = {}
	setmetatable(o, Drawer)
	return o
end

function Drawer:screenRect()
	return self.x, self.y, self.width, self.height -- bar is not scrollable, so baize == screen pos
end

function Drawer:visible()
	return self.x == 0
end

function Drawer:hidden()
	return self.x == -self.width
end

function Drawer:show()
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
		wgt.width = self.font:getWidth(wgt.text)
		wgt.height = self.font:getHeight(wgt.text)
		wgt.x = self.spacex
		wgt.y = nexty

		nexty = wgt.y + wgt.height + self.spacey
	end
end

function Drawer:draw()
	if not self:hidden() then
		love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
		for _, w in ipairs(self.widgets) do
			w:draw()
		end
	end
end

return Drawer
