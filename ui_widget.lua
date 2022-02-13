-- widget

local Widget = {
	-- parent
	-- x, y	relative to parent
	-- width, height
	-- align -1 (top/left), 0 (center), +1 (bottom/right)
}
Widget.__index = Widget

function Widget.new(o)
	setmetatable(o, Widget)
	return o
end

function Widget:screenPos()
	return {x=self.parent.x + self.x, y=self.parent.y + self.y}
end

function Widget:screenRect()
	return {
		x1=self.parent.x + self.x,
		y1=self.parent.y + self.y,
		x2=self.parent.x + self.x + self.width,
		y2=self.parent.y + self.y + self.height,
	}
end

-- Widget:layout() done by subclasses

-- no need for Widget:update()

-- Widget.draw done by subclasses

return Widget
