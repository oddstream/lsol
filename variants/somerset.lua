-- somerset

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Somerset = {}
Somerset.__index = Somerset
setmetatable(Somerset, {__index = Variant})

function Somerset.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://politaire.com/help/somerset'
	o.layouts = {
		{x = 1, n = 1},
		{x = 2, n = 2},
		{x = 3, n = 3},
		{x = 4, n = 4},
		{x = 5, n = 5},
		{x = 6, n = 6},
		{x = 7, n = 7},
		{x = 8, n = 8},
		{x = 9, n = 8},
		{x = 10, n = 8},
	}
	return setmetatable(o, Somerset)
end

function Somerset:buildPiles()
	Stock.new({x=-4, y=-4, nodraw=true})
	for x = 7, 10 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for _, layout in ipairs(self.layouts) do
		local tab = Tableau.new({x=layout.x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
		if not self.relaxed then
			tab.label = 'K'
		end
	end
end

function Somerset:dealCards()
	local stock = _G.BAIZE.stock
	for _, layout in ipairs(self.layouts) do
		local tab = _G.BAIZE.tableaux[layout.x]
		for _ = 1, layout.n do
			Util.moveCard(stock, tab)
		end
	end
end

function Somerset:startGame()
	self:dealCards()
	_G.BAIZE:setRecycles(0)
end

function Somerset:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownAltColor(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Somerset:tailAppendError(dst, tail)
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

return Somerset
