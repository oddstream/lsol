-- canfield

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Canfield = {}
Canfield.__index = Canfield
setmetatable(Canfield, {__index = Variant})

function Canfield.new(o)
	o = o or {}
	if o.rainbow then
		o.tabCompareFn = CC.DownWrap
	elseif o.storehouse then
		o.tabCompareFn = CC.DownSuitWrap
	else
		o.tabCompareFn = CC.DownAltColorWrap
	end
	o.wikipedia = 'https://en.wikipedia.org/wiki/Canfield_(solitaire)'
	return setmetatable(o, Canfield)
end

function Canfield:buildPiles()
	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	Reserve.new({x=1, y=3, fanType='FAN_RIGHT'})
	for x = 4, 7 do
		Foundation.new({x=x, y=1})
		-- Cards on the tableau are also moved one unit, provided that the entire column has to be moved.
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TOP_OR_ALL'})
	end
end

function Canfield:startGame()
	local stock = _G.BAIZE.stock

	-- Then a card is placed on first of four foundations to the right of the reserve.
	-- This card is the first foundation card all other cards of the same rank must also start the other three foundations.
	if self.storehouse then
		for _, f in ipairs(_G.BAIZE.foundations) do
			Util.moveCardByOrd(stock, f, 2)
			f.label = '2'
		end
	else
		local card = Util.moveCard(stock, _G.BAIZE.foundations[1])
		for _, pile in ipairs(_G.BAIZE.foundations) do
			pile.label = _G.ORD2STRING[card.ord]
		end
	end

	-- To play the game, one must first deal thirteen cards face down into one packet and then turn the top card up. These cards form the reserve
	for _ = 1, 13 do
		local card = Util.moveCard(stock, _G.BAIZE.reserves[1])
		card.prone = true
	end
	_G.BAIZE.reserves[1]:peek().prone = false

	-- Below the foundations are four piles, each starting with a card each.
	-- This will be the tableau and the top cards of each pile are available for play.
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(stock, pile)
	end

	if self.rainbow then
		_G.BAIZE:setRecycles(0)
	elseif self.storehouse then
		_G.BAIZE:setRecycles(1)
	else
		_G.BAIZE:setRecycles(32767)
	end
end

function Canfield:afterMove()
	-- Any gaps on the tableau are filled from the reserve; in case the reserve is used up, cards from the waste pile are used.
	for _, tab in ipairs(_G.BAIZE.tableaux) do
		if #tab.cards == 0 then
			if #_G.BAIZE.reserves[1].cards > 0 then
				Util.moveCard(_G.BAIZE.reserves[1], tab)
			elseif #_G.BAIZE.waste.cards > 0 then
				Util.moveCard(_G.BAIZE.waste, tab)
			end
		end
	end
end

function Canfield:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		if #tail == 1 then
			return nil
		end
		if #tail ~= #pile.cards then
			return 'Can only move one card, or the whole pile'
		end
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

function Canfield:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuitWrap({dst:peek(), tail[1]})
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

function Canfield:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function Canfield:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		if self.rainbow or self.storehouse then
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		else
			for _ = 1, 3 do
				Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
			end
		end
	else
		pile:tailTapped(tail)
	end
end

return Canfield
