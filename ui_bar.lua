-- bar

local Bar = {}
Bar.__index = Bar

function Bar.new()
	local o = {}
	setmetatable(o, Bar)

	o.widgets = {}

	return o
end

-- no need for Bar:update()

-- use Subclass:layout()

function Bar:draw()
	love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
	love.graphics.rectangle('fill', self.x, self.y, self.width, self.height)
	for _, w in ipairs(self.widgets) do
		w:draw()
	end
end

return Bar
