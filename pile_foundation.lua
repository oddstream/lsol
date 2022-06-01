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
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.foundations, o)
  return setmetatable(o, Foundation)
end

-- vtable functions

function Foundation:acceptCardError(c)
	if #self.cards == #_G.BAIZE.deck / #_G.BAIZE.foundations then
		return 'The Foundation is full'
	end
	return _G.BAIZE.script:tailAppendError(self, {c})
end

function Foundation:acceptTailError(tail)
	if #tail > 1 then
		return 'Cannot move more than one card to a Foundation'
	end
	return _G.BAIZE.script:tailAppendError(self, tail)
end

function Foundation:tailTapped(tail)
	-- do nothing
end

function Foundation:unsortedPairs()
	return 0
end

return Foundation
