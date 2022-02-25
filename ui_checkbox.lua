-- textwidget

local log = require 'log'

local Widget = require 'ui_widget'
local Util = require 'util'

local Checkbox = {
	-- text
	-- _G.BAIZE.setting
}
Checkbox.__index = Checkbox
setmetatable(Checkbox, {__index = Widget})

function Checkbox.new(o)
	assert(o.text)
	assert(o.var)

	local fname = 'assets/icons/check_box.png'
	local imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.imgWidth = imageData:getWidth()
		o.imgHeight = imageData:getHeight()
		o.imgChecked = love.graphics.newImage(imageData)
	end

	fname = 'assets/icons/check_box_outline_blank.png'
	imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.imgUnchecked = love.graphics.newImage(imageData)
	end

	o.baizeCmd = 'toggleSetting'
	o.param = o.var
	o.enabled = true
	return setmetatable(o, Checkbox)
end

function Checkbox:draw()
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
			love.graphics.setColor(0.9,0.9,0.9,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end
	if self.checked then
		love.graphics.draw(self.imgChecked, wx, wy)
	else
		love.graphics.draw(self.imgUnchecked, wx, wy)
	end
	wx = wx + self.imgWidth + 3
	wy = wy + 3 -- TODO
	if self.text then
		love.graphics.print(self.text, wx, wy)
	end
end

return Checkbox
