-- usk

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Usk = {}
Usk.__index = Usk
setmetatable(Usk, {__index = Variant})

function Usk.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://politaire.com/help/usk'
	o.layouts = {
		{x = 1, n = 8},
		{x = 2, n = 8},
		{x = 3, n = 8},
		{x = 4, n = 7},
		{x = 5, n = 6},
		{x = 6, n = 5},
		{x = 7, n = 4},
		{x = 8, n = 3},
		{x = 9, n = 2},
		{x = 10, n = 1},
	}
	return setmetatable(o, Usk)
end

function Usk:buildPiles()
	Stock.new({x=1, y=1})
	for x = 7, 10 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for _, layout in ipairs(self.layouts) do
		local tab = Tableau.new({x=layout.x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		if not self.relaxed then
			tab.label = 'K'
		end
	end
end

function Usk:dealCards()
	local stock = _G.BAIZE.stock
	for _, layout in ipairs(self.layouts) do
		local tab = _G.BAIZE.tableaux[layout.x]
		for _ = 1, layout.n do
			Util.moveCard(stock, tab)
		end
	end
end

function Usk:startGame()
	self:dealCards()
	_G.BAIZE:setRecycles(1)
	if self.relaxed then
		_G.BAIZE.ui:toast('Relaxed version - any card may be placed in an empty pile')
	end
end

function Usk:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownAltColor(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Usk:tailAppendError(dst, tail)
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
			return CC.DownAltColor({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Usk:pileTapped(pile)
	if pile.category ~= 'Stock' then
		return
	end
	if _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more recycles', 'blip')
		return
	end
	--[[
		The redeal procedure begins by picking up all cards on the tableau.
		The cards from the tableau are collected, one column at a time,
		starting with the left-most column,
		picking up the cards in each column in bottom to top order.
		Then, without shuffling, the cards are dealt out again,
		starting with the first card picked up.
		Deal the tableau in the same arrangement as it was originally dealt,
		one row at a time, starting with the bottom-most row,
		dealing the cards in each row in left to right order.
	]]
	local stock = _G.BAIZE.stock
	-- collect cards
	for _, tab in ipairs(_G.BAIZE.tableaux) do
		for i = 1, #tab.cards do
			table.insert(stock.cards, tab.cards[i])
		end
		tab.cards = {}
	end
	-- reverse the stock cards so we can pop
	for i = 1, math.floor(#stock.cards/2) do
		local j = #stock.cards - i + 1
		stock.cards[i], stock.cards[j] = stock.cards[j], stock.cards[i]
	 end
	-- redeal cards
	self:dealCards()
	_G.BAIZE:setRecycles(0)
end

-- function Usk:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Usk
