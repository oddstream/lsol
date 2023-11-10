-- Reserve.lua

local Pile = require 'pile'
local Util = require 'util'

---@class (exact) Reserve : Pile
---@field __index Reserve
---@field new function
local Reserve = {}
Reserve.__index = Reserve
setmetatable(Reserve, {__index = Pile})

function Reserve.new(o)
	o.category = 'Reserve'
	o.fanType = o.fanType or 'FAN_DOWN'
	o.moveType = 'MOVE_ONE'
	-- don't draw graphics if pile is redundant when all cards have left it
	o.nodraw = true
	o = Pile.prepare(o)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.reserves, o)
	return setmetatable(o, Reserve)
end

-- vtable functions

---@return string|nil
function Reserve:acceptTailError(tail)
	return 'Cannot move a card to a Reserve'
end

-- use Pile.tailTapped

-- use Pile.collect

---@return integer
function Reserve:unsortedPairs()
	-- they're all unsorted, even if they aren't
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

function Reserve:movableTails()
	-- same as Cell:movableTails
	local tails = {}
	if #self.cards > 0 then
		local card = self:peek()
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

function Reserve:movableTailsMay23()
	-- same as Cell/Waste:movableTails2
	-- only look at the top card
	if #self.cards > 0 then
		local card = self:peek()
		if not card.prone then
			return {card}
		end
	end
	return nil
end

return Reserve
