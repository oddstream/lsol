-- debug

local log = require 'log'

local CC = require 'cc'

local Discard = require 'pile_discard'
local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Debug = {}
Debug.__index = Debug

function Debug.new(o)
	o = o or {}
	setmetatable(o, Debug)
	return o
end

function Debug:buildPiles()
	_G.PATIENCE_SETTINGS.fourColorCards = true

	Stock.new({x=4, y=-4})
	for x = 5.5, 8.5 do
		if self.spiderLike then
			Discard.new({x=x, y=1})
		else
			local f = Foundation.new({x=x, y=1})
			f.label = 'A'
		end
	end
	for x = 1, 13 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
	end
end

function Debug:startGame()
	local src
	src = _G.BAIZE.stock

	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for i = 1, 4 do
			Util.moveCard(src, dst)
		end
	end

	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
end

function Debug:afterMove()
end

function Debug:tailMoveError(tail)
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

function Debug:tailAppendError(dst, tail)
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
	elseif dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuit({dst:peek(), tail[1]})
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

function Debug:unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownSuit)
end

function Debug:pileTapped(pile)
end

function Debug:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	pile:tailTapped(tail)
end

return Debug
