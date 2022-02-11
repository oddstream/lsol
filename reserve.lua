-- Reserve.lua

local Pile = require 'pile'

local Reserve = {}
Reserve.__index = Reserve
setmetatable(Reserve, {__index = Pile})

function Reserve.new(o)
	o = Pile.new(o)
	o.category = 'Reserve'
	o.moveType = 'MOVE_ONE'
	setmetatable(o, Reserve)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.reserves, o)
	return o
end

-- vtable functions

function Reserve:canAcceptCard(c)
	return 'Cannot move a card to a Reserve'
end

function Reserve:canAcceptTail(c)
	return 'Cannot move a card to a Reserve'
end

-- use Pile.tailTapped

-- use Pile.collect

function Reserve:conformant()
	return #self.cards < 2
end

function Reserve:complete()
	return #self.cards == 0
end

function Reserve:unsortedPairs()
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

return Reserve
