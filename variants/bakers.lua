-- baker's dozen

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local BakersDozen = {}
BakersDozen.__index = BakersDozen
setmetatable(BakersDozen, {__index = Variant})

function BakersDozen.new(o)
	o = o or {}
	o.tabCompareFn = CC.Down
	o.wikipedia = 'https://en.wikipedia.org/wiki/Baker%27s_Dozen_(card_game)'
	return setmetatable(o, BakersDozen)
end

function BakersDozen:buildPiles()
	Stock.new({x=-5, y=-5})
	if self.wide then
		for x = 10, 13 do
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
		for x = 1, 13 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TOP_ONLY', nodraw=true})
			t.label = 'X'
		end
	else
		for y = 1, 4 do
			local f = Foundation.new({x=8.5, y=y})
			f.label = 'A'
		end
		for x = 1, 7 do
			local t = Tableau.new({x=x, y=1, fanType='FAN_DOWN', moveType='MOVE_TOP_ONLY', nodraw=true})
			t.label = 'X'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType='MOVE_TOP_ONLY', nodraw=true})
			t.label = 'X'
		end
		for i = 1, 6 do
			local t = _G.BAIZE.tableaux[i]
			t.boundaryPile = _G.BAIZE.tableaux[i+7]
		end
	end
end

function BakersDozen:startGame()
	local src
	src = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 4 do
			Util.moveCard(src, t)
		end
		t:buryCards(13)
	end
	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
end

-- function BakersDozen:afterMove()
-- end

function BakersDozen:moveTailError(tail)
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

function BakersDozen:tailAppendError(dst, tail)
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

-- function BakersDozen:pileTapped(pile)
-- end

-- function BakersDozen:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

function BakersDozen:fcSolver()
	return 'bakers_dozen'
end

return BakersDozen
