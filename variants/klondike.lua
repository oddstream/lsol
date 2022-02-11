-- klondike

local log = require 'log'

local CC = require 'cc'
local Foundation = require 'foundation'
local Stock = require 'stock'
local Tableau = require 'tableau'
local Waste = require 'waste'

local Util = require 'util'

local Klondike = {}
Klondike.__index = Klondike

function Klondike.new(params)
	local o = {}
	setmetatable(o, Klondike)
	return o
end

function Klondike.buildPiles()
	log.trace('Klondike.buildPiles')

	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	for x = 5, 8 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 8 do
		local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		pile.label = 'K'
	end
	_G.BAIZE:setRecycles(32767)
end

function Klondike.startGame()
	log.trace('Klondike.startGame')

	local src = _G.BAIZE.stock
	local dealDown = 0
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, dealDown do
			local card = Util.moveCard(src, dst)
			card.prone = true
		end
		dealDown = dealDown + 1
		Util.moveCard(src, dst)
	end
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
end

function Klondike.afterMove()
	-- log.trace('Klondike.afterMove')
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function Klondike.tailMoveError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownAltColor(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end
--[[
function Klondike.Tableau.tailMoveError(tail)
	local cpairs = Util.makeCardPairs(tail)
	for _, cpair in ipairs(cpairs) do
		local err = CC.DownAltColor(cpair)
		if err then
			return err
		end
	end
	return nil
end
]]

function Klondike.tailAppendError(dst, tail)
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
			return CC.DownAltColor({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Klondike.pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function Klondike.tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(pile, _G.BAIZE.waste)
	else
		log.trace('tap on card from pile', pile.category)
		pile:tailTapped(tail)
	end
end

return Klondike
