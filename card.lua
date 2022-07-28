-- Card

-- local log = require 'log'

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
	-- degrees, spin

	-- lerpCount
	-- lerpTime
	-- lerpStartTime
	-- flipCount
	-- flipTime
	-- flipStartTime
}
Card.__index = Card

local measureTime = true	-- debug for measuring transition and flip time

function Card:__tostring()
	return self.textureId
end

function Card.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.pack)=='number')
	-- assert(type(o.suit)=='string')
	-- assert(type(o.ord)=='number')

	if o.suit == '♣' or o.suit == '♠' then
		o.twoColor = 'black'
	else
		o.twoColor = 'red'
	end

	-- fictional start point off top of screen
	o.x = 512
	o.y = -128

	o.textureId = string.format('%02u%s', o.ord, o.suit)	-- used as index/key into Card Texture Library

	o.lerping = false
	o.lerpStep = 1.0

	o.flipStep = 0.0
	-- cards have to flip faster than they transition
	-- remember that flipping happens in two steps
	-- so three times faster would do, but four times faster seems snappier
	-- with cardTransitionStep at 0.02, and flipStepAmount at 0.08,
	-- average transitions take 0.64ms, flips take 0.39ms
	o.flipStepAmount = _G.SETTINGS.cardTransitionStep * 4

	o.spinDegrees = 0
	o.spinDelaySeconds = 0.0

	if measureTime then
		o.flipTime = 0.0
		o.flipCount = 0
		o.lerpTime = 0.0
		o.lerpCount = 0
	end

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
		self.flipStep = -self.flipStepAmount	-- start by making card narrower
		self.flipWidth = 1.0
		if measureTime then
			self.flipStartTime = love.timer.getTime()
		end
	end
end

function Card:flipDown()
	if not self.prone then
		self.prone = true
		self.flipStep = -self.flipStepAmount	-- start by making card narrower
		self.flipWidth = 1.0
		if measureTime then
			self.flipStartTime = love.timer.getTime()
		end
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

	if self:spinning() then
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
	self.lerpStepAmount = _G.SETTINGS.cardTransitionStep
	self.lerping = true

	if measureTime then
		self.lerpStartTime = love.timer.getTime()
	end
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
	self.degrees = 0
	self.spinDegrees = math.random() - 0.5
	self.spinDelaySeconds = 2.0
end

function Card:stopSpinning()
	self.degrees = 0
	self.spinDegrees = 0
end

function Card:spinning()
	return self.spinDegrees ~= 0
end

--[[
function Card:shake()
	self.shakeExtent = math.ceil((_G.BAIZE.cardWidth / 25))
	self.shakeDst = self.x + self.shakeExtent
	self.shakeOffset = 0
	print('shake', tostring(self))
end

function Card:shaking()
	return self.shakeExtent ~= nil	-- doubles up as a flag
end
]]

function Card:update(dt_seconds)
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
			if measureTime then
				self.lerpTime = self.lerpTime + (love.timer.getTime() - self.lerpStartTime)
				self.lerpCount = self.lerpCount + 1
			end
		end
	end
	if self:flipping() then
		self.flipWidth = self.flipWidth + self.flipStep
		if self.flipWidth <= 0.0 then
			self.flipStep = self.flipStepAmount -- now make card wider
		elseif self.flipWidth >= 1.0 then
			-- finished flipping
			self.flipWidth = 1.0
			self.flipStep = 0.0
			if measureTime then
				self.flipTime = self.flipTime + (love.timer.getTime() - self.flipStartTime)
				self.flipCount = self.flipCount + 1
			end
		end
	end
	if self:spinning() then
		if self.spinDelaySeconds > 0 then
			self.spinDelaySeconds = self.spinDelaySeconds - dt_seconds
		else
			self.x = self.x + self.directionX
			self.y = self.y + self.directionY
			self.degrees  = self.degrees + self.spinDegrees
			if self.degrees > 360 then
				self.degrees = self.degrees - 360
			elseif self.degrees < 0 then
				self.degrees = self.degrees + 360
			end
			-- use the whole window, not just the safe area
			local windowWidth, windowHeight, _ = love.window.getMode()
			windowWidth = windowWidth - _G.BAIZE.dragOffset.x
			windowHeight = windowHeight - _G.BAIZE.dragOffset.y
			local centerx = self.x + _G.BAIZE.cardWidth / 2
			local centery = self.y + _G.BAIZE.cardHeight / 2
			if (centerx < 0) or (centerx > windowWidth) then
				self.directionX = -self.directionX
				self.spinDegrees = math.random() - 0.5
			end
			if (centery < 0) or (centery > windowHeight) then
				self.directionY = -self.directionY
				self.spinDegrees = math.random() - 0.5
			end
		end
	end
--[[
	if self:shaking() then
		-- move to the right, then to the left, then back to center
		if self.shakeDst > 0 then
			if self.shakeOffset >= self.shakeExtent then
				self.shakeDst = -self.shakeExtent
			else
				self.shakeOffset = self.shakeOffset + 1
			end
		elseif self.shakeDst < 0 then
			if self.shakeOffset <= -self.shakeExtent then
				self.shakeDst = 0
			else
				self.shakeOffset = self.shakeOffset - 1
			end
		else	-- shakeDst must be 0
			if self.shakeOffset == 0 then
				self.shakeExtent = nil	-- finished shaking
			else
				self.shakeOffset = self.shakeOffset + 1
			end
		end
	end
]]
end

function Card:draw()
--[[
	if self.prone then
		if not self:transitioning() then
			if not self:spinning() then
				-- always draw spinning and moving cards
				local pile = self.parent
				local n = #pile.cards
				if n > 2 and pile.fanType == 'FAN_NONE' then
					-- only draw the top two cards as an optimization and to avoid corner artifact
					if not (self == pile.cards[n] or self == pile.cards[n-1]) then
						return
					end
				end
			end
		end
	end
]]
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

	local function drawCard()
		love.graphics.draw(img, x, y)
		if self.movable > 0 and b.showMovable then
			-- love.graphics.setColor(0,0,0,0.1)
			-- love.graphics.rectangle('fill', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
			Util.setColorFromSetting('hintColor')
			love.graphics.setLineWidth(self.movable)
			love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
		end
	end

	if self:spinning() then
		if self.spinDelaySeconds > 0 then
			love.graphics.draw(img, x, y)
		else
			love.graphics.draw(img, x, y, self.degrees * math.pi / 180.0, 1.25, 1.25)
		end
	elseif self:flipping() then
		local cw = b.cardWidth
		local scw = cw / self.flipWidth
		love.graphics.draw(img, x, y,
			0,
			self.flipWidth, 1.0,
			(cw - scw) / 2, 0)
	elseif self:transitioning() then
		local xoffset, yoffset = 2, 2
		-- local xoffset = b.cardWidth / 66
		-- local yoffset = b.cardHeight / 66
		love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
		drawCard()
	elseif self:dragging() then
		local xoffset, yoffset = 2, 2
		-- local xoffset = b.cardWidth / 66
		-- local yoffset = b.cardHeight / 66
		love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
		-- this looks intuitively better than "lifting" the card with offset * 2
		-- even though "lifting" it (moving it up/left towards the light source) would be more "correct"
		x = x - xoffset / 2
		y = y - yoffset / 2
		drawCard()
	else
--[[
		if self:shaking() then
			x = x + self.shakeOffset
		end
]]
		drawCard()
	end

end

return Card
