-- the fan

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local TheFan = {}
TheFan.__index = TheFan
setmetatable(TheFan, {__index = Variant})

function TheFan.new(o)
	o = o or {}
	o.wikipedia = 'https://en.wikipedia.org/wiki/La_Belle_Lucie'
	o.tabCompareFn = CC.DownSuit
	o.moveType = 'MOVE_TOP_ONLY'
	return setmetatable(o, TheFan)
end

function TheFan:buildPiles()
	Stock.new({x=4, y=-4})
	if Util.orientation() == 'landscape' then
		for x = 6, 9 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 9 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType})
			t.label = 'K'
		end
		for x = 1, 9 do
			local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType=self.moveType})
			t.label = 'K'
		end
		for i = 1, 9 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+9]
		end
	else	-- portrait
		for x = 3, 6 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType})
			t.label = 'K'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType=self.moveType})
			t.label = 'K'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=6, fanType='FAN_DOWN', moveType=self.moveType})
			t.label = 'K'
		end
		for i = 1, 6 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+6]
		end
		for i = 7, 12 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+6]
		end
	end
end

function TheFan:startGame()
	local src = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 3 do
			Util.moveCard(src, t)
		end
	end
	_G.BAIZE:setRecycles(0)
end

function TheFan:afterMove()
end

function TheFan:moveTailError(tail)
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

function TheFan:tailAppendError(dst, tail)
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
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

--[[
function TheFan:pileTapped(pile)
end
]]

--[[
function TheFan:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
end
]]

return TheFan
