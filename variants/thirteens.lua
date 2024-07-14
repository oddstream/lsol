-- thirteens

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Thirteens = {}
Thirteens.__index = Thirteens
setmetatable(Thirteens, {__index = Variant})

function Thirteens.new(o)
	o.tabCompareFn = CC.Thirteen
	o.wikipedia = 'https://en.wikipedia.org/wiki/Good_Thirteen'
	return setmetatable(o, Thirteens)
end

function Thirteens:buildPiles()
	Stock.new({x=1, y=1, nodraw=true})
	Foundation.new({x=10, y=1})
	for x = 1, 10 do
		Tableau.new({x=x, y=2, fanType='FAN_NONE', moveType='MOVE_TOP_ONLY'})
	end
end

function Thirteens:startGame()
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(_G.BAIZE.stock, pile)
	end
	_G.BAIZE:setRecycles(0)
end

function Thirteens:afterMove()
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		if #pile.cards == 2 then
			if pile.cards[1].ord + pile.cards[2].ord == 13 then
				Util.moveCard(pile, _G.BAIZE.foundations[1])
				Util.moveCard(pile, _G.BAIZE.foundations[1])
			end
		end
	end
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		if #pile.cards == 0 then
			Util.moveCard(_G.BAIZE.stock, pile)
		end
	end
end

function Thirteens:moveTailError(tail)
	return nil
end

function Thirteens:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if tail[1].ord ~= 13 then
			return 'You can only move a King directly to the foundation'
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			-- nothing
		else
			return CC.Thirteen({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Thirteens:unsortedPairs(pile)
-- 	return 0
-- end

-- function Thirteens:pileTapped(pile)
-- end

function Thirteens:tailTapped(tail)
	if tail[1].ord == 13 then
		tail[1].parent:tailTapped(tail)
	end
end

return Thirteens
