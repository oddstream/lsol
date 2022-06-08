-- eightoff

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Cell = require 'pile_cell'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local EightOff = {}
EightOff.__index = EightOff
setmetatable(EightOff, {__index = Variant})

function EightOff.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Eight_Off'
	return setmetatable(o, EightOff)
end

function EightOff:buildPiles()
	Stock.new({x=4, y=-4})
	if Util.orientation() == 'landscape' then
		for x = 1, 8 do
			Cell.new({x=x, y=1})
		end
		for x = 1, 8 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
			if not self.relaxed then
				t.label = 'K'
			end
		end
		for y = 1, 4 do
			local f = Foundation.new({x=9.5, y=y})
			f.label = 'A'
		end
	else
		for x = 1, 8 do
			Cell.new({x=x, y=2})
		end
		for x = 1, 8 do
			local t = Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
			if not self.relaxed then
				t.label = 'K'
			end
		end
		for x = 3, 6 do
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
	end
end

function EightOff:startGame()
	local src, dst
	src = _G.BAIZE.stock
	for i = 1, 4 do
		dst = _G.BAIZE.cells[i]
		Util.moveCard(src, dst)
	end
	for i = 1, 8 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 6 do
			Util.moveCard(src, dst)
		end
	end
	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
	if self.relaxed then
		_G.BAIZE.ui:toast('Relaxed version - any card may be placed in an empty pile')
	end
	_G.BAIZE:setRecycles(0)
end

-- function EightOff:afterMove()
-- end

function EightOff:moveTailError(tail)
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

function EightOff:tailAppendError(dst, tail)
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

-- function EightOff:pileTapped(pile)
-- end

-- function EightOff:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return EightOff
