-- ui_container

local Container = {}
Container.__index = Container

function Container.new(o)
	o = o or {}
	o.dragOffset = {x=0, y=0}
	o.dragStart = {x=0, y=0}
	o.widgets = {}
	return setmetatable(o, Container)
end

function Container:screenRect()
	return self.x, self.y, self.width, self.height -- bar is not scrollable, so baize == screen pos
end

function Container:startDrag(x, y)
	self.dragStart.x = self.dragOffset.x
	self.dragStart.y = self.dragOffset.y
end

function Container:dragBy(dx, dy)
--[[
	self.dragOffset.x = self.dragStart.x + dx
	if self.dragOffset.x > 0 then
		self.dragOffset.x = 0	-- DragOffset should only ever be 0 or -ve
	end
]]
	self.dragOffset.y = self.dragStart.y + dy
	if self.dragOffset.y > 0 then
		self.dragOffset.y = 0	-- DragOffset should only ever be 0 or -ve
	end
end

function Container:stopDrag(x, y)
end

-- update handled by subclasses
-- layout handled by subclasses

function Container:draw()
	if not self:hidden() then
		love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
		love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
		for _, w in ipairs(self.widgets) do
			w:draw()
		end
	end
end

return Container