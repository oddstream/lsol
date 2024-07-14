-- american toad

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local AmToad = {}
AmToad.__index = AmToad
setmetatable(AmToad, {__index = Variant})

function AmToad.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownSuitWrap
	o.wikipedia = 'https://en.wikipedia.org/wiki/American_Toad_(solitaire)'
	return setmetatable(o, AmToad)
end

function AmToad:buildPiles()
	Stock.new({x=1, y=1, packs=2})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	Reserve.new({x=4, y=1, fanType='FAN_RIGHT'})
	for x = 1, 8 do
		Foundation.new({x=x, y=2})
		Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_TOP_OR_ALL'})
	end
end

function AmToad:startGame()
	local src = _G.BAIZE.stock

	for _ = 1, 20 do
		local card = Util.moveCard(src, _G.BAIZE.reserves[1])
		card.prone = true
	end
	_G.BAIZE.reserves[1]:peek().prone = false

	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(src, pile)
	end

	local card = Util.moveCard(src, _G.BAIZE.foundations[1])
	for _, pile in ipairs(_G.BAIZE.foundations) do
		pile.label = _G.ORD2STRING[card.ord]
	end

	_G.BAIZE:setRecycles(1)
end

function AmToad:afterMove()
	-- Empty spaces are filled automatically from the reserve
	-- added 2023-01-10
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		if #pile.cards == 0 then
			Util.moveCard(_G.BAIZE.reserves[1], pile)
		end
	end
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function AmToad:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		-- if #tail == 1 then
		-- 	return nil
		-- end
		-- if #tail ~= #pile.cards then
		-- 	return 'Can only move one card, or the whole pile'
		-- end
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

function AmToad:tailAppendError(dst, tail)
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

function AmToad:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function AmToad:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return AmToad
