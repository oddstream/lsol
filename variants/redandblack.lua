-- red and black

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local RedAndBlack = {}
RedAndBlack.__index = RedAndBlack
setmetatable(RedAndBlack, {__index = Variant})

function RedAndBlack.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://en.wikipedia.org/wiki/Red_and_Black_(card_game)'
	return setmetatable(o, RedAndBlack)
end

function RedAndBlack:buildPiles()
	Stock.new{x=1, y=1, packs=2}
	Waste.new{x=2, y=1, fanType='FAN_RIGHT3'}

	for x = 1, 8 do
		Foundation.new{x=x, y=2}
		Tableau.new{x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ANY'}
	end
end

function RedAndBlack:startGame()
	for _, pile in ipairs(_G.BAIZE.foundations) do
		Util.moveCardByOrd(_G.BAIZE.stock, pile, 1)
	end
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(_G.BAIZE.stock, pile)
	end
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	_G.BAIZE:setRecycles(0)
end

function RedAndBlack:afterMove()
	if #_G.BAIZE.waste.cards == 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function RedAndBlack:moveTailError(tail)
	local card = tail[1]
	local pile = card.parent
	if pile.category == 'Tableau' then
		if #tail > 1 then
			local cpairs = Util.makeCardPairs(tail)
			for _, cpair in ipairs(cpairs) do
				local err = self.tabCompareFn(cpair)
				if err then
					return err
				end
			end
		end
	end
end

function RedAndBlack:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpAltColor({dst:peek(), tail[1]})
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

-- function RedAndBlack:pileTapped(pile)
-- end

function RedAndBlack:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return RedAndBlack
