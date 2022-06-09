-- freecell

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Cell = require 'pile_cell'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Freecell = {}
Freecell.__index = Freecell
setmetatable(Freecell, {__index = Variant})

function Freecell.new(o)
	o = o or {}
	if o.bakers then
		o.tabCompareFn = CC.DownSuit
		o.wikipedia = 'https://en.wikipedia.org/wiki/Baker%27s_Game'
	elseif o.chinese then
		o.tabCompareFn = CC.DownAltSuit
		o.wikipedia = 'https://en.wikipedia.org/wiki/Baker%27s_Game'
	else
		o.tabCompareFn = CC.DownAltColor
		o.wikipedia = 'https://en.wikipedia.org/wiki/FreeCell'
	end
	if o.double then
		o.foundCompareFn = CC.UpSuitWrap
	else
		o.foundCompareFn = CC.UpSuit
	end
	return setmetatable(o, Freecell)
end

function Freecell:buildPiles()
	if self.double then
		Stock.new({x=4, y=-4, packs=2})
		for x = 1, 6 do
			Cell.new({x=x, y=1})
		end
		for x = 7, 10 do
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
		for x = 1, 10 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
			if self.relaxed == false then
				t.label = 'K'
			end
		end
	elseif self.chinese then
		Stock.new({x=4, y=-4, packs=2, suitFilter={'♦','♥','♠'}})
		for x = 1, 4 do
			Cell.new({x=x, y=1})
		end
		for x = 6, 11 do
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
		for x = 1, 11 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
			if self.relaxed == false then
				t.label = 'K'
			end
		end
	else
		Stock.new({x=4, y=-4})
		for x = 1, 4 do
			Cell.new({x=x, y=1})
		end
		for x = 5, 8 do
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
		for x = 1, 8 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
			if self.relaxed == false then
				t.label = 'K'
			end
		end
	end
end

function Freecell:startGame()
	local stock = _G.BAIZE.stock
	if self.double then
		Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[1], 1, '♣')
		Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[2], 1, '♦')
		Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[3], 1, '♥')
		Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[4], 1, '♠')
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, 10 do
				Util.moveCard(stock, tab)
			end
		end
	elseif self.chinese then
		while #stock.cards > 0 do
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				Util.moveCard(stock, tab)
			end
		end
	else
		for i = 1, 4 do
			local tab = _G.BAIZE.tableaux[i]
			for _ = 1, 7 do
				Util.moveCard(stock, tab)
			end
		end
		for i = 5, 8 do
			local tab = _G.BAIZE.tableaux[i]
			for _ = 1, 6 do
				Util.moveCard(stock, tab)
			end
		end
	end
	if #stock.cards > 0 then
		log.error('still', #stock.cards, 'cards in Stock')
	end
	_G.BAIZE:setRecycles(0)
end

-- function Freecell:afterMove()
-- end

function Freecell:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = self.tabCompareFn(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Freecell:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return self.foundCompareFn({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Freecell:pileTapped(pile)
-- end

-- function Freecell:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Freecell
