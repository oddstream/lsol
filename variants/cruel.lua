-- cruel

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Cruel = {}
Cruel.__index = Cruel
setmetatable(Cruel, {__index = Variant})

function Cruel.new(o)
	o = o or {}
	if o.subtype == 'Cruel' then
		o.tabCompareFn = CC.UpOrDownSuit
		o.wikipedia = 'https://en.wikipedia.org/wiki/Cruel_(solitaire)'
		o.moveType = 'MOVE_ONE'
	elseif o.subtype == 'Perseverance' then
		o.tabCompareFn = CC.DownSuit
		o.wikipedia = 'https://en.wikipedia.org/wiki/Perseverance_(solitaire)'
		o.moveType = 'MOVE_ANY'
	end
	return setmetatable(o, Cruel)
end

function Cruel:buildPiles()
	Stock.new({x=1, y=1})
	for x = 9, 12 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 12 do
		local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType})
		t.label = 'X'
	end
end

function Cruel:startGame()
	local src = _G.BAIZE.stock
	for _, f in ipairs(_G.BAIZE.foundations) do
		Util.moveCardByOrd(src, f, 1)
	end
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 4 do
			Util.moveCard(src, t)
		end
	end
	if self.subtype == 'Cruel' then
		_G.BAIZE:setRecycles(0)
	elseif self.subtype == 'Perseverance' then
		_G.BAIZE:setRecycles(2)
	end
end

function Cruel:afterMove()
	-- kludge afterMove is called by stock recycle
	if self.subtype == 'Cruel' then
		_G.BAIZE:setRecycles(_G.BAIZE.recycles + 1)
	end
end

function Cruel:moveTailError(tail)
	-- not reached by Cruel because Tableau moveType == 'MOVE_ONE'
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

function Cruel:tailAppendError(dst, tail)
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
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Cruel:pileTapped(pile)
	if pile.category ~= 'Stock' then
		return
	end
	if self.subtype == 'Cruel' and _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('You cannot redeal until you have moved a card', 'blip')
		return
	elseif self.subtype == 'Perseverance' and _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more redeals', 'blip')
		return
	end
	--[[
		The cards from the tableau are collected, one column at a time,
		starting with the left-most column,
		picking up the cards in each column in top to bottom order.
		(Remember - the "top" card is the one you can play - which is confusingly on the bottom on your screen.)
		Then, without shuffling, the cards are dealt out again,
		starting with the first card picked up,
		and dealing the cards in the same order as they were picked up.
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
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 4 do
			Util.moveCard(stock, t)
		end
	end
	if self.subtype == 'Cruel' then
		_G.BAIZE:setRecycles(-1)	-- kludge because recycle will trigger afterUserMove
	elseif self.subtype == 'Perseverance' then
		_G.BAIZE:setRecycles(_G.BAIZE.recycles - 1)
		if _G.BAIZE.recycles == 1 then
			_G.BAIZE.ui:toast('One more redeal')
		end
	end
end

-- function Cruel:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Cruel
