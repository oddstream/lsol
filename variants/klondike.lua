-- klondike

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Klondike = {}
Klondike.__index = Klondike
setmetatable(Klondike, {__index = Variant})

function Klondike.new(o)
	o = o or {}
	if o.whitehead then
		o.tabCompareFn = CC.DownColor
	else
		o.tabCompareFn = CC.DownAltColor
	end
	if o.gargantua then
		o.packs = 2
		o.wikipedia = 'https://en.wikipedia.org/wiki/Gargantua_(card_game)'
	elseif o.triple then
		o.packs = 3
		o.wikipedia = 'https://en.wikipedia.org/wiki/Klondike_(solitaire)'
	else
		o.packs = 1
		o.wikipedia = 'https://en.wikipedia.org/wiki/Klondike_(solitaire)'
	end
	o.turn = o.turn or 1
	return setmetatable(o, Klondike)
end

function Klondike:buildPiles()
	Stock.new({x=1, y=1, packs=self.packs})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	if self.athena then
		for x = 4, 7 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 7 do
			local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
			pile.label = 'K'
		end
	elseif self.gargantua then
		for x = 4, 11 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 3, 11 do
			local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
			pile.label = 'K'
		end
	elseif self.triple then
		for x = 4, 15 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 5, 15 do
			local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
			pile.label = 'K'
		end
	else
		for x = 4, 7 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 7 do
			local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
			if not self.whitehead then pile.label = 'K' end
		end
	end
end

function Klondike:startGame()
	local src = _G.BAIZE.stock
	if self.athena then
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _= 1, 2 do
				local card = Util.moveCard(src, dst)
				if not (self.thoughtful or self.whitehead) then card.prone = true end
				Util.moveCard(src, dst)
			end
		end
	else
		local dealDown = 0
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, dealDown do
				local card = Util.moveCard(src, dst)
				if not (self.thoughtful or self.whitehead) then card.prone = true end
			end
			dealDown = dealDown + 1
			Util.moveCard(src, dst)
		end
		for _ = 1, self.turn do
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		end
	end
	_G.BAIZE:setRecycles(32767)
end

function Klondike:afterMove()
	-- log.trace('Klondike.afterMove')
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		for _ = 1, self.turn do
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		end
	end
end

function Klondike:moveTailError(tail)
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

function Klondike:tailAppendError(dst, tail)
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

function Klondike:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function Klondike:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		for _ = 1, self.turn do
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		end
	else
		pile:tailTapped(tail)
	end
end

return Klondike
