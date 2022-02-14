-- class Waste, derived from Pile

local Pile = require 'pile'

local Waste = {}
Waste.__index = Waste
setmetatable(Waste, {__index = Pile})

function Waste.new(o)
	o = Pile.new(o)
	o.category = 'Waste'
	o.moveType = 'MOVE_ONE'
	setmetatable(o, Waste)
	table.insert(_G.BAIZE.piles, o)
	_G.BAIZE.waste = o
	return o
end

-- vtable functions

function Waste:canAcceptCard(c)
	if c.parent.category ~= 'Stock' then
		return 'Waste can only accept cards from the Stock'
	end
	return nil
end

function Waste:canAcceptTail(tail)
	if #tail > 1 then
		return 'Can only move a single card to Waste'
	end
	return self:canAcceptCard(tail[1])
end

-- use Pile.tailTapped

-- use Pile.collect

function Waste:conformant()
	return #self.cards < 2
end

function Waste:complete()
	return #self.cards == 0
end

function Waste:unsortedPairs()
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

return Waste
