-- class Waste, derived from Pile

local Pile = require 'pile'
local Util = require 'util'

---@class (exact) Waste : Pile
---@field __index Waste
---@field new function
local Waste = {}
Waste.__index = Waste
setmetatable(Waste, {__index = Pile})

function Waste.new(o)
	o.category = 'Waste'
	o.fanType = o.fanType or 'FAN_RIGHT3'
	o.moveType = o.moveType or 'MOVE_ONE'
	o = Pile.prepare(o)
	table.insert(_G.BAIZE.piles, o)
	_G.BAIZE.waste = o
	return setmetatable(o, Waste)
end

-- vtable functions

---@return string|nil
function Waste:acceptTailError(tail)
	if #tail > 1 then
		return 'Can only move a single card to Waste'
	end
	if tail[1].parent.category ~= 'Stock' then
		return 'Waste can only accept cards from the Stock'
		-- TODO not true for all variants
	end
	-- card may be prone if being dragged from Stock;
	-- that's ok because Stock:pop() will flip it
	return nil
end

-- use Pile.tailTapped

-- use Pile.collect

---@return integer
function Waste:unsortedPairs()
	-- they're all unsorted, even if they aren't
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

function Waste:movableTails()
	-- same as Cell/Reserve:movableTails
	-- only look at the top card
	local tails = {}
	if #self.cards > 0 then
		local card = self:peek()
		if not card.prone then	-- all Waste cards should be face up
			local tail = {card}
			local homes = Util.findHomesForTail(tail)
			for _, home in ipairs(homes) do
				table.insert(tails, {tail=tail, dst=home.dst})
			end
		end
	end
	return tails
end

return Waste
