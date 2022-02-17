-- iconwidget

local log = require 'log'

local Widget = require 'ui_widget'

local IconWidget = {
	-- icon name
	-- baizeCmd and optional param
}
IconWidget.__index = IconWidget
setmetatable(IconWidget, {__index = Widget})

function IconWidget.new(o)
	setmetatable(o, IconWidget)
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
	love.graphics.setColor(1,1,1,1)
	if self.img then
		love.graphics.draw(self.img, self.parent.x + self.x, self.parent.y + self.y)
	end
end

return IconWidget
