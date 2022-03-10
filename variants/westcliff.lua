-- westcliff

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local West = {}
West.__index = West
setmetatable(West, {__index = Variant})

function West.new(o)
	o.tabCompareFn = CC.DownAltColor
	o.wikipedia = 'https://en.wikipedia.org/wiki/Westcliff_(card_game)'
	return setmetatable(o, West)
end

function West:buildPiles()
	Stock.new({x=1, y=1})
	if self.classic then
		Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
		for x = 4, 7 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 7 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
			-- no label
		end
	elseif self.american then
		Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
		for x = 7, 10 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 10 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
			-- no label
		end
	elseif self.easthaven then
		-- no waste pile
		for x = 4, 7 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 7 do
			local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
			pile.label = 'K'
		end
	end
end

function West:startGame()
	local src = _G.BAIZE.stock
	if self.classic then
		for i = 1, 4 do
			Util.moveCardByOrd(src, _G.BAIZE.foundations[i], 1)
		end
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, 2 do
				local card = Util.moveCard(src, dst)
				card.prone = true
			end
			Util.moveCard(src, dst)
		end
		Util.moveCard(src, _G.BAIZE.waste)
	elseif self.american then
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, 2 do
				local card = Util.moveCard(src, dst)
				card.prone = true
			end
			Util.moveCard(src, dst)
		end
		Util.moveCard(src, _G.BAIZE.waste)
	elseif self.easthaven then
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, 2 do
				local card = Util.moveCard(src, dst)
				card.prone = true
			end
			Util.moveCard(src, dst)
		end
	end
	_G.BAIZE:setRecycles(0)
end

function West:afterMove()
	if _G.BAIZE.waste then
		if #_G.BAIZE.waste.cards == 0 and #_G.BAIZE.stock.cards > 0 then
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		end
	end
end

function West:moveTailError(tail)
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

function West:tailAppendError(dst, tail)
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

-- function West:pileTapped(pile)
-- 	-- no recycles
-- end

function West:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		if self.classic or self.american then
			Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
		elseif self.easthaven then
			local src = _G.BAIZE.stock
			if #src.cards > 0 then
				for _, tab in ipairs(_G.BAIZE.tableaux) do
					Util.moveCard(src, tab)
				end
			end
		end
	else
		pile:tailTapped(tail)
	end
end

return West
