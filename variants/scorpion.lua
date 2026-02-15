-- scorpion

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Discard = require 'pile_discard'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Scorpion = {}
Scorpion.__index = Scorpion
setmetatable(Scorpion, {__index = Variant})

function Scorpion.new(o)
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Scorpion_(solitaire)'
	return setmetatable(o, Scorpion)
end

function Scorpion:buildPiles()
	Stock.new({x=1, y=1, nodraw=true})
	for x = 4, 7 do
		Discard.new({x=x, y=1})
	end
	for x = 1, 7 do
		local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		if not self.relaxed then
			t.label = 'K'
		end
	end
end

function Scorpion:startGame()
	local stock = _G.BAIZE.stock
	for x = 1, 4 do
		local pile = _G.BAIZE.tableaux[x]
		for _ = 1, 3 do
			local card = Util.moveCard(stock, pile)
			card.prone = true
		end
		for _ = 4, 7 do
			Util.moveCard(stock, pile)
		end
	end
	for x = 5, 7 do
		local pile = _G.BAIZE.tableaux[x]
		for _ = 1, 7 do
			Util.moveCard(stock, pile)
		end
	end
	_G.BAIZE:setRecycles(0)
end

-- function Scorpion:afterMove()
-- end

function Scorpion:moveTailError(tail)
end

function Scorpion:tailAppendError(dst, tail)
	if dst.category == 'Discard' then
		if #dst.cards == 0 then
			-- already checked before coming here
			-- if #tail ~= 13 then
			-- 	return 'Can only discard 13 cards'
			-- end
			if tail[1].ord ~= 13 then
				return 'Can only discard starting from a King'
			end
			local cpairs = Util.makeCardPairs(tail)
			for _, cpair in ipairs(cpairs) do
				local err = self.tabCompareFn(cpair)
				if err then
					return err
				end
			end
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

function Scorpion:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE.ui:toast('No more cards in Stock', 'blip')
	end
end

function Scorpion:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock then
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			Util.moveCard(_G.BAIZE.stock, tab)
		end
	else
		pile:tailTapped(tail)
	end
end

return Scorpion
