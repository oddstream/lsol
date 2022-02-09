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
		if self.fanType == 'FAN_DOWN' then
			r.y2 = cRect.y2
		elseif self.fanType == 'FAN_RIGHT' then
			r.x2 = cRect.x2
		end
	end
	return r
end

function Pile:posAfter(c)
	if (c == nil ) or (#self.cards == 0) then
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
	end
	return x, y
end

function Pile:refan()
	if self.fanType == 'FAN_NONE' then
		for _, c in ipairs(self.cards) do
			c.x = self.x
			c.y = self.y
		end
	elseif self.fanType == 'FAN_DOWN' then
		local x, y = self.x, self.y
		local i = 1
		for _, c in ipairs(self.cards) do
			c.x = x
			c.y = y
			x, y = self:posAfter(self.cards[i])
			i = i + 1
		end
	end
end

function Pile:peek()
	return self.cards[#self.cards]
end

function Pile:push(c)
	local x, y = self:posAfter(self:peek())
	table.insert(self.cards, c)
	c.parent = self
	c:transitionTo(x, y)
end

function Pile:pop()
	local c = table.remove(self.cards)
	if c then c.parent = nil end
	return c
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
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle('line', self.x, self.y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
	for _, c in ipairs(self.cards) do
		c:draw()
	end
end

return Pile
