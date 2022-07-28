-- crimean/ukrainian

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Discard = require 'pile_discard'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Crimean = {}
Crimean.__index = Crimean
setmetatable(Crimean, {__index = Variant})

function Crimean.new(o)
	o.tabCompareFn = CC.DownSuitWrap
	o.wikipedia = 'https://en.wikipedia.org/wiki/Crimean_(solitaire)'
	return setmetatable(o, Crimean)
end

function Crimean:buildPiles()
	Stock.new({x=-5, y=-5})
	if self.crimean then
		for x = 1, 3 do
			Reserve.new({x=x, y=1, fanType='FAN_NONE'})
		end
	end
	for x = 4, 7 do
		Discard.new({x=x, y=1})
	end
	for x = 1, 7 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
	end
end

function Crimean:startGame()
	local src = _G.BAIZE.stock
	local dealDown = 0
	local dealUp = 7
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, dealDown do
			local card = Util.moveCard(src, t)
			card.prone = true
		end
		dealDown = dealDown + 1
		for _ = 1, dealUp do
			Util.moveCard(src, t)
		end
		dealUp = dealUp - 1
	end

	if self.crimean then
		for _, r in ipairs(_G.BAIZE.reserves) do
			Util.moveCard(src, r)
		end
	elseif self.ukrainian then
		Util.moveCard(src, _G.BAIZE.tableaux[5])
		Util.moveCard(src, _G.BAIZE.tableaux[6])
		Util.moveCard(src, _G.BAIZE.tableaux[7])
	end
	if #_G.BAIZE.stock.cards > 0 then
		log.error('Oops - there are still', #_G.BAIZE.stock.cards, 'cards in the Stock')
	end
	_G.BAIZE:setRecycles(0)
end

-- function Crimean:afterMove()
-- end

function Crimean:moveTailError(tail)
	-- Like Yukon, you can move groups of cards in the tableau regardless of any sequence.
end

function Crimean:tailAppendError(dst, tail)
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
				local err = CC.DownSuit(cpair)
				if err then
					return err
				end
			end
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return nil
		else
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Crimean:pileTapped(pile)
-- end

function Crimean:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	pile:tailTapped(tail)
end

return Crimean
