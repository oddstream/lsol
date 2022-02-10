-- pile
-- virtual base class for Stock, Waste, Foundation, Tableau, Reserve, Cell

local Pile = {}
Pile.__index = Pile

function Pile.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.x)=='number')
	-- assert(type(o.y)=='number')
	setmetatable(o, Pile)
    o.slot = {x = o.x, y = o.y}
	o.cards = {}
	o.label = ''
	o.faceFanFactor = 3
	o.backFanFactor = 4
	return o
end

function Pile:setBaizePos(x, y)
	self.x, self.y = x, y
	if self.fanType == 'FAN_DOWN3' then
		self.pos1 = {x=x, y=y + (_G.BAIZE.cardHeight / self.faceFanFactor)}
		self.pos2 = {x=x, y=y + (_G.BAIZE.cardHeight / self.faceFanFactor) + (_G.BAIZE.cardHeight / self.faceFanFactor)}
	elseif self.fanType == 'FAN_LEFT3' then
		self.pos1 = {x=x - (_G.BAIZE.cardHeight / self.faceFanFactor), y=y}
		self.pos2 = {x=x - (_G.BAIZE.cardHeight / self.faceFanFactor)  + (_G.BAIZE.cardHeight / self.faceFanFactor), y=y}
	elseif self.fanType == 'FAN_RIGHT3' then
		self.pos1 = {x=x + (_G.BAIZE.cardHeight / self.faceFanFactor), y=y}
		self.pos2 = {x=x + (_G.BAIZE.cardHeight / self.faceFanFactor)  + (_G.BAIZE.cardHeight / self.faceFanFactor), y=y}
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
			y = y + (_G.BAIZE.cardHeight / self.backFanFactor)
		else
			y = y + (_G.BAIZE.cardHeight / self.faceFanFactor)
		end
	elseif self.fanType == 'FAN_RIGHT' then
		if c.prone then
			x = x + (_G.BAIZE.cardWidth / self.backFanFactor)
		else
			x = x + (_G.BAIZE.cardWidth / self.faceFanFactor)
		end
	elseif self.fanType == 'FAN_LEFT' then
		if c.prone then
			x = x - (_G.BAIZE.cardWidth / self.backFanFactor)
		else
			x = x - (_G.BAIZE.cardWidth / self.faceFanFactor)
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
	print('ERROR base canAcceptCard should not be called')
	return true, nil
end

function Pile.canAcceptTail(c)
	print('ERROR base canAcceptTail should not be called')
	return true, nil
end

function Pile:tailTapped(tail)
	print('TRACE Pile.tailTapped')
	-- TODO
end

function Pile:collect()
	print('ERROR base collect should not be called')
end

function Pile:conformant()
	print('ERROR base conformat should not be called')
end

function Pile:complete()
	print('ERROR base complete should not be called')
end

function Pile:unsortedPairs()
	print('ERROR base unsortedPairs should not be called')
end

-- game engine functions

function Pile:update(dt)
	for _, c in ipairs(self.cards) do
		c:update(dt)
	end
end

function Pile:draw()
	local b = _G.BAIZE
	local x, y = self:getScreenPos()

	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
	if self.label then
		love.graphics.setFont(_G.BAIZE.labelFont)
		love.graphics.print(self.label,
			x + _G.BAIZE.cardWidth / 2,
			y + _G.BAIZE.cardHeight / 2,
			0,	-- orientation
			1,	-- x scale
			1,	-- y scale
			_G.BAIZE.labelFont:getWidth(self.label) / 2,
			_G.BAIZE.labelFont:getHeight(self.label) / 2)
	elseif self.rune then
		love.graphics.setFont(_G.BAIZE.runeFont)
		love.graphics.print(self.rune,
			x + _G.BAIZE.cardWidth / 2,
			y + _G.BAIZE.cardHeight / 2,
			0,	-- orientation
			1,	-- x scale
			1,	-- y scale
			_G.BAIZE.runeFont:getWidth(self.rune) / 2,
			_G.BAIZE.runeFont:getHeight(self.rune) / 2)
	end
	for _, c in ipairs(self.cards) do
		c:draw()
	end
end

return Pile
