-- stock, derived from pile

local log = require 'log'

local Card = require 'card'
local Pile = require 'pile'

local Stock = {}
Stock.__index = Stock   -- Stock's own __index looks in Stock for methods
setmetatable(Stock, {__index = Pile}) -- failing that, Stock's metatable then looks in base class for methods

function Stock.new(o)
	assert(type(o)=='table')
	assert(type(o.x)=='number')
	assert(type(o.y)=='number')
	o = Pile.new(o)
	setmetatable(o, Stock)

	o.category = 'Stock'
	o.ordFilter = o.ordFilter or {1,2,3,4,5,6,7,8,9,10,11,12,13}
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	o.packs = o.packs or 1
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_ONE'

	for pack = 1, o.packs do
		for _, ord in ipairs(o.ordFilter) do
			for _, suit in ipairs(o.suitFilter) do
				Pile.push(o, Card.new({pack=pack, ord=ord, suit=suit, prone=true}))
				-- card parent is assigned in Pile.push
			end
		end
	end
	-- log.info('made', #o.cards, 'cards')

	o:shuffle()

	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	_G.BAIZE.stock = o

	-- create a shadow copy of all the cards
	-- so that when restoring the piles from a saved baize
	-- all the cards can be found in one place
	_G.BAIZE.deck = {}
	for _, c in ipairs(o.cards) do
		table.insert(_G.BAIZE.deck, c)
	end
	assert(#o.cards == #_G.BAIZE.deck)

	return o
end

function Stock:shuffle()
	for i = #self.cards, 2, -1 do
		local j = math.random(i)
		if i ~= j then
			self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
		end
	end
end

function Stock:push(c)
	Pile.push(self, c)
	-- Stock cards are always prone
	c:flipDown()
end

function Stock:pop()
	local c = Pile.pop(self)
	if c then
		c:flipUp()
	end
	return c
end

-- vtable functions

function Stock:acceptCardError(c)
	return 'Cannot move cards to the Stock'
end

function Stock:acceptTailError(tail)
	return 'Cannot move cards to the Stock'
end

function Stock:tailTapped(tail)
	-- do nothing, handled by script, which had first dibs
end

function Stock:unsortedPairs()
	-- they're all unsorted, even if they aren't
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

function Stock:draw()
	local b = _G.BAIZE
	local x, y = self:screenPos()

	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
	if self.rune then
		love.graphics.setFont(b.runeFont)
		love.graphics.print(self.rune,
			x + b.cardWidth / 2,
			y + b.cardHeight / 2,
			0,	-- orientation
			1,	-- x scale
			1,	-- y scale
			b.runeFont:getWidth(self.rune) / 2,		-- origin offset
			b.runeFont:getHeight() / 2)				-- origin offset
	end
end

return Stock
