-- sea haven towers

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Cell = require 'pile_cell'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local SeaHaven = {}
SeaHaven.__index = SeaHaven
setmetatable(SeaHaven, {__index = Variant})

function SeaHaven.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Seahaven_Towers'
	return setmetatable(o, SeaHaven)
end

function SeaHaven:buildPiles()
	Stock.new({x=4, y=-4})
	for x = 1, 4 do
		Cell.new({x=x, y=1})
	end
	for x = 7, 10 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 1, 10 do
		local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
		t.label = 'K'
	end
end

function SeaHaven:startGame()
	local stock
	stock = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 5 do
			Util.moveCard(stock, t)
		end
	end
	Util.moveCard(stock, _G.BAIZE.cells[2])
	Util.moveCard(stock, _G.BAIZE.cells[3])
	if #stock.cards > 0 then
		log.error('still', #stock.cards, 'cards in Stock')
	end
end

-- function SeaHaven:afterMove()
-- end

function SeaHaven:moveTailError(tail)
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

function SeaHaven:tailAppendError(dst, tail)
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

-- function SeaHaven:pileTapped(pile)
-- end

-- function SeaHaven:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return SeaHaven
