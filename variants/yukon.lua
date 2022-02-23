-- yukon

local log = require 'log'

local CC = require 'cc'

local Cell = require 'pile_cell'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Yukon = {}
Yukon.__index = Yukon

function Yukon.new(o)
	o = o or {}
	o.wikipedia = 'https://en.wikipedia.org/wiki/Yukon_(solitaire)'
	o.packs = o.packs or 1
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	return setmetatable(o, Yukon)
end

function Yukon:buildPiles()
	-- hidden stock
	Stock.new{x=5, y=-5, packs=self.packs, suitFilter=self.suitFilter}
	-- the flipper, seven cells
	for y = 1, 4 do
		local pile = Foundation.new{x=8.5, y=y}
		pile.label =  _G.ORD2STRING[1]
	end
	if self.cells then
		for y = 5, 7 do
			Cell.new{x=8.5, y=y}
		end
	end
	for x = 1, 7 do
		local pile = Tableau.new{x=x, y=1, fanType='FAN_DOWN', moveType='MOVE_ANY'}
		if not self.relaxed then
			pile.label = _G.ORD2STRING[13]
		end
	end
end

function Yukon:startGame()
	local card
	local pile = _G.BAIZE.tableaux[1]
	Util.moveCard(_G.BAIZE.stock, pile)
	local dealDown = 1
	local dealUp = 5
	for x = 2, 7 do
		pile = _G.BAIZE.tableaux[x]
		for _ = 1, dealDown do
			card = Util.moveCard(_G.BAIZE.stock, pile)
			card.prone = true
		end
		for _ = 1, dealUp do
			Util.moveCard(_G.BAIZE.stock, pile)
		end
		dealDown = dealDown + 1
	end
	if #_G.BAIZE.stock.cards > 0 then
		log.error('Oops - there are still', #_G.BAIZE.stock.cards, 'cards in the Stock')
	end
	if self.relaxed then
		_G.BAIZE.ui:toast('Relaxed version - any card may be placed in an empty pile')
	end
end

function Yukon:afterMove()
end

function Yukon:tailMoveError(tail)
end

function Yukon:tailAppendError(dst, tail)
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

function Yukon:unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownAltColor)
end

function Yukon:pileTapped(pile)
end

function Yukon:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	pile:tailTapped(tail)
end

return Yukon
