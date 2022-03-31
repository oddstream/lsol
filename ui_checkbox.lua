-- check box

local log = require 'log'

local Widget = require 'ui_widget'
local Util = require 'util'

local Checkbox = {}
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
		o.imgWidth = imageData:getWidth() * _G.UI_SCALE
		o.imgHeight = imageData:getHeight() * _G.UI_SCALE
		o.imgChecked = love.graphics.newImage(imageData)
	end

	fname = 'assets/icons/check_box_outline_blank.png'
	imageData = love.image.newImageData(fname)
	if not imageData then
		log.error('could not load', fname)
	else
		o.imgUnchecked = love.graphics.newImage(imageData)
	end

	o.baizeCmd = 'toggleCheckbox'
	o.param = o.var
	o.enabled = true

	-- check and img will be updated when drawer is shown by showSettingsDrawer
	-- supply some values for now, so layout works
	o.checked = true
	o.img = o.imgChecked

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
			love.graphics.setColor(1,1,1,1)
		end
	else
		love.graphics.setColor(0.5,0.5,0.5,1)
	end

	love.graphics.draw(self.img, wx, wy, 0, _G.UI_SCALE, _G.UI_SCALE)

	if self.text then
		love.graphics.print(self.text, wx + self.imgWidth + 8, wy + 3)
	end

	if _G.BAIZE.settings.debug then
		love.graphics.setColor(0.5,0.5,0.5,1)
		love.graphics.rectangle('line', wx, wy, ww, wh)
	end

end

return Checkbox
