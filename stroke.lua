-- stroke

-- TODO update to allow touch (and joystick?) as well as mouse
-- TODO update to allow right mouse button

-- local log = require 'log'

local Stroke = {}
Stroke.__index = Stroke

function Stroke:makeNotifyObject(event)
	assert(type(event)=='string')
	return {event=event, stroke=self, object=self.draggedObject, type=self.draggedObjectType, x=self.curr.x, y=self.curr.y, dx=self.curr.x - self.init.x, dy=self.curr.y - self.init.y}
end

function Stroke.start(notifyFn)
	assert(type(notifyFn)=='function')
	local s
	if love.mouse.isDown(1) then
		local mx, my = love.mouse.getPosition()
		s = {
			init = {x=mx, y=my},
			curr = {x=mx, y=my},
			released = false,
			cancelled = false,
			timeStart = love.timer.getTime(),
			notifyFn = notifyFn
		}
		setmetatable(s, Stroke)
		s.notifyFn(s:makeNotifyObject('start'))
	end
	return s
end

function Stroke:update()
	if self.released or self.cancelled then
		return
	end
	if not love.mouse.isDown(1) then
		if math.abs(self.init.x - self.curr.x) < 3 and math.abs(self.init.y - self.curr.y) < 3 then
			local elapsed = love.timer.getTime() - self.timeStart
			-- log.info('elapsed', elapsed)
			if elapsed < 0.2 then
				-- send out a cancel so the object/card can be put back to it's original place
				self.notifyFn(self:makeNotifyObject('cancel'))
				self.cancelled = true
				self.notifyFn(self:makeNotifyObject('tap'))
			else
				self.notifyFn(self:makeNotifyObject('cancel'))
				self.cancelled = true
			end
		else
			self.notifyFn(self:makeNotifyObject('stop'))
			self.released = true
		end
	else
		local mx, my = love.mouse.getPosition()
		if self.curr.x ~= mx or self.curr.y ~= my then
			self.curr.x = mx
			self.curr.y = my
			self.notifyFn(self:makeNotifyObject('move'))
		end
	end
end

function Stroke:cancel()
	self.cancelled = true
end

function Stroke:isReleased()
	return self.released
end

function Stroke:isCancelled()
	return self.cancelled
end

function Stroke:position()
	return self.curr.x, self.curr.y
end

function Stroke:positionDiff()
	return self.curr.x - self.init.x, self.curr.y - self.init.y
end

function Stroke:setDraggedObject(obj, typ)
	self.draggedObject = obj
	self.draggedObjectType = typ
end

function Stroke:getDraggedObject()
	return self.draggedObject, self.draggedObjectType
end

return Stroke
