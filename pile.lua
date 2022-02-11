-- pile
-- virtual base class for Stock, Waste, Foundation, Tableau, Reserve, Cell

local log = require 'log'

local Pile = {}
Pile.__index = Pile

function Pile.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.x)=='number')
	-- assert(type(o.y)=='number')
	setmetatable(o, Pile)
    o.slot = {x = o.x, y = o.y}
	o.cards = {}
	o.faceFanFactorH = 4
	o.faceFanFactorV = 3
	o.backFanFactorH = 5
	o.backFanFactorV = 5
	return o
end

function Pile:setBaizePos(x, y)
	self.x, self.y = x, y
	if self.fanType == 'FAN_DOWN3' then
		self.pos1 = {x=x, y=y + (_G.BAIZE.cardHeight / self.faceFanFactorV)}
		self.pos2 = {x=x, y=y + (_G.BAIZE.cardHeight / self.faceFanFactorV) + (_G.BAIZE.cardHeight / self.faceFanFactorV)}
	elseif self.fanType == 'FAN_LEFT3' then
		self.pos1 = {x=x - (_G.BAIZE.cardHeight / self.faceFanFactorH), y=y}
		self.pos2 = {x=x - (_G.BAIZE.cardHeight / self.faceFanFactorH)  + (_G.BAIZE.cardHeight / self.faceFanFactorH), y=y}
	elseif self.fanType == 'FAN_RIGHT3' then
		self.pos1 = {x=x + (_G.BAIZE.cardHeight / self.faceFanFactorH), y=y}
		self.pos2 = {x=x + (_G.BAIZE.cardHeight / self.faceFanFactorH)  + (_G.BAIZE.cardHeight / self.faceFanFactorH), y=y}
	end
end

function Pile:getScreenPos()
	return self.x + _G.BAIZE.dragOffset.x, self.y + _G.BAIZE.dragOffset.y
end

function Pile:baizeRect()
	return {x1=self.x, y1=self.y, x2=self.x + _G.BAIZE.cardWidth, y2=self.y + _G.BAIZE.cardHeight}
end

function Pile:screenRect()
	local rect = self:baizeRect()
	return {
		x1 = rect.x1 + _G.BAIZE.dragOffset.x,
		y1 = rect.y1 + _G.BAIZE.dragOffset.y,
		x2 = rect.x2 + _G.BAIZE.dragOffset.x,
		y2 = rect.y2 + _G.BAIZE.dragOffset.y,
	}
end

function Pile:fannedBaizeRect()
	local r = self:baizeRect()
	if #self.cards > 1 and self.fanType ~= 'FAN_NONE' then
		local c = self:peek()
		local cRect = c:baizeRect()
		if self.fanType == 'FAN_DOWN' or self.fanType == 'FAN_DOWN3' then
			r.y2 = cRect.y2
		elseif self.fanType == 'FAN_RIGHT' or self.fanType == 'FAN_RIGHT3' then
			r.x2 = cRect.x2
		elseif self.fanType == 'FAN_LEFT' or self.fanType == 'FAN_LEFT3' then
			r.x1 = cRect.x1	-- TODO verify this is correct
		end
	end
	return r
end

function Pile:posAfter(c)
	if (c == nil) or (#self.cards == 0) then
		return self.x, self.y
	end
	local x, y
	if c:transitioning() then
		x, y = c.dst.x, c.dst.y
	else
		x, y = c.x, c.y
	end
	if self.fanType == 'FAN_NONE' then
		-- do nothing
	elseif self.fanType == 'FAN_DOWN' then
		if c.prone then
			y = y + (_G.BAIZE.cardHeight / self.backFanFactorV)
		else
			y = y + (_G.BAIZE.cardHeight / self.faceFanFactorV)
		end
	elseif self.fanType == 'FAN_RIGHT' then
		if c.prone then
			x = x + (_G.BAIZE.cardWidth / self.backFanFactorH)
		else
			x = x + (_G.BAIZE.cardWidth / self.faceFanFactorH)
		end
	elseif self.fanType == 'FAN_LEFT' then
		if c.prone then
			x = x - (_G.BAIZE.cardWidth / self.backFanFactorH)
		else
			x = x - (_G.BAIZE.cardWidth / self.faceFanFactorH)
		end
	elseif self.fanType == 'FAN_RIGHT3' or self.fanType == 'FAN_LEFT3' or self.fanType == 'FAN_DOWN3' then
		if #self.cards == 0 then
			-- do nothing (can't ever happen because we know pile is not empty)
		elseif #self.cards == 1 then
			x, y = self.pos1.x, self.pos1.y
		elseif #self.cards == 2 then
			x, y = self.pos2.x, self.pos2.y
		else
			x, y = self.pos2.x, self.pos2.y	-- incoming card at slot 2
			-- top card needs to move from slot 2 to slot 1
			local i = #self.cards
			self.cards[i]:transitionTo(self.pos1.x, self.pos1.y)
			-- mid card needs to move from slot 1 to slot 0
			i = i - 1
			self.cards[i]:transitionTo(self.x, self.y)
			-- remaining cards need to transition to slot 0
			while i > 0 do
				self.cards[i]:transitionTo(self.x, self.y)
				i = i - 1
			end
		end
	end
	return x, y
end

function Pile:refan(fn)
	if #self.cards == 0 then
		return
	end
	local doFan3 = false
	if self.fanType == 'FAN_NONE' then
		for _, c in ipairs(self.cards) do
			fn(c, self.x, self.y)
		end
	elseif self.fanType == 'FAN_DOWN' or self.fanType == 'FAN_RIGHT' or self.fanType == 'FAN_LEFT' then
		local x, y = self.x, self.y
		local i = 1
		for _, c in ipairs(self.cards) do
			fn(c, x, y)
			x, y = self:posAfter(self.cards[i])
			i = i + 1
		end
	elseif self.fanType == 'FAN_DOWN3' or self.fanType == 'FAN_RIGHT3' or self.fanType == 'FAN_LEFT3' then
		for _, c in ipairs(self.cards) do
			fn(c, self.x, self.y)
		end
		doFan3 = true
	end
	if doFan3 then
		if #self.cards == 0 then
			-- do nothing, already screened out
		elseif #self.cards == 1 then
			-- do nothing
		elseif #self.cards == 2 then
			-- transition the top card
			local c = self.cards[2]
			fn(c, self.pos1.x, self.pos1.y)
		else
			-- transition the top two cards
			local c = self.cards[#self.cards]
			fn(c, self.pos2.x, self.pos2.y)
			c = self.cards[#self.cards - 1]
			fn(c, self.pos1.x, self.pos1.y)
		end
	end
end

function Pile:peek()
	return self.cards[#self.cards]
end

function Pile:pop()
	local c = table.remove(self.cards)
	if c then c.parent = nil end
	return c
end

function Pile:push(c)
	local x, y = self:posAfter(self:peek())
	table.insert(self.cards, c)
	c.parent = self
	c:transitionTo(x, y)
	-- c:setBaizePos(x, y)
end

function Pile:flipUpExposedCard()
	if self.category ~= 'Stock' then
		local c = self:peek()
		if c and c.prone then
			c:flipUp()
		end
	end
end

function Pile:indexOf(card)
	for i, c in ipairs(self.cards) do
		if c == card then
			return i
		end
	end
	return 0
end

function Pile:canMoveTail(tail)
--[[
	if tail[1].parent.category ~= 'Stock' then
		for _, c in ipairs(tail) do
			if c.prone then
				return 'Cannot move a face down card'
			end
		end
	end
]]
	-- don't test for MOVE_ANY or MOVE_ONE_PLUS
	-- don't know destination, so we allow MOVE_ONE_PLUS as MOVE_ANY at the moment
	if self.moveType == 'MOVE_NONE' then
		return 'Cannot move a card from that pile'
	elseif self.moveType == 'MOVE_ONE' then
		if #tail > 1 then
			return 'Can only move one card from that pile'
		end
	elseif self.moveType == 'MOVE_ONE_OR_ALL' then
		if not (#tail == 1 or #tail == #self.cards) then
			return 'Only move one card, or the whole pile'
		end
	end
	return nil
end

function Pile:makeTail(c)
	for i=1, #self.cards do
		-- find the first card
		if self.cards[i] == c then
			-- copy rest of cards
			local tail = {}
			for j=i, #self.cards do
				table.insert(tail, self.cards[j])
			end
			return tail
		end
	  end
	return nil
end

-- vtable functions

function Pile.canAcceptCard(c)
	log.warning('base canAcceptCard should not be called')
	return nil
end

function Pile.canAcceptTail(c)
	log.warning('base canAcceptTail should not be called')
	return nil
end

function Pile:tailTapped(tail)
	log.trace('Pile.tailTapped')
	-- TODO
	tail[1]:flip()
end

function Pile:collect()
	log.warning('base collect should not be called')
end

function Pile:conformant()
	log.warning('base conformat should not be called')
end

function Pile:complete()
	log.warning('base complete should not be called')
end

function Pile:unsortedPairs()
	log.warning('base unsortedPairs should not be called')
end

-- game engine functions

function Pile:update(dt)
	for _, c in ipairs(self.cards) do
		c:update(dt)
	end
end

function Pile:drawStaticCards()
	for _, c in ipairs(self.cards) do
		if not (c:transitioning() or c:flipping() or c:dragging()) then
			c:draw()
		end
	end
end

function Pile:drawTransitioningCards()
	for _, c in ipairs(self.cards) do
		if c:transitioning() then
			c:draw()
		end
	end
end

function Pile:drawFlippingCards()
	for _, c in ipairs(self.cards) do
		if c:flipping() then
			c:draw()
		end
	end
end

function Pile:drawDraggingCards()
	for _, c in ipairs(self.cards) do
		if c:dragging() then
			c:draw()
		end
	end
end

function Pile:draw()
	local b = _G.BAIZE
	local x, y = self:getScreenPos()

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
	if self.label then
		love.graphics.setFont(b.labelFont)
		love.graphics.print(self.label,
			x + b.cardWidth / 2,
			y + b.cardHeight / 2,
			0,	-- orientation
			1,	-- x scale
			1,	-- y scale
			b.labelFont:getWidth(self.label) / 2,
			b.labelFont:getHeight(self.label) / 2)
	end
end

return Pile
