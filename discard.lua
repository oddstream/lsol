-- class Discard, derived from Pile

local Pile = require 'pile'

local Discard = {}
Discard.__index = Discard
setmetatable(Discard, {__index = Pile})

function Discard.new(o)
	o.category = 'Discard'
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_NONE'
	o = Pile.new(o)
	setmetatable(o, Discard)
	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.discards, o)
	return o
end

function Discard:canAcceptCard(c)
	return false, 'Cannot move a single card to a Discard'
end

function Discard:canAcceptTail(tail)
	if #self.cards ~= 0 then
		return false, 'Can only move cards to an empty Discard'
	end
	for _, c in ipairs(tail) do
		if c.prone then
			return false, 'Cannot move a face down card to a Discard'
		end
	end
	if #tail ~= _G.BAIZE.numberOfCards / #_G.BAIZE.discards then
		return false, 'Can only move a full set of cards to a Discard'
	end
	return _G.BAIZE.script.tailMoveError(self, tail)	-- check cards are conformant
end

function Discard:tailTapped(tail)
	-- do nothing
end

function Discard:collect()
	-- override Pile.collect to do nothing
end

function Discard:conformant()
	-- no Baize that contains any discard piles should be Conformant,
	-- because there is no use showing the collect all FAB
	-- because that would do nothing
	-- because cards are not collected to discard piles
	return false
end

function Discard:complete()
	if #self.cards == 0 then
		return true
	end
	if #self.cards == _G.BAIZE.numberOfCards / #_G.BAIZE.discards then
		return true
	end
	return false
end

function Discard:unsortedPairs()
	-- you can only put a sorted sequence into a Discard, so this will always be zero
	return 0
end

return Discard
