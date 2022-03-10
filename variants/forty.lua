-- forty

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Forty = {}
Forty.__index = Forty
setmetatable(Forty, {__index = Variant})

function Forty.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Forty_Thieves_(solitaire)'
	o.packs = o.packs or 2
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	return setmetatable(o, Forty)
end

function Forty:buildPiles()
	Stock.new{x=1, y=1, packs=self.packs, suitFilter=self.suitFilter}
	Waste.new{x=2, y=1, fanType='FAN_RIGHT3'}

	local firstFound = self.tabs - 8
	if firstFound < 3 then
		firstFound = 3
	end
	for x = 1, 8 do
		local pile = Foundation.new{x=firstFound+x, y=1}
		pile.label =  _G.ORD2STRING[1]
	end
	local firstTab = firstFound + 8 - self.tabs
	for x = 1, self.tabs do
		Tableau.new{x=firstTab + x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'}
	end
end

function Forty:startGame()
	_G.BAIZE:setRecycles(0)
	if self.dealAces then
		for _, pile in ipairs(_G.BAIZE.foundations) do
			Util.moveCardByOrd(_G.BAIZE.stock, pile, 1)
		end
	end
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, self.cardsPerTab do
			Util.moveCard(_G.BAIZE.stock, pile)
		end
	end
end

-- function Forty:afterMove()
-- end

function Forty:moveTailError(tail)
	local card = tail[1]
	local pile = card.parent
	if pile.category == 'Tableau' then
		if #tail > 1 then
			local cpairs = Util.makeCardPairs(tail)
			for _, cpair in ipairs(cpairs) do
				local err = CC.DownSuit(cpair)
				if err then
					return err
				end
			end
		end
	end
end

function Forty:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuit({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.DownSuit({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Forty:pileTapped(pile)
-- end

function Forty:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Forty
