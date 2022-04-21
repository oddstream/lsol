-- tripeaks

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local TriPeaks = {}
TriPeaks.__index = TriPeaks
setmetatable(TriPeaks, {__index = Variant})

local function tableauxCards()
	local cards = 0
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		cards = cards + #pile.cards
	end
	return cards
end

function TriPeaks.new(o)
	o.tabCompareFn = CC.UpOrDownWrap
	o.wikipedia='https://en.wikipedia.org/wiki/Tri_Peaks_(game)'
	return setmetatable(o, TriPeaks)
end

function TriPeaks:buildPiles()

	-- TODO these piles should have no outline
	for _, x in ipairs({2.5, 5.5, 8.5}) do
		Tableau.new({x=x, y=1.5, fanType='FAN_NONE', moveType='MOVE_ONE', hidden=true})
	end

	for _, x in ipairs({2, 3, 5, 6, 8, 9}) do
		Tableau.new({x=x, y=2, fanType='FAN_NONE', moveType='MOVE_ONE', hidden=true})
	end

	for x = 1.5, 9.5 do
		Tableau.new({x=x, y=2.5, fanType='FAN_NONE', moveType='MOVE_ONE', hidden=true})
	end

	for x = 1, 10 do
		Tableau.new({x=x, y=3, fanType='FAN_NONE', moveType='MOVE_ONE', hidden=true})
	end

	self.stock = Stock.new({x=5, y=5})
	self.foundation = Foundation.new({x=6, y=5, fanType='FAN_NONE'})

end

function TriPeaks:startGame()
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		local card = Util.moveCard(self.stock, dst)
		if (not self.open) and (dst.slot.y < 3) then
			card.prone = true
		end
	end

	Util.moveCard(self.stock, self.foundation)
	_G.BAIZE:setRecycles(0)
end

function TriPeaks:afterMove()
	if self.open then return end

	-- record which piles overlap each pile
	for _, tab1 in ipairs(_G.BAIZE.tableaux) do
		tab1.overlapPiles = {}
		local ax, ay, aw, ah = tab1:baizeRect()
		for _, tab2 in ipairs(_G.BAIZE.tableaux) do
			if tab2.slot.y > tab1.slot.y then
				local bx, by, bw, bh = tab2:baizeRect()
				local area = Util.overlapArea(ax, ay, aw, ah, bx, by, bw, bh)
				if area > 0 then
					table.insert(tab1.overlapPiles, tab2)
				end
			end
		end
	end

	for _, tab1 in ipairs(_G.BAIZE.tableaux) do
		if #tab1.cards > 0 and tab1.cards[1].prone then
			local overlappingCards = 0
			for _, tab2 in ipairs(tab1.overlapPiles) do
				if #tab2.cards > 0 then
					overlappingCards = overlappingCards + 1
				end
			end
			if overlappingCards == 0 then
				tab1.cards[1]:flipUp()
			end
		end
	end
end

function TriPeaks:moveTailError(tail)
	return nil
end

function TriPeaks:tailAppendError(dst, tail)
	if #tail > 1 then
		return 'Cannot move more than one card'
	end
	if dst.category == 'Tableau' then
		return 'Cannot move cards to the tableaux'
	elseif dst.category == 'Foundation' then
		return CC.UpOrDownWrap({dst:peek(), tail[1]})
	end
	log.error('What are we doing here?')
	return nil
end

-- function TriPeaks:unsortedPairs(pile)
-- 	return #pile.cards
-- end

function TriPeaks:percentComplete()
	local cards = tableauxCards()
	return 100 - Util.mapValue(28 - cards, 0, 28, 100, 0)
end

function TriPeaks:complete()
	return tableauxCards() == 0
end

-- function TriPeaks:pileTapped(pile)
-- 	-- no recycles
-- end

function TriPeaks:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == self.stock and #tail == 1 then
		Util.moveCard(self.stock, self.foundation)
	else
		pile:tailTapped(tail)
	end
end

return TriPeaks
