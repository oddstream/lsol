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
	-- dragStart {x,y}

	-- flipDirection
	-- flipWidth
	-- flipStartTime

	-- directionX, directionY
	-- degrees, spin
}
Card.__index = Card

local LERP_SECONDS = 0.5
local FLIP_SECONDS = LERP_SECONDS / 3
local SPIN_SECONDS = LERP_SECONDS * 2

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

	o.textureId = Util.cardTextureId(o.ord, o.suit)	-- used as index/key into Card Texture Library

	-- cards have to flip faster than they transition
	-- remember that flipping happens in two steps
	-- so three times faster would do, but four times faster seems snappier
	o.flipWidth = 1.0	-- lerps from 1.0 to 0.0 (then from 0.0 to 1.0)
	o.flipDirection = 0	-- -1 narrower, 0 statis, +1 wider

	o.spinDegrees = 0
	o.spinDelaySeconds = 0.0

	return setmetatable(o, Card)
end

function Card:getSavable()
	return {pack=self.pack, ord=self.ord, suit=self.suit, prone=self.prone}
end

function Card:setBaizePos(x, y)
	self.x = x
	self.y = y
	self:stopTransition()
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

function Card:_startFlip()
	self.flipWidth = 1.0
	self.flipDirection = -1	-- start by making card narrower
	self.flipStartTime = love.timer.getTime()
end

function Card:flipUp()
	if self.prone then
		self.prone = false
		self:_startFlip()
	end
end

function Card:flipDown()
	if not self.prone then
		self.prone = true
		self:_startFlip()
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
	return self.flipDirection ~= 0.0
end

function Card:transitioning()
	return self.dst ~= nil
end

function Card:nearEnough()
	return math.abs(self.x - self.dst.x) < 1.0 and math.abs(self.y - self.dst.y) < 1.0
	-- return self.x == self.dst.x and self.y == self.dst.y
end

function Card:stopTransition()
	self.src = nil
	self.dst = nil
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
		if self:nearEnough() then
			self:setBaizePos(x, y)
			return	-- repeat request
		end
	end

	self.src = {x = self.x, y = self.y}
	self.dst = {x = x, y = y}

	self.lerpStartTime = love.timer.getTime()
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
	self.degrees = 0.0
	repeat
		self.spinDegrees = math.random() - 0.5
	until self.spinDegress ~= 0.0
	self.spinDelaySeconds = SPIN_SECONDS
end

function Card:stopSpinning()
	self.degrees = 0.0
	self.spinDegrees = 0.0
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
		if not self:nearEnough() then
			-- Calculate the fraction of the total duration that has passed
			local t = (love.timer.getTime() - self.lerpStartTime) / LERP_SECONDS
			self.x = Util.smoothstep(self.src.x, self.dst.x, t)
			self.y = Util.smoothstep(self.src.y, self.dst.y, t)
			-- local rate = 10.0	-- too low gives settling flicker
			-- https://www.gamedeveloper.com/programming/improved-lerp-smoothing-
			-- value = lerp(target, value, exp2(-rate*deltaTime))
			-- exp2(x) is 2 ^ x
			-- ... rate controls how quickly the value converges on the target.
			-- With a rate of 1.0, the value will move halfway to the target each second.
			-- If you double the rate, the value will move in twice as fast.
			-- If you halve the rate, it will move in half as fast.
			--
			-- Even better, it’s frame rate independent.
			-- If you lerp() this way 60 times with a delta time of 1/60 s,
			-- it will be the same result as 30 times with 1/30 s, or once with 1 s.
			-- No fixed time step is needed, or the jittery movement it causes.
			-- self.x = Util.lerp(self.dst.x, self.x, math.pow(2, -rate * dt_seconds))
			-- self.y = Util.lerp(self.dst.y, self.y, math.pow(2, -rate * dt_seconds))
		else
			-- we have arrived at our destination
			-- make sure card is in proper place
			-- and terminate any transition
			self:setBaizePos(self.dst.x, self.dst.y)	-- also stops lerping
		end
	end

	if self:flipping() then
		-- Calculate the fraction of the total duration that has passed
		local t = (love.timer.getTime() - self.flipStartTime) / FLIP_SECONDS
		if self.flipDirection < 0 then
			self.flipWidth = Util.lerp(1.0, 0.0, t)
			if self.flipWidth <= 0.0 then
				-- reverse direction, make card bigger
				self.flipDirection = 1
				self.flipStartTime = love.timer.getTime()
			end
		elseif self.flipDirection > 0 then
			self.flipWidth = Util.lerp(0.0, 1.0, t)
			if self.flipWidth >= 1.0 then
				-- finished
				self.flipDirection = 0
			end
		end
	end

	if self:spinning() then
		if self.spinDelaySeconds > 0 then
			self.spinDelaySeconds = self.spinDelaySeconds - dt_seconds
			if self.spinDelaySeconds < 0 then
				-- while waiting to spin, cards can carry on lerping
				-- but must stop when spinning starts
				self:stopTransition()
			end
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
	if self.flipDirection < 0.0 then
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

	if self:spinning() then
		love.graphics.draw(img, x, y, self.degrees * math.pi / 180.0)
	elseif self:flipping() then
		local cw = b.cardWidth
		local scw = cw / self.flipWidth
		love.graphics.draw(img, x, y,
			0,
			self.flipWidth, 1.0,
			(cw - scw) / 2, 0)
	elseif self:transitioning() then
		local xoffset, yoffset = 1, 1
		love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
		love.graphics.draw(img, x, y)
	elseif self:dragging() then
		local xoffset, yoffset = 2, 2
		-- local xoffset = b.cardWidth / 66
		-- local yoffset = b.cardHeight / 66
		love.graphics.draw(b.cardShadowTexture, x + xoffset, y + yoffset)
		-- this looks intuitively better than "lifting" the card with offset * 2
		-- even though "lifting" it (moving it up/left towards the light source) would be more "correct"
		x = x - xoffset / 2
		y = y - yoffset / 2
		-- love.graphics.setColor(1, 0.95, 1, 1)
		love.graphics.draw(img, x, y)
		-- love.graphics.setColor(1,1,1,1)
	else
--[[
		if self:shaking() then
			x = x + self.shakeOffset
		end
]]
		love.graphics.draw(img, x, y)

		if b.showMovable and self.movable > 0 then
			-- BUG after mirror baize when complete "cannot undo a completed game"
			-- self.movable will be nil

			Util.setColorFromSetting('hintColor')
			love.graphics.setLineWidth(self.movable)
			love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
			love.graphics.setColor(1,1,1,1)
		end
	end

end

return Card
