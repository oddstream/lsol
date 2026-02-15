-- class Cell, derived from Pile

local Pile = require 'pile'
local Util = require 'util'

---@class (exact) Cell: Pile
---@field __index Cell
---@field new function
local Cell = {}
Cell.__index = Cell
setmetatable(Cell, {__index = Pile})

function Cell.new(o)
	o.category = 'Cell'
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_TOP_ONLY'
	o = Pile.prepare(o)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.cells, o)
	return setmetatable(o, Cell)
end

---@return string|nil
function Cell:acceptTailError(tail)
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

---@return integer
function Cell:unsortedPairs()
	return 0
end

function Cell:movableTails()
	-- same as Reserve:movableTails
	local tails = {}
	if #self.cards > 0 then
		local card = self:peek()	-- card should never be prone
		if not card.prone then
			local tail = {card}
			local homes = Util.findHomesForTail(tail)
			for _, home in ipairs(homes) do
				table.insert(tails, {tail=tail, dst=home.dst})
			end
		end
	end
	return tails
end

return Cell
