-- stroke

local Stroke = {}
Stroke.__index = Stroke

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
		s.notifyFn({event='start', stroke=s, x=mx, y=my})
	end
	return s
end

function Stroke:update()
	if self.released or self.cancelled then
		return
	end
	if not love.mouse.isDown(1) then
		if self.init.x == self.curr.x and self.init.y == self.curr.y then
			local elapsed = love.timer.getTime() - self.timeStart
			print('elapsed', elapsed)
			if elapsed < 0.2 then
				self.notifyFn({event='tap', object=self.draggedObject, type=self.draggedObjectType, x=self.curr.x, y=self.curr.y})
			end
			self.notifyFn({event='cancel', object=self.draggedObject, type=self.draggedObjectType, x=self.curr.x, y=self.curr.y})
			self.cancelled = true
		else
			self.notifyFn({event='stop', object=self.draggedObject, type=self.draggedObjectType, x=self.curr.x, y=self.curr.y})
			self.released = true
		end
	else
		local mx, my = love.mouse.getPosition()
		if self.curr.x ~= mx or self.curr.y ~= my then
			self.curr.x = mx
			self.curr.y = my
			self.notifyFn({event='move', object=self.draggedObject, type=self.draggedObjectType, x=self.curr.x, y=self.curr.y})
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
