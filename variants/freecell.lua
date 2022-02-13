-- freecell

local log = require 'log'

local CC = require 'cc'

local Cell = require 'cell'
local Foundation = require 'foundation'
local Stock = require 'stock'
local Tableau = require 'tableau'

local Util = require 'util'

local Freecell = {}
Freecell.__index = Freecell

function Freecell.new(params)
	local o = {}
	setmetatable(o, Freecell)
	return o
end

function Freecell.buildPiles()
	_G.PATIENCE_SETTINGS.fourColorCards = false

	Stock.new({x=4, y=-4})
	for x = 1, 4 do
		Cell.new({x=x, y=1})
	end
	for x = 5, 8 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 1, 8 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
	end
end

function Freecell.startGame()
	local src, dst
	src = _G.BAIZE.stock
	for i = 1, 4 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 7 do
			Util.moveCard(src, dst)
		end
	end
	for i = 5, 8 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 6 do
			Util.moveCard(src, dst)
		end
	end
	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
end

function Freecell.afterMove()
end

function Freecell.tailMoveError(tail)
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

function Freecell.tailAppendError(dst, tail)
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

function Freecell.unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownAltColor)
end

function Freecell.pileTapped(pile)
end

function Freecell.tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	pile:tailTapped(tail)
end

return Freecell
