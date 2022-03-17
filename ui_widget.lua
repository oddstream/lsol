-- widget

local Widget = {
	-- parent
	-- x, y	relative to parent
	-- width, height
	-- align
}
Widget.__index = Widget

function Widget.new(o)
	return setmetatable(o, Widget)
end

function Widget:screenRect()
	local x = self.parent.x + self.parent.dragOffset.x + self.x
	local y = self.parent.y + self.parent.dragOffset.y + self.y
	return x, y, self.width, self.height
end

-- Widget:layout() done by parent

-- no need for Widget:update()

-- Widget.draw() done by subclasses

return Widget
