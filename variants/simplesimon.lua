-- simplesimon

local log = require 'log'

local CC = require 'cc'

local Discard = require 'pile_discard'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local SimpleSimon = {}
SimpleSimon.__index = SimpleSimon

function SimpleSimon.new(o)
	o = o or {}
	setmetatable(o, SimpleSimon)
	return o
end

function SimpleSimon:buildPiles()
	_G.PATIENCE_SETTINGS.fourColorCards = true

	Stock.new({x=4, y=-4})
	for x = 4, 7 do
		Discard.new({x=x, y=1})
	end
	for x = 1, 10 do
	-- for x = 1, 13 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
	end
end

function SimpleSimon:startGame()
	local src, dst
	src = _G.BAIZE.stock

	-- 3 piles of 8 cards each
	for i = 1, 3 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 8 do
			Util.moveCard(src, dst)
		end
	end
	local deal = 7
	for i = 4, 10 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, deal do
			Util.moveCard(src, dst)
		end
		deal = deal - 1
	end
--[[
	for _, p in ipairs(_G.BAIZE.tableaux) do
		for i = 1, 4 do
			Util.moveCard(src, p)
		end
	end
]]
	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
end

function SimpleSimon:afterMove()
end

function SimpleSimon:tailMoveError(tail)
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

function SimpleSimon:tailAppendError(dst, tail)
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

function SimpleSimon:unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownSuit)
end

function SimpleSimon:pileTapped(pile)
end

function SimpleSimon:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	pile:tailTapped(tail)
end

return SimpleSimon