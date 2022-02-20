-- ui_fab

local log = require 'log'

local Util = require 'util'

local FAB = {}
FAB.__index = FAB

function FAB.new(o)
	assert(o.icon)
	assert(o.baizeCmd)
	setmetatable(o, FAB)

	local fname = 'assets/' .. o.icon .. '.png'
	local imageData = love.image.newImageData(fname)
	local imgIcon
	if not imageData then
		log.error('could not load', fname)
	else
		imgIcon = love.graphics.newImage(imageData)
		o.width = imageData:getWidth() * 2
		o.height = imageData:getHeight() * 2
		-- log.trace('loaded', fname)
	end

	local canvas = love.graphics.newCanvas(o.width, o.height)
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(love.math.colorFromBytes(0x32, 0x32, 0x32, 255))
	love.graphics.circle('fill', o.width/2, o.height/2, o.width/2)
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(imgIcon, o.width / 4, o.height / 4)
	love.graphics.setCanvas()

	o.texture = canvas
	o.enabled = true
	return o
end

function FAB:screenPos()
	return self.x, self.y
end

function FAB:screenRect()
	return self.x, self.y, self.width, self.height
end

function FAB:layout()
	local w, h, _ = love.window.getMode()

	self.x = w - (self.width * 1.5)
	self.y = h - (self.height * 1.5) - 24
end

function FAB:draw()
	if self.texture then
		local x, y = self.x, self.y
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			if love.mouse.isDown(1) then
				x = x + 2
				y = y + 2
			end
		end
		love.graphics.draw(self.texture, x, y)
	end
end

return FAB
