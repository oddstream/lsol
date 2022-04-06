-- alhambra

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Alhambra = {}
Alhambra.__index = Alhambra
setmetatable(Alhambra, {__index = Variant})

function Alhambra.new(o)
	o.wikipedia = 'https://en.wikipedia.org/wiki/Alhambra_(solitaire)'
	o.tabCompareFn = CC.UpOrDownSuitWrap
	return setmetatable(o, Alhambra)
end

function Alhambra:buildPiles()
	for x = 1, 4 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 5, 8 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'K'
	end
	for x = 1, 8 do
		Reserve.new({x=x, y=2, fanType='FAN_DOWN'})
	end

	Stock.new({x=1, y=4, packs=2})
	Tableau.new({x=2, y=4, fanType='FAN_RIGHT3', moveType='MOVE_ONE'})
end

function Alhambra:startGame()
	local stock = _G.BAIZE.stock
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[1], 1, '♣')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[2], 1, '♦')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[3], 1, '♥')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[4], 1, '♠')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[5], 13, '♣')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[6], 13, '♦')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[7], 13, '♥')
	Util.moveCardByOrdAndSuit(stock, _G.BAIZE.foundations[8], 13, '♠')
	for _, r in ipairs(_G.BAIZE.reserves) do
		for _ = 1, 4 do
			Util.moveCard(stock, r)
		end
	end
	_G.BAIZE:setRecycles(2)
end

function Alhambra:afterMove()
end

function Alhambra:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownSuit(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Alhambra:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if dst.label == 'A' then
			return CC.UpSuit({dst:peek(), tail[1]})
		elseif dst.label == 'K' then
			return CC.DownSuit({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards > 0 then
			return CC.UpOrDownSuitWrap({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Alhambra:pileTapped(pile)
	if pile.category == 'Stock' then
		local stock = _G.BAIZE.stock
		if _G.BAIZE.recycles > 0 then
			local tab = _G.BAIZE.tableaux[1]
			while #tab.cards > 0 do
				Util.moveCard(tab, stock)
			end
			_G.BAIZE:setRecycles(_G.BAIZE.recycles - 1)
			if _G.BAIZE.recycles == 0 then
				_G.BAIZE.ui:toast('No more recycles', 'blip')
			elseif _G.BAIZE.recycles == 1 then
				_G.BAIZE.ui:toast('One more recycle')
			elseif _G.BAIZE.recycles < 10 then
				_G.BAIZE.ui:toast(string.format('%d recycles remaining', _G.BAIZE.recycles))
			end
		else
			_G.BAIZE.ui:toast('No more recycles', 'blip')
		end
	end
end

function Alhambra:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.tableaux[1])
	else
		pile:tailTapped(tail)
	end
end

return Alhambra
