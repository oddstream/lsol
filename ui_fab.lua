-- ui_fab

local log = require 'log'

local Util = require 'util'

local FAB = {}
FAB.__index = FAB

function FAB.new(o)
	assert(o.icon)
	assert(o.baizeCmd)

	local fname = 'assets/icons/' .. o.icon .. '.png'
	local imageData = love.image.newImageData(fname)
	local imgIcon
	if not imageData then
		log.error('could not load', fname)
	else
		imgIcon = love.graphics.newImage(imageData)
		o.width = imageData:getWidth() * 2 -- * _G.UI_SCALE
		o.height = imageData:getHeight() * 2 -- * _G.UI_SCALE
		-- log.trace('loaded', fname)
	end

	local canvas = love.graphics.newCanvas(o.width, o.height)
	love.graphics.setCanvas(canvas)
	Util.setColorFromName('UiBackground')
	love.graphics.circle('fill', o.width/2, o.height/2, o.width/2)
	Util.setColorFromName('UiForeground')
	love.graphics.draw(imgIcon, o.width / 4, o.height / 4) --, 0, _G.UI_SCALE, _G.UI_SCALE)
	love.graphics.setCanvas()

	o.texture = canvas
	o.enabled = true
	return setmetatable(o, FAB)
end

-- function FAB:screenPos()
-- 	return self.x, self.y
-- end

function FAB:screenRect()
	return self.x, self.y, self.width, self.height
end

function FAB:startDrag(x, y)
	-- can't drag a FAB
end

function FAB:dragBy(dx, dy)
	-- can't drag a FAB
end

function FAB:stopDrag(x, y)
	-- can't drag a FAB
end

function FAB:layout()
	self.x = (_G.UI_SAFEX + _G.UI_SAFEW) - (self.width * 1.5)
	self.y = (_G.UI_SAFEY + _G.UI_SAFEH) - (self.height * 1.5) - _G.STATUSBARHEIGHT
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
		-- very important!: reset color before drawing to canvas to have colors properly displayed
		-- see discussion here: https://love2d.org/forums/viewtopic.php?f=4&p=211418#p211418
		Util.setColorFromName('UiForeground')
		love.graphics.draw(self.texture, x, y) --, 0, _G.UI_SCALE, _G.UI_SCALE)
	end
end

return FAB
