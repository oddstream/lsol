-- penguin

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Cell = require 'pile_cell'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Penguin = {}
Penguin.__index = Penguin
setmetatable(Penguin, {__index = Variant})

function Penguin.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuitWrap
	o.wikipedia = 'https://en.wikipedia.org/wiki/Penguin_(solitaire)'
	return setmetatable(o, Penguin)
end

function Penguin:buildPiles()
	Stock.new{x=5, y=-5, nodraw=true}
	if Util.orientation() == 'landscape' then
		-- the flipper, seven cells
		for x = 1, 7 do
			Cell.new{x=x, y=1}
		end
		for y = 1, 4 do
			Foundation.new{x=8.5, y=y}
		end
		for x = 1, 7 do
			Tableau.new{x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'}
		end
	else
		-- the flipper, seven cells
		for x = 1, 7 do
			Cell.new{x=x, y=2}
		end
		for x = 2.5, 5.5 do
			Foundation.new{x=x, y=1}
		end
		for x = 1, 7 do
			Tableau.new{x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ANY'}
		end
	end
end

function Penguin:startGame()
	-- Shuffle a 52-card pack and deal the first card face up to the top left of the board.
	-- This card is called the Beak.
	local faccept = _G.BAIZE.stock:peek().ord
	for _, f in ipairs(_G.BAIZE.foundations) do
		f.label = _G.ORD2STRING[faccept]
	end
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.tableaux[1])

	_G.BAIZE.stock:disinterOneCardByOrd(faccept)
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.foundations[1])
	_G.BAIZE.stock:disinterOneCardByOrd(faccept)
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.foundations[2])
	_G.BAIZE.stock:disinterOneCardByOrd(faccept)
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.foundations[3])

	-- 49-card layout consisting of seven rows and seven columns
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		while #pile.cards < 7 do
			Util.moveCard(_G.BAIZE.stock, pile)
		end
	end

	if #_G.BAIZE.stock.cards > 0 then
		log.error('Oops - there are still', #_G.BAIZE.stock.cards, 'cards in the Stock')
	end

	-- When you empty a column, you may fill the space it leaves with a card one rank lower than the rank of the beak,
	-- together with any other cards attached to it in descending suit-sequence.
	-- For example, since the beak is a Ten, you can start a new column only with a Nine,
	-- or a suit-sequence headed by a Nine.

	local taccept = faccept - 1
	if taccept == 0 then
		taccept = 13
	end
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		pile.label = _G.ORD2STRING[taccept]
	end
	_G.BAIZE:setRecycles(0)
end

-- function Penguin:afterMove()
-- end

function Penguin:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownSuitWrap(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Penguin:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuitWrap({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.DownSuitWrap({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Penguin:pileTapped(pile)
-- end

-- function Penguin:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Penguin
