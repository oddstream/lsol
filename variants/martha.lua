-- martha

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Martha = {}
Martha.__index = Martha
setmetatable(Martha, {__index = Variant})

function Martha.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://en.wikipedia.org/wiki/Martha_(solitaire)'
	return setmetatable(o, Martha)
end

function Martha:buildPiles()
	Stock.new({x=-5, y=-5, nodraw=true})
	for x = 9, 12 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 12 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_TAIL'})
	end
end

function Martha:startGame()
	local src = _G.BAIZE.stock
	for _, f in ipairs(_G.BAIZE.foundations) do
		Util.moveCardByOrd(src, f, 1)
	end
	for _, t in ipairs(_G.BAIZE.tableaux) do
		local card = Util.moveCard(src, t)
		card.prone = true

		Util.moveCard(src, t)

		card = Util.moveCard(src, t)
		card.prone = true

		Util.moveCard(src, t)
	end
	_G.BAIZE:setRecycles(0)
end

-- function Martha:afterMove()
-- end

function Martha:moveTailError(tail)
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

function Martha:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuit({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			if #tail > 1 then
				return 'Can only move a single card to an empty tableau'
			end
		else
			return CC.DownAltColor({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Martha:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		for _ = 1, self.turn do
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		end
	else
		pile:tailTapped(tail)
	end
end

return Martha
