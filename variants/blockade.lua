-- blockade

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Blockade = {}
Blockade.__index = Blockade
setmetatable(Blockade, {__index = Variant})

function Blockade.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Blockade_(solitaire)'
	o.packs = o.packs or 2
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	return setmetatable(o, Blockade)
end

function Blockade:buildPiles()
	Stock.new{x=1, y=1, packs=self.packs, suitFilter=self.suitFilter}

	for x = 5, 12 do
		local pile = Foundation.new{x=x, y=1}
		pile.label = 'A'
	end
	for x = 1, 12 do
		Tableau.new{x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'}
	end
end

function Blockade:startGame()
	_G.BAIZE:setRecycles(0)
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(_G.BAIZE.stock, pile)
	end
end

-- function Blockade:afterMove()
-- end

function Blockade:moveTailError(tail)
	local card = tail[1]
	local pile = card.parent
	if pile.category == 'Tableau' then
		if #tail > 1 then
			local cpairs = Util.makeCardPairs(tail)
			for _, cpair in ipairs(cpairs) do
				local err = CC.DownSuit(cpair)
				if err then
					return err
				end
			end
		end
	end
end

function Blockade:tailAppendError(dst, tail)
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
			return CC.DownSuit({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Blockade:pileTapped(pile)
-- end

function Blockade:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			Util.moveCard(_G.BAIZE.stock, tab)
		end
	else
		pile:tailTapped(tail)
	end
end

return Blockade
