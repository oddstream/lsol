-- stock, derived from pile

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

	print('TRACE making cards')
	for pack = 1, o.packs do
		for _, ord in ipairs(o.ordFilter) do
			for _, suit in ipairs(o.suitFilter) do
				Pile.push(o, Card.new({pack=pack, ord=ord, suit=suit, prone=true}))
				-- card parent is assigned in Pile.push
			end
		end
	end
	_G.BAIZE.numberOfCards = #o.cards
	print('TRACE made', #o.cards, 'cards')

	print('TRACE shuffling cards')
	math.randomseed(os.time())
	for i = #o.cards, 2, -1 do
		local j = math.random(i)
		if i ~= j then
			o.cards[i], o.cards[j] = o.cards[j], o.cards[i]
		end
	end

	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	_G.BAIZE.stock = o

	return o
end

function Stock:push(c)
	Pile.push(self, c)
	-- Stock cards are always prone
	c.prone = true
end

function Stock:pop()
	local c = Pile.pop(self)
	if c and c.prone then
		c.prone = false
	end
	return c
end

-- vtable functions

function Stock:canAcceptCard(c)
	return false, 'Cannot move cards to the Stock'
end

function Stock:canAcceptTail(tail)
	return false, 'Cannot move cards to the Stock'
end

function Stock:tailTapped(tail)
	-- do nothing, handled by script, which had first dibs
end

function Stock:collect()
	-- override Pile.collect to do nothing
end

function Stock:conformat()
	return #self.cards == 0
end

function Stock:complete()
	return #self.cards == 0
end

function Stock:unsortedPairs()
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end


return Stock
