-- pile
-- virtual base class for Stock, Waste, Foundation, Tableau, Reserve, Cell

local Pile = {
    -- slot
	-- cards
    -- label
}
Pile.__index = Pile

function Pile.new(o)
	-- assert(type(o)=='table')
	-- assert(type(o.x)=='number')
	-- assert(type(o.y)=='number')
	setmetatable(o, Pile)
    o.slot = {x = o.x, y = o.y}
	o.cards = {}
	o.label = ''
	return o
end

function Pile:peek()
	return self.cards[#self.cards]
end

function Pile:push(c)
	table.insert(self.cards, c)
	c.parent = self
end

function Pile:pop()
	local c = table.remove(self.cards)
	if c then c.parent = nil end
	return c
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
	love.graphics.setColor(1, 1, 1, 0.25)
	love.graphics.rectangle('line', self.x, self.y, _G.BAIZE.cardWidth, _G.BAIZE.cardHeight, 10, 10)
	for _, c in ipairs(self.cards) do
		c:draw()
	end
end

return Pile
