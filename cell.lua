-- class Cell, derived from Pile

local Pile = require 'pile'

local Cell = {}
Cell.__index = Cell
setmetatable(Cell, {__index = Pile})

function Cell.new(o)
	o.category = 'Cell'
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_ONE'
	o = Pile.new(o)
	setmetatable(o, Cell)

	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.cells, o)

	return o
end

function Cell:canAcceptCard(c)
	if #self.cards ~= 0 then
		return false, 'A Cell can only contain one card'
	end
	if c.prone then
		-- eg being dragged from Stock
		return false, 'Cannot add a face down card to a Cell'
	end
	return true, nil
end

function Cell:canAcceptTail(tail)
	if #self.cards ~= 0 then
		return false, 'A Cell can only contain one card'
	end
	if #tail > 1 then
		return false, 'Can only move one card to a Cell'
	end
	if tail[1].prone then
	-- eg being dragged from Stock
		return false, 'Cannot add a face down card to a Cell'
	end
	return true, nil
end

-- use Pile.tailTapped

-- use Pile.collect

function Cell:conformant()
	return true
end

function Cell:complete()
	return #self.cards == 0
end

function Cell:unsortedPairs()
	return 0
end

return Cell
