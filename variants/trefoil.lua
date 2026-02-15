-- trefoil

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Trefoil = {}
Trefoil.__index = Trefoil
setmetatable(Trefoil, {__index = Variant})

function Trefoil.new(o)
	o = o or {}
	o.wikipedia = 'https://en.wikipedia.org/wiki/La_Belle_Lucie'
	o.tabCompareFn = CC.DownSuit
	o.moveType = 'MOVE_TOP_ONLY'
	return setmetatable(o, Trefoil)
end

function Trefoil:buildPiles()
	-- if Util.orientation() == 'landscape' then
	Stock.new({x=1, y=1})
	for x = 5, 8 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 8 do
		local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
		t.label = 'X'
	end
	for x = 1, 8 do
		local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
		t.label = 'X'
	end
	for i = 1, 8 do
		_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+8]
	end
end

function Trefoil:startGame()
	local src = _G.BAIZE.stock
	for _, f in ipairs(_G.BAIZE.foundations) do
		Util.moveCardByOrd(src, f, 1)
	end
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 3 do
			Util.moveCard(src, t)
		end
	end
	_G.BAIZE:setRecycles(2)
end

function Trefoil:afterMove()
end

function Trefoil:moveTailError(tail)
	-- not reached by Trefoil because Tableau moveType == 'MOVE_TOP_ONLY'
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

function Trefoil:tailAppendError(dst, tail)
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

function Trefoil:pileTapped(pile)
	if pile.category ~= 'Stock' then
		return
	end
	if _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more reshuffles', 'blip')
		return
	end
	local stock = _G.BAIZE.stock
	-- collect cards
	for _, tab in ipairs(_G.BAIZE.tableaux) do
		for i = 1, #tab.cards do
			table.insert(stock.cards, tab.cards[i])
		end
		tab.cards = {}
	end
	-- shuffle stock
	stock:shuffle()
	-- redeal cards
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 3 do
			Util.moveCard(stock, t)
		end
	end
	_G.BAIZE:setRecycles(_G.BAIZE.recycles - 1)
	if _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more reshuffles')
	elseif _G.BAIZE.recycles == 1 then
		_G.BAIZE.ui:toast('One more reshuffle')
	end
end

-- function Trefoil:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Trefoil
