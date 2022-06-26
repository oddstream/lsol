-- gate

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Gate = {}
Gate.__index = Gate
setmetatable(Gate, {__index = Variant})

function Gate.new(o)
	o = o or {}
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia='https://en.wikipedia.org/wiki/Gate_(solitaire)'
	return setmetatable(o, Gate)
end

function Gate:buildPiles()
	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})

	for x = 4, 7 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end

	for y = 2, 6 do
		Reserve.new({x=1, y=y, fanType='FAN_NONE'})
		Reserve.new({x=7, y=y, fanType='FAN_NONE'})
	end

	for x  = 2.5, 5.5 do
		-- could work out boundaryPile by examining piles after buildPiles() is called
		-- but setting them explicitly is more predictable
		local tupper = Tableau.new({x=x, y=2.5, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		local tlower = Tableau.new({x=x, y=5.5, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		tupper.boundaryPile = tlower
	end
end

function Gate:startGame()
	local src = _G.BAIZE.stock
	for _, dst in ipairs(_G.BAIZE.reserves) do
		Util.moveCard(src, dst)
	end
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(src, dst)
	end
	Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)

	_G.BAIZE:setRecycles(0)
end

function Gate:afterMove()
	if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function Gate:moveTailError(tail)
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

function Gate:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuit({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		-- Spaces in the rails are filled using cards from the gate posts.
		-- If the cards in the gate posts are used up, the top card of the wastepile,
		-- or the next card in the stock if there is no wastepile, can be used to fill spaces.
		if #dst.cards == 0 then
			if tail[1].parent.category == 'Waste' then
				for _, r in ipairs(_G.BAIZE.reserves) do
					if #r.cards > 0 then
						return 'Spaces in the rails are filled using cards from the gate posts'
					end
				end
			end
			return CC.Empty(dst, tail[1])
		else
			return CC.DownAltColor({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Gate:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function Gate:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Gate
