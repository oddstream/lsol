-- algerian

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Algerian = {}
Algerian.__index = Algerian
setmetatable(Algerian, {__index = Variant})

function Algerian.new(o)
	o.wikipedia = 'https://en.wikipedia.org/wiki/Algerian_(card_game)'
	o.tabCompareFn = CC.UpOrDownSuitWrap
	return setmetatable(o, Algerian)
end

function Algerian:buildPiles()
	for x = 1, 4 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 5, 8 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'K'
	end
	for x = 1, 8 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE'})
	end
	for x = 1, 6 do
		Reserve.new({x=x, y=4, fanType='FAN_DOWN'})
	end
	self.stock = Stock.new({x=8, y=4, packs=2, nodraw=true})

	for i = 1, 6 do
		_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.reserves[i]
	end
	_G.BAIZE.tableaux[8].boundaryPile = _G.BAIZE.stock
end

function Algerian:startGame()
	if self.easy then
		-- Tarbart lays out these 4 Aces and 4 Kings at the beginning; Parlett has them founded as they appear.
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[1], 1, '♣')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[2], 1, '♦')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[3], 1, '♥')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[4], 1, '♠')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[5], 13, '♣')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[6], 13, '♦')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[7], 13, '♥')
		Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[8], 13, '♠')
	end
	for _, tab in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(self.stock, tab)
	end
	for _, res in ipairs(_G.BAIZE.reserves) do
		for _ = 1, 4 do
			Util.moveCard(self.stock, res)
		end
	end
	_G.BAIZE:setRecycles(0)
end

-- function Algerian:afterMove()
-- end

-- function Algerian:moveTailError(tail)
-- 	-- can only move one card
-- 	return nil
-- end

function Algerian:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if dst.label == 'A' then
			if #dst.cards > 0 then
				return CC.UpSuit({dst:peek(), tail[1]})
			else
				return CC.Empty(dst, tail[1])
			end
		elseif dst.label == 'K' then
			if #dst.cards > 0 then
				return CC.DownSuit({dst:peek(), tail[1]})
			else
				return CC.Empty(dst, tail[1])
			end
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards > 0 then
			return CC.UpOrDownSuitWrap({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Algerian:pileTapped(pile)
-- end

function Algerian:tailTapped(tail)
	local pile = tail[1].parent
	if pile.category == 'Stock' then
		-- When all desired plays have been made, two further cards are dealt from the stock onto each reserve pile and more plays may then be made if possible.
		-- This continues until eight cards remain in hand. On this final pass through the deck, one card is dealt to each depot.
		if #self.stock.cards > 0 then
			-- if #self.stock.cards == 8 then
			-- 	for _, tab in ipairs(_G.BAIZE.tableaux) do
			-- 		Util.moveCard(self.stock, tab)
			-- 	end
			-- else
				for _ = 1, 2 do
					for _, res in ipairs(_G.BAIZE.reserves) do
						Util.moveCard(self.stock, res)
					end
				end
			-- end
		end
	else
		return pile:tailTapped(tail)
	end
end

return Algerian
