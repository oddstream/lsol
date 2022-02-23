-- australian

local log = require 'log'

local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Australian = {}
Australian.__index = Australian

function Australian.new(o)
	o = o or {}
	setmetatable(o, Australian)
	return o
end

function Australian:buildPiles()
	-- log.trace('Australian.buildPiles')
	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	for x = 4, 7 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 7 do
		local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		pile.label = 'K'
	end
end

function Australian:startGame()
	-- log.trace('Australian.startGame')
	local src = _G.BAIZE.stock
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 4 do
			Util.moveCard(src, dst)
		end
	end
	_G.BAIZE:setRecycles(0)
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
end

function Australian:afterMove()
	-- log.trace('Australian.afterMove')
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function Australian:tailMoveError(tail)
	return nil
end

function Australian:tailAppendError(dst, tail)
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

function Australian:unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownSuit)
end

function Australian:pileTapped(pile)
	-- no recycles
end

function Australian:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Australian
