-- mount olympus

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local MountOlympus = {}
MountOlympus.__index = MountOlympus
setmetatable(MountOlympus, {__index = Variant})

function MountOlympus.new(o)
	o.wikipedia = 'https://en.wikipedia.org/wiki/Mount_Olympus_(solitaire)'
	o.tabCompareFn = CC.DownSuitTwo
	return setmetatable(o, MountOlympus)
end

function MountOlympus:buildPiles()
	self.stock = Stock.new({x=1, y=1, packs=2, nodraw=true})

	for x = 3, 10 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 3, 10 do
		local f = Foundation.new({x=x, y=2})
		f.label = '2'
	end
	local ypos = {4.33,4,3.66,3.33,3,3.33,3.66,4,4.33}
	local i = 1
	for x = 2, 10 do
		Tableau.new({x=x, y=ypos[i], fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		i = i + 1
	end
end

function MountOlympus:startGame()
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[1], 1, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[2], 1, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[3], 1, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[4], 1, '♠')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[5], 1, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[6], 1, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[7], 1, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[8], 1, '♠')

	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[9], 2, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[10], 2, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[11], 2, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[12], 2, '♠')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[13], 2, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[14], 2, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[15], 2, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[16], 2, '♠')

	for _, tab in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(self.stock, tab)
	end

	_G.BAIZE:setRecycles(0)
end

function MountOlympus:afterMove()
	if #self.stock.cards > 0 then
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			if #tab.cards == 0 then
				Util.moveCard(self.stock, tab)
			end
		end
	end
end

function MountOlympus:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownSuitTwo(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function MountOlympus:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		return CC.UpSuitTwo({dst:peek(), tail[1]})
	elseif dst.category == 'Tableau' then
		if #dst.cards > 0 then
			return CC.DownSuitTwo({dst:peek(), tail[1]})
		else
			return CC.Empty(dst, tail[1])
		end
	end
	return nil
end

-- function MountOlympus:pileTapped(pile)
-- end

function MountOlympus:tailTapped(tail)
	local pile = tail[1].parent
	if pile.category == 'Stock' then
		if #self.stock.cards > 0 then
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				Util.moveCard(self.stock, tab)
			end
		end
	else
		return pile:tailTapped(tail)
	end
end

return MountOlympus
