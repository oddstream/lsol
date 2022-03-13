-- radio button

local log = require 'log'

local Widget = require 'ui_widget'
local Util = require 'util'

local Radio = {}
Radio.__index = Radio
setmetatable(Radio, {__index = Widget})

function Radio.new(o)
	assert(o.text)
	assert(o.var)
	assert(o.grp)

	local fname = 'assets/icons/radio_button_checked.png'
	local imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.imgWidth = imageData:getWidth()
		o.imgHeight = imageData:getHeight()
		o.imgChecked = love.graphics.newImage(imageData)
	end

	fname = 'assets/icons/radio_button_unchecked.png'
	imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.imgUnchecked = love.graphics.newImage(imageData)
	end

	o.baizeCmd = 'toggleRadio'
	o.param = o
	o.enabled = true

	-- check and img will be updated when drawer is shown by showSettingsDrawer
	-- supply some values for now, so layout works
	o.checked = true
	o.img = o.imgChecked

	return setmetatable(o, Radio)
end

function Radio:draw()
	local cx, cy, cw, ch = self.parent:screenRect()
	local wx, wy, ww, wh = self:screenRect()

	-- TODO consider using scissors
	if wy < cy then
		return
	end
	if wy + wh > cy + ch then
		return
	end

	love.graphics.setFont(self.parent.font)
	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			love.graphics.setColor(1,1,1,1)
			if love.mouse.isDown(1) then
				wx = wx + 2
				wy = wy + 2
			end
		else
			love.graphics.setColor(1,1,1,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end

	love.graphics.draw(self.img, wx, wy)

	if self.text then
		love.graphics.print(self.text, wx + 36 + 4, wy + 2)
	end

	if _G.BAIZE.settings.debug then
		love.graphics.rectangle('line', wx, wy, ww, wh)
	end

end

return Radio
