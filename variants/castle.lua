-- Beleaguered Castle

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Castle = {}
Castle.__index = Castle
setmetatable(Castle, {__index = Variant})

function Castle.new(o)
	o = o or {}
	o.tabCompareFn = CC.Down
	o.wikipedia='https://en.wikipedia.org/wiki/Beleaguered_Castle'
	return setmetatable(o, Castle)
end

function Castle:buildPiles()
	Stock.new({x=4, y=-4, nodraw=true})
	if self.flat then
		for x = 3, 6 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 8 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE'})
		end
	else
		for y = 1, 4 do
			local pile = Foundation.new({x=4, y=y})
			pile.label = 'A'
		end
		for y = 1, 4 do
			Tableau.new({x=3, y=y, fanType='FAN_LEFT', moveType='MOVE_ONE'})
			Tableau.new({x=5, y=y, fanType='FAN_RIGHT', moveType='MOVE_ONE'})
		end
	end
end

function Castle:startGame()
	local src = _G.BAIZE.stock
	for _, pile in ipairs(_G.BAIZE.foundations) do
		Util.moveCardByOrd(src, pile, 1)
	end
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 6 do
			Util.moveCard(src, dst)
		end
	end
	_G.BAIZE:setRecycles(0)
end

-- function Castle:afterMove()
-- end

function Castle:moveTailError(tail)
	return nil
end

function Castle:tailAppendError(dst, tail)
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
			return CC.Down({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Castle:pileTapped(pile)
-- end

-- function Castle:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Castle
