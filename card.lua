-- Card

local Util = require 'util'

local Card = {
	-- pack
    -- ord 1 .. 13
    -- suit C, D, H, S
	-- savableId
    -- textureId

    -- prone
    -- parent

	-- x
	-- y
	-- src {x, y}
	-- dst {x, y}
	-- lerpStep			current lerp value 0.0 .. 1.0; if < 1.0, card is lerping
	-- lerpStepAmount	the amount a transitioning card moves each tick

	-- dragStart {x,y}
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
	setmetatable(o, Card)

	-- fictional start point off top of screen
	o.x = 512
	o.y = -128

	o.savableId = string.format('%u01%02u%s', o.pack, o.ord, o.suit)	-- used when saving card in undoStack
	o.textureId = string.format('%02u%s', o.ord, o.suit)	-- used as index/key into Card Texture Library
	o.lerpStep = 1.0	-- not transitioning

	return o
end

function Card:setBaizePos(x, y)
	self.x = x
	self.y = y
	self:stopTransition()
end

function Card:getScreenPos()
	return self.x + _G.BAIZE.dragOffset.x, self.y + _G.BAIZE.dragOffset.y
end

function Card:baizeRect()
	return {x1=self.x, y1=self.y, x2=self.x + _G.BAIZE.cardWidth, y2=self.y + _G.BAIZE.cardHeight}
end

function Card:screenRect()
	local rect = self:baizeRect()
	return {
		x1 = rect.x1 + _G.BAIZE.dragOffset.x,
		y1 = rect.y1 + _G.BAIZE.dragOffset.y,
		x2 = rect.x2 + _G.BAIZE.dragOffset.x,
		y2 = rect.y2 + _G.BAIZE.dragOffset.y,
	}
end

function Card:transitioning()
	return self.lerpStep < 1.0 and self.dst and self.src and (self.x ~= self.dst.x or self.y ~= self.dst.y)
end

function Card:stopTransition()
	self.src = nil
	self.dst = nil
	self.lerpStep = 1.0
end

function Card:transitionTo(x, y)
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
	self.lerpStep = 0.1	-- starting from 0.0 feels a little laggy
	self.lerpStepAmount = 0.025
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
end

function Card:draw()
	local x, y = self:getScreenPos()

	-- very important!: reset color before drawing to canvas to have colors properly displayed
    -- see discussion here: https://love2d.org/forums/viewtopic.php?f=4&p=211418#p211418
	love.graphics.setColor(1,1,1,1)

	if self.prone then
		love.graphics.draw(_G.BAIZE.cardBackTexture, x, y)
	else
		love.graphics.draw(_G.BAIZE.cardTextureLibrary[self.textureId], x, y)
	end
end

return Card
