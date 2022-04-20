-- assembly

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Assembly = {}
Assembly.__index = Assembly
setmetatable(Assembly, {__index = Variant})

function Assembly.new(o)
	o = o or {}
	o.tabCompareFn = CC.Down
	o.wikipedia = 'https://politaire.com/help/assembly'
	return setmetatable(o, Assembly)
end

function Assembly:buildPiles()
	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT'})
	for x = 1, 4 do
		local f = Foundation.new({x=x, y=2})
		f.label = 'A'
	end
	for x = 1, 4 do
		Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
	end
end

function Assembly:startGame()
	local src = _G.BAIZE.stock
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(src, dst)
	end
end

function Assembly:afterMove()
end

function Assembly:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = self.tabCompareFn(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Assembly:tailAppendError(dst, tail)
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
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Assembly:pileTapped(pile)
end

function Assembly:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Assembly
