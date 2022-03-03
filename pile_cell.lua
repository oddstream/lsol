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
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.cells, o)
	return setmetatable(o, Cell)
end

function Cell:canAcceptCard(c)
	if #self.cards ~= 0 then
		return 'A Cell can only contain one card'
	end
	if c.prone then
		-- eg being dragged from Stock
		return 'Cannot add a face down card to a Cell'
	end
	return nil
end

function Cell:canAcceptTail(tail)
	if #self.cards ~= 0 then
		return 'A Cell can only contain one card'
	end
	if #tail > 1 then
		return 'Can only move one card to a Cell'
	end
	if tail[1].prone then
	-- eg being dragged from Stock
		return 'Cannot add a face down card to a Cell'
	end
	return nil
end

-- use Pile.tailTapped

-- use Pile.collect

function Cell:conformant()
	return true
end

function Cell:unsortedPairs()
	return 0
end

return Cell
