-- Reserve.lua

local Pile = require 'pile'
local Util = require 'util'

local Reserve = {}
Reserve.__index = Reserve
setmetatable(Reserve, {__index = Pile})

function Reserve.new(o)
	o.category = 'Reserve'
	o.fanType = o.fanType or 'FAN_DOWN'
	o.moveType = 'MOVE_ONE'
	o = Pile.prepare(o)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.reserves, o)
	return setmetatable(o, Reserve)
end

-- vtable functions

function Reserve:acceptCardError(c)
	return 'Cannot move a card to a Reserve'
end

function Reserve:acceptTailError(c)
	return 'Cannot move a card to a Reserve'
end

-- use Pile.tailTapped

-- use Pile.collect

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

return Reserve
