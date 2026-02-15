-- royal cotillion

-- local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local RoyalCotillion = {}
RoyalCotillion.__index = RoyalCotillion
setmetatable(RoyalCotillion, {__index = Variant})

function RoyalCotillion.new(o)
	o.wikipedia = 'https://en.wikipedia.org/wiki/Royal_Cotillion'
	o.tabCompareFn = CC.Any
	return setmetatable(o, RoyalCotillion)
end

function RoyalCotillion:buildPiles()
	self.stock = Stock.new({x=1, y=4, packs=2})
	self.waste = Waste.new({x=2, y=4, fanType='FAN_RIGHT3'})

	self.ladies = {}
	for x = 1, 4 do
		local r = Tableau.new({x=x, y=1, fanType='FAN_DOWN', moveType='MOVE_TOP_ONLY'})
		table.insert(self.ladies, r)
	end

	for y = 1, 4 do
		local f = Foundation.new({x=5.5, y=y})
		f.label = 'A'
	end
	for y = 1, 4 do
		local f = Foundation.new({x=6.5, y=y})
		f.label = '2'
	end

	self.lords = {}
	for x = 8, 11 do
		for y = 1, 4 do
			local r = Reserve.new({x=x, y=y, fanType='FAN_NONE'})
			table.insert(self.lords, r)
		end
	end

end

function RoyalCotillion:startGame()
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[1], 1, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[2], 1, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[3], 1, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[4], 1, '♠')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[5], 2, '♣')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[6], 2, '♦')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[7], 2, '♥')
	Util.moveCardByOrdAndSuit(self.stock, _G.BAIZE.foundations[8], 2, '♠')

	for _, tab in ipairs(self.ladies) do
		Util.moveCard(self.stock, tab)
		Util.moveCard(self.stock, tab)
		Util.moveCard(self.stock, tab)
	end

	for _, tab in ipairs(self.lords) do
		Util.moveCard(self.stock, tab)
	end

	_G.BAIZE:setRecycles(0)
end

function RoyalCotillion:afterMove()
	-- fill empty lords from waste, stock
	for _, tab in ipairs(self.lords) do
		if #tab.cards == 0 then
			if #self.waste.cards > 0 then
				Util.moveCard(self.waste, tab)
			elseif #self.stock.cards > 0 then
				Util.moveCard(self.stock, tab)
			end
		end
	end
end

function RoyalCotillion:moveTailError(tail)
	return nil
end

function RoyalCotillion:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		return CC.UpSuitTwoWrap({dst:peek(), tail[1]})
	elseif dst.category == 'Tableau' then
		return 'Cannot move cards there'
	end
	return nil
end


-- function RoyalCotillion:pileTapped(pile)
-- end

function RoyalCotillion:tailTapped(tail)
	local pile = tail[1].parent
	if pile == self.stock then
		Util.moveCard(self.stock, self.waste)
	else
		return pile:tailTapped(tail)
	end
end

return RoyalCotillion
