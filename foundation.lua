-- class Foundation, derived from Pile

local Pile = require 'pile'

local Foundation = {}
Foundation.__index = Foundation
setmetatable(Foundation, {__index = Pile})

function Foundation.new(o)
	o.category = 'Foundation'
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_NONE'
	o = Pile.new(o)
	setmetatable(o, Foundation)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.foundations, o)
  return o
end

-- vtable functions

function Foundation:canAcceptCard(c)
	if c.prone then
		return 'Cannot move a face down card'
	end -- eg being dragged from Stock
	if #self.cards == _G.BAIZE.numberOfCards / #_G.BAIZE.foundations then
		return 'The Foundation is full'
	end
	return _G.BAIZE.script.tailAppendError(self, {c})
end

function Foundation:canAcceptTail(tail)
	if #tail > 1 then
		return 'Cannot move more than one card to a Foundation'
	end
	return _G.BAIZE.script.tailAppendError(self, tail)
end

function Foundation:tailTapped(tail)
	-- do nothing
end

function Foundation:collect()
	-- override Pile.collect to do nothing
end

function Foundation:conformant()
	return true
end

function Foundation:complete()
	return #self.cards == _G.BAIZE.numberOfCards / #_G.BAIZE.foundations
end

function Foundation:unsortedPairs()
	return 0
end

return Foundation
