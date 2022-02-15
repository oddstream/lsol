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
	return self.parent.x + self.x, self.parent.y + self.y
end

function Widget:screenRect()
	return self.parent.x + self.x, self.parent.y + self.y, self.width, self.height
end

-- Widget:layout() done by parent

-- no need for Widget:update()

-- Widget.draw() done by subclasses

return Widget
