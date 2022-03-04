-- Card

local log = require 'log'

local Util = require 'util'

local Card = {
	-- pack
	-- ord 1 .. 13
	-- suit C, D, H, S
	-- textureId

	-- prone
	-- parent

	-- x
	-- y
	-- src {x, y}
	-- dst {x, y}
	-- lerpStep			current lerp value 0.0 .. 1.0; if < 1.0, card is lerping
	-- lerpStepAmount	the amount a transitioning card moves each tick
	-- lerping			a boolean to save some messy comparisons
	-- dragStart {x,y}

	-- flipStep
	-- flipWidth

	-- directionX, directionY
	-- angle, spin
}
Card.__index = Card

function Card:__tostring()
	return self.textureId
end

function Card.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.pack)=='number')
	-- assert(type(o.suit)=='string')
	-- assert(type(o.ord)=='number')

	o.black = o.suit == '♣' or o.suit == '♠'	-- helps when comparing colors

	-- fictional start point off top of screen
	o.x = 512
	o.y = -128

	o.textureId = string.format('%02u%s', o.ord, o.suit)	-- used as index/key into Card Texture Library

	o.lerping = false
	o.lerpStep = 1.0

	o.flipStep = 0.0

	o.spinning = false

	return setmetatable(o, Card)
end

function Card:getSavable()
	return {pack=self.pack, ord=self.ord, suit=self.suit, prone=self.prone}
end

function Card:setBaizePos(x, y)
	self.x = x
	self.y = y
	self:stopTransition()
--[[
	if not self:dragging() then
		local ssr = self.parent:screenBox()
		if ssr then
			use Util.rectContains()
			if not Util.inRect(self.x, self.y, ssr.x, ssr.y, ssr.width, ssr.height) then
				log.warn('card', tostring(self), 'outside ssr')
			end
		end
	end
]]
end

function Card:screenPos()
	return self.x + _G.BAIZE.dragOffset.x, self.y + _G.BAIZE.dragOffset.y
end

function Card:baizeRect()
	return self.x, self.y, _G.BAIZE.cardWidth, _G.BAIZE.cardHeight
end

function Card:baizeStaticRect()
	if self:dragging() then
		return self.dragStart.x, self.dragStart.y, _G.BAIZE.cardWidth, _G.BAIZE.cardHeight
	else
		return self.x, self.y, _G.BAIZE.cardWidth, _G.BAIZE.cardHeight
	end
end

function Card:screenRect()
	return self.x  + _G.BAIZE.dragOffset.x, self.y  + _G.BAIZE.dragOffset.y, _G.BAIZE.cardWidth, _G.BAIZE.cardHeight
end

function Card:flipUp()
	if self.prone then
		self.prone = false
		self.flipStep = -0.05	-- start by making card narrower
		self.flipWidth = 1.0
	end
end

function Card:flipDown()
	if not self.prone then
		self.prone = true
		self.flipStep = -0.05	-- start by making card narrower
		self.flipWidth = 1.0
	end
end

function Card:flip()
	if self.prone then
		self:flipUp()
	else
		self:flipDown()
	end
end

function Card:flipping()
	return self.flipStep ~= 0.0
end

function Card:transitioning()
	return self.lerping
	-- return self.lerpStep < 1.0 and self.dst and self.src and (self.x ~= self.dst.x or self.y ~= self.dst.y)
end

function Card:stopTransition()
	self.src = nil
	self.dst = nil
	self.lerpStep = 1.0
	self.lerping = false
end

function Card:transitionTo(x, y)

	if self.spinning then
		return
	end

	if self.x == x and self.y == y then
		self:setBaizePos(x, y)
		return
	end

	if self.dst then
		if self.dst.x == x and self.dst.y == y and self.lerpStep < 1.0 then
			return	-- repeat request
		end
	end

	self.src = {x = self.x, y = self.y}
	self.dst = {x = x, y = y}
	self.lerpStep = 0.2	-- starting from 0.0 feels a little laggy
	self.lerpStepAmount = _G.BAIZE.settings.cardTransitionStep
	self.lerping = true
end

function Card:dragging()
	return self.dragStart ~= nil
end

function Card:startDrag()
	if self:transitioning() then
		self.dragStart = self.dst
		self:stopTransition()
	else
		self.dragStart = {x=self.x, y=self.y}
	end
end

function Card:dragBy(dx, dy)
	self:setBaizePos(self.dragStart.x + dx, self.dragStart.y + dy)
end

function Card:cancelDrag()
	self:transitionTo(self.dragStart.x, self.dragStart.y)
	self.dragStart = nil
end

function Card:stopDrag()
	self.dragStart = nil
end

function Card:wasDragged()
	if self.dragStart then
		if self.dragStart.x ~= self.x or self.dragStart.y ~= self.y then
			return true
		end
	end
	return false
end

function Card:startSpinning()
	self.directionX = math.random(-3, 3)
	self.directionY = math.random(-3, 3)
	self.angle = 0
	self.spin = math.random() - 0.5
	self.spinning = true
end

function Card:stopSpinning()
	self.angle = 0
	self.spin = 0
	self.spinning = false
end

function Card:update(dt)
	if self:transitioning() then
		self.lerpStep = self.lerpStep + self.lerpStepAmount
		if self.lerpStep < 1.0 then
			self.x = Util.smootherstep(self.src.x, self.dst.x, self.lerpStep)
			self.y = Util.smootherstep(self.src.y, self.dst.y, self.lerpStep)
		else
			-- we have arrived at our destination
			-- make sure card is in proper place
			-- and terminate any transition
			self:setBaizePos(self.dst.x, self.dst.y)
		end
	end
	if self:flipping() then
		self.flipWidth = self.flipWidth + self.flipStep
		if self.flipWidth <= 0.0 then
			self.flipStep = 0.05 -- now make card wider
		elseif self.flipWidth >= 1.0 then
			-- finished flipping
			self.flipWidth = 1.0
			self.flipStep = 0.0
		end
	end
	if self.spinning then
		self.x = self.x + self.directionX
		self.y = self.y + self.directionY
		self.angle  = self.angle + self.spin
		if self.angle > 360 then
			self.angle = self.angle - 360
		elseif self.angle < 0 then
			self.angle = self.angle + 360
		end
		local windowWidth, windowHeight, _ = love.window.getMode()
		windowWidth = windowWidth - _G.BAIZE.dragOffset.x
		windowHeight = windowHeight - _G.BAIZE.dragOffset.y
		local centerx = self.x + _G.BAIZE.cardWidth / 2
		local centery = self.y + _G.BAIZE.cardHeight / 2
		if (centerx < 0) or (centerx > windowWidth) then
			self.directionX = -self.directionX
			self.spin = math.random() - 0.5
		end
		if (centery < 0) or (centery > windowHeight) then
			self.directionY = -self.directionY
			self.spin = math.random() - 0.5
		end
	end
end

function Card:draw()
	local b = _G.BAIZE
	local x, y = self:screenPos()

	-- very important!: reset color before drawing to canvas to have colors properly displayed
	-- see discussion here: https://love2d.org/forums/viewtopic.php?f=4&p=211418#p211418
	love.graphics.setColor(1,1,1,1)

	local img
	if self.flipStep < 0.0 then
		if self.prone then
			-- card is getting narrower, and it's going to show face down, but show face up
			img = b.cardTextureLibrary[self.textureId]
		else
			-- card is getting narrower, and it's going to show face up, but show face down
			img = b.cardBackTexture
		end
	else
		if self.prone then
			img = b.cardBackTexture
		else
			img = b.cardTextureLibrary[self.textureId]
		end
	end

	if self:flipping() then
		local cw = b.cardWidth
		local scw = cw / self.flipWidth
		love.graphics.draw(img, x, y,
		0,
		self.flipWidth, 1.0,
		(cw - scw) / 2, 0)
	else
		if self:transitioning() then
			local xoffset, yoffset = 2, 2
			-- local xoffset = b.cardWidth / 66
			-- local yoffset = b.cardHeight / 66
			love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
		elseif self:dragging() then
			local xoffset, yoffset = 2, 2
			-- local xoffset = b.cardWidth / 66
			-- local yoffset = b.cardHeight / 66
			love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
			-- this looks intuitively better than "lifting" the card with offset * 2
			-- even though "lifting" it (moving it up/left towards the light source) would be more "correct"
			x = x - xoffset / 2
			y = y - yoffset / 2
		end
		if self.spinning then
			love.graphics.draw(img, x, y, self.angle * math.pi / 180.0, 1.1, 1.1)
		else
			love.graphics.draw(img, x, y)
		end
	end
end

return Card
