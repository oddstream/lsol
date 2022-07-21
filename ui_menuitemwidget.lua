-- menuitemwidget

local log = require 'log'

local Widget = require 'ui_widget'
local Util = require 'util'

local MenuItemWidget = {
	-- icon name
	-- baizeCmd and optional param
}
MenuItemWidget.__index = MenuItemWidget
setmetatable(MenuItemWidget, {__index = Widget})

function MenuItemWidget:hitRect()
	-- override base hitRect()
	local x = self.parent.x + self.parent.dragOffset.x
	local y = self.parent.y + self.parent.dragOffset.y + self.y
	return x, y, self.parent.width, self.height
end

function MenuItemWidget.new(o)
	o.enabled = true

	if o.icon then
		local fname = 'assets/icons/' .. o.icon .. '.png'
		local imageData = love.image.newImageData(fname)
		if not imageData then
			log.error('could not load', fname)
		else
			o.img = love.graphics.newImage(imageData)
			assert(o.img)
			o.imgWidth = imageData:getWidth() * _G.UI_SCALE
			o.imgHeight = imageData:getHeight() * _G.UI_SCALE
			-- log.trace('loaded', fname, o.imgWidth, o.imgHeight)
		end
	end
	return setmetatable(o, MenuItemWidget)
end

function MenuItemWidget:draw()
	-- very important!: reset color before drawing to canvas to have colors properly displayed
	local _, cy, _, ch = self.parent:screenRect()
	local wx, wy, ww, wh = self:screenRect()

	if wy < cy then
		return
	end
	if wy + wh > cy + ch then
		return
	end

	if self.backColor then
		Util.setColorFromName(self.backColor)
		local x, _, w, _ = self.parent:screenRect()
		local _, y, _, h = self:screenRect()
		-- widgets are vertically at 36 pixel intervals
		local iconSize = 36 * _G.UI_SCALE
		y = y - (iconSize - h) / 2
		h = h + (iconSize - h)
		love.graphics.rectangle('fill', x, y, w, h)
	end

	if _G.SETTINGS.debug then
		Util.setColorFromName('UiGrayedOut')
		love.graphics.setLineWidth(1)
		love.graphics.rectangle('line', wx, wy, ww, wh)
	end

	local textColor = self.textColor or 'UiForeground'

	if self.enabled then
		local mx, my = love.mouse.getPosition()
		if self.baizeCmd and Util.inRect(mx, my, self:screenRect()) then
			Util.setColorFromName(textColor)
			if love.mouse.isDown(1) then
				wx = wx + 2
				wy = wy + 2
			end
		else
			Util.setColorFromName(textColor)
		end
	else
		Util.setColorFromName('UiGrayedOut')
	end

	local textOffsetX = 0
	local textOffsetY = 0
	if self.img then
		love.graphics.draw(self.img, wx, wy, 0, _G.UI_SCALE, _G.UI_SCALE)
		-- TODO get rid of these magic numbers
		textOffsetX = self.imgWidth + 8
		textOffsetY = 3
	end

	if self.text then
		love.graphics.setFont(self.parent.font)
		love.graphics.print(self.text,
			wx,
			wy,
			0,		-- orientation in radians
			1,		-- scale x
			1,		-- scale y
			-textOffsetX,
			-textOffsetY
		)
	end

end

return MenuItemWidget
