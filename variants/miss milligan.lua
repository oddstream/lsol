-- miss milligan

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local MissMilligan = {}
MissMilligan.__index = MissMilligan
setmetatable(MissMilligan, {__index = Variant})

function MissMilligan.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://en.wikipedia.org/wiki/Miss_Milligan'
	o.packs = o.packs or 2
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	return setmetatable(o, MissMilligan)
end

function MissMilligan:buildPiles()
	self.stock = Stock.new{x=1, y=1, packs=self.packs, suitFilter=self.suitFilter, nodraw=true}

	self.foundations = {}
	for x = 3, 10 do
		local pile = Foundation.new{x=x, y=1}
		pile.label = 'A'
		table.insert(self.foundations, pile)
	end

	self.tableaux = {}
	for x = 3, 10 do
		local tab = Tableau.new{x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'}
		if not self.giant then
			tab.label = 'K'
		end
		table.insert(self.tableaux, tab)
	end

	if not self.giant then
		self.weaving = Tableau.new{x=1, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'}
	end
end

function MissMilligan:startGame()
	for _, tab in ipairs(self.tableaux) do
		Util.moveCard(_G.BAIZE.stock, tab)
	end
	_G.BAIZE:setRecycles(0)
end

function MissMilligan:afterMove()
end

function MissMilligan:moveTailError(tail)
	local card = tail[1]
	local pile = card.parent
	if pile.category == 'Tableau' then
		if #tail > 1 then
			local cpairs = Util.makeCardPairs(tail)
			for _, cpair in ipairs(cpairs) do
				local err = CC.DownAltColor(cpair)
				if err then
					return err
				end
			end
		end
	end
end

function MissMilligan:tailAppendError(dst, tail)
	-- can only move a pile to the weaving when (a) stock is empty and (b) weaving is empty

	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuit({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if self.weaving and dst == self.weaving then
			if #self.stock.cards > 0 then
				return 'Cannot use the weaving until the stock is empty'
			elseif #self.weaving.cards > 0 then
				return 'The weaving is already in use'
			else
				return CC.Empty(dst, tail[1])
			end
		else
			if #dst.cards == 0 then
				return CC.Empty(dst, tail[1])
			else
				return CC.DownAltColor({dst:peek(), tail[1]})
			end
		end
	end
	return nil
end

-- function MissMilligan:pileTapped(pile)
-- end

function MissMilligan:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == self.stock and #tail == 1 then
		for _, tab in ipairs(self.tableaux) do
			Util.moveCard(self.stock, tab)
		end
	else
		pile:tailTapped(tail)
	end
end

return MissMilligan
