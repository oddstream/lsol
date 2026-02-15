-- spider

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Discard = require 'pile_discard'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Spider = {}
Spider.__index = Spider
setmetatable(Spider, {__index = Variant})

function Spider.new(o)
	o.tabCompareFn = CC.DownSuit
	o.wikipedia = 'https://en.wikipedia.org/wiki/Spider_(solitaire)'
	o.packs = o.packs or 2
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	return setmetatable(o, Spider)
end

function Spider:buildPiles()
	Stock.new({x=1, y=1, packs=self.packs, suitFilter=self.suitFilter, nodraw=true})
	if self.spiderette then
		for x = 4, 7 do
			Discard.new({x=x, y=1})
		end
		for x = 1, 7 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		end
	else
		for x = 3, 10 do
			Discard.new({x=x, y=1})
		end
		for x = 1, 10 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		end
	end
end

function Spider:startGame()
	local src = _G.BAIZE.stock
	if self.spiderette then
		local deal = 0
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, deal do
				Util.moveCard(src, dst)
			end
			deal = deal + 1
			Util.moveCard(src, dst)
		end
	else
		for x = 1, 4 do
			local pile = _G.BAIZE.tableaux[x]
			for _ = 1,4 do
				local card = Util.moveCard(src, pile)
				card.prone = true
			end
			Util.moveCard(src, pile)
		end
		for x = 5, 10 do
			local pile = _G.BAIZE.tableaux[x]
			for _ = 1,3 do
				local card = Util.moveCard(src, pile)
				card.prone = true
			end
			Util.moveCard(src, pile)
		end
	end
	_G.BAIZE:setRecycles(0)
end

-- function Spider:afterMove()
-- end

function Spider:moveTailError(tail)
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

function Spider:tailAppendError(dst, tail)
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
			return CC.Down({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Spider:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE.ui:toast('No more cards in Stock', 'blip')
	end
end

function Spider:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock then
		local tabCards = 0
		local emptyTabs = 0
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			if #tab.cards == 0 then
				emptyTabs = emptyTabs + 1
			else
				tabCards = tabCards + #tab.cards
			end
		end
		if emptyTabs > 0 and tabCards >= #_G.BAIZE.tableaux then
			_G.BAIZE.ui:toast("All empty tableaux must be filled before dealing a new row", 'blip')
		else
			for _, tab in ipairs(_G.BAIZE.tableaux) do
				Util.moveCard(_G.BAIZE.stock, tab)
			end
		end
	else
		pile:tailTapped(tail)
	end
end

return Spider
