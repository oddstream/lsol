-- iconwidget

local log = require 'log'

local Widget = require 'ui_widget'
local Util = require 'util'

local IconWidget = {
	-- icon name
	-- baizeCmd and optional param
}
IconWidget.__index = IconWidget
setmetatable(IconWidget, {__index = Widget})

function IconWidget.new(o)
	setmetatable(o, IconWidget)
	o.enabled = true

	local fname = 'assets/' .. o.icon .. '.png'
	local imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.img = love.graphics.newImage(imageData)
		assert(o.img)
		o.imgWidth = imageData:getWidth()
		o.imgHeight = imageData:getHeight()
		log.trace('loaded', fname, o.imgWidth, o.imgHeight)
	end
	return o
end

function IconWidget:draw()
	-- very important!: reset color before drawing to canvas to have colors properly displayed
	local x, y = self.parent.x + self.x, self.parent.y + self.y
	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			love.graphics.setColor(1,1,1,1)
			if love.mouse.isDown(1) then
				x = x + 2
				y = y + 2
			end
		else
			love.graphics.setColor(0.9,0.9,0.9,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end
	if self.img then
		love.graphics.draw(self.img, x, y)
	end
end

return IconWidget
