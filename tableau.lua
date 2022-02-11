-- class Tableau, derived from Pile

local Pile = require 'pile'

local Tableau = {}
Tableau.__index = Tableau
setmetatable(Tableau, {__index = Pile})

function Tableau.new(o)
	o = Pile.new(o)
	setmetatable(o, Tableau)

	o.category = 'Tableau'
	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.tableaux, o)

	return o
end

function Tableau:canAcceptCard(c)
	if c.prone then
		return 'Cannot add a face down card to a Tableau'
	end
	return _G.BAIZE.script.tailAppendError(self, {c})
end

function Tableau:canAcceptTail(tail)
	for _, c in ipairs(tail) do
		if c.prone then
			return 'Cannot add a face down card'
		end
	end
	if self.moveType == 'MOVE_ONE_PLUS' then
		-- TODO powermoves
		if #tail > 1 then
			return 'Cannot add more than one card'
		end
	end
	return _G.BAIZE.script.tailAppendError(self, tail)
end

-- use Pile.tailTapped

-- use Pile.collect

function Tableau:conformant()
	return _G.BAIZE.script.unsortedPairs(self)
end

function Tableau:complete()
	if #self.cards == 0 then
		return true
	end
	if _G.BAIZE.discards and #_G.BAIZE.discards > 0 then
		if #self.cards == _G.BAIZE.numberOfCards / #_G.BAIZE.discards then
			if _G.BAIZE.script.unsortedPairs(self) == 0 then
				return true
			end
		end
	end
	return false
end

function Tableau:unsortedPairs()
	return _G.BAIZE.script.unsortedPairs(self)
end

return Tableau
