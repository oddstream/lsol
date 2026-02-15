-- australian

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Australian = {}
Australian.__index = Australian
setmetatable(Australian, {__index = Variant})

function Australian.new(o)
	o.tabCompareFn = CC.DownSuit
	o.wikipedia='https://en.wikipedia.org/wiki/Australian_Patience'
	return setmetatable(o, Australian)
end

function Australian:buildPiles()
	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	for x = 4, 7 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 7 do
		local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
		pile.label = 'K'
	end
end

function Australian:startGame()
	local stock = _G.BAIZE.stock
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 4 do
			Util.moveCard(stock, dst)
		end
	end

	Util.moveCard(stock, _G.BAIZE.waste)

	_G.BAIZE:setRecycles(0)
end

function Australian:afterMove()
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function Australian:moveTailError(tail)
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

-- function Australian:pileTapped(pile)
-- 	-- no recycles
-- end

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
