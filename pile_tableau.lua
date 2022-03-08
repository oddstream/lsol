-- class Tableau, derived from Pile

local log = require 'log'

local Pile = require 'pile'

local Tableau = {}
Tableau.__index = Tableau
setmetatable(Tableau, {__index = Pile})

function Tableau.new(o)
	o = Pile.new(o)
	o.category = 'Tableau'
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.tableaux, o)
	return setmetatable(o, Tableau)
end

function Tableau:acceptCardError(c)
	if c.prone then
		return 'Cannot add a face down card to a Tableau'
	end
	return _G.BAIZE.script:tailAppendError(self, {c})
end

local function powerMoves(pileTarget)
	-- (1 + number of empty freecells) * 2 ^ (number of empty columns)
	-- see http://ezinearticles.com/?Freecell-PowerMoves-Explained&id=104608
	-- and http://www.solitairecentral.com/articles/FreecellPowerMovesExplained.html
	local emptyCells, emptyCols = 0, 0
	for _, pile in ipairs(_G.BAIZE.piles) do
		if #pile.cards == 0 then
			if pile.category == 'Cell' then
				emptyCells = emptyCells + 1
			elseif pile.category == 'Tableau' then
				if (not pile.label) and (pile ~= pileTarget) then
					emptyCols = emptyCols + 1
				end
			end
		end
	end
	local n = (1 + emptyCells) * (2 ^ emptyCols)
	-- log.info(emptyCells, "emptyCells,", emptyCols, "emptyCols,", n, "powerMoves")
	return n
end

function Tableau:acceptTailError(tail)
	for _, c in ipairs(tail) do
		if c.prone then
			return 'Cannot add a face down card'
		end
	end
	if self.moveType == 'MOVE_ONE_PLUS' then
		if _G.BAIZE.settings.powerMoves then
			local moves = powerMoves(self)
			if #tail > moves then
				if moves == 1 then
					return string.format('Space to move 1 card, not %d', #tail)
				else
					return string.format('Space to move %d cards, not %d', moves, #tail)
				end
			end
		else
			if #tail > 1 then
				return 'Cannot add more than one card'
			end
		end
	elseif self.moveType == 'MOVE_ONE' then
		if #tail > 1 then
			return 'Cannot add more than one card'
		end
	-- else
	-- 	log.error('unknown tableau move type', self.moveType)
	end
	return _G.BAIZE.script:tailAppendError(self, tail)
end

-- use Pile.tailTapped

-- use Pile.collect

function Tableau:conformant()
	return _G.BAIZE.script:unsortedPairs(self) == 0
end

function Tableau:unsortedPairs()
	return _G.BAIZE.script:unsortedPairs(self)
end

return Tableau
