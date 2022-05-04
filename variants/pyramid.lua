-- pyramid

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
-- local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Pyramid = {}
Pyramid.__index = Pyramid
setmetatable(Pyramid, {__index = Variant})

local function tableauxCards()
	local cards = 0
	for _, pile in ipairs(_G.BAIZE.tableaux) do
		cards = cards + #pile.cards
	end
	return cards
end

function Pyramid.new(o)
	o.tabCompareFn = CC.Thirteen
	o.wikipedia = 'https://en.wikipedia.org/wiki/Pyramid_(solitaire)'
	return setmetatable(o, Pyramid)
end

function Pyramid:buildPiles()

	local nx = 1
	local xfirst = 3

	for y = 1, 4, 0.5 do
		for x = 1, nx do
			Tableau.new({x=xfirst+x, y=y, fanType='FAN_NONE', moveType='MOVE_ONE', nodraw=true})
		end
		nx = nx + 1
		xfirst = xfirst - 0.5
	end

	self.stock = Stock.new({x=3, y=6})
	self.waste = Waste.new({x=4, y=6, fanType='FAN_NONE', moveType='MOVE_ONE'})
	self.foundation = Foundation.new({x=5, y=6, fanType='FAN_NONE'})
	self.tableaux = _G.BAIZE.tableaux
end

function Pyramid:startGame()
	for _, dst in ipairs(self.tableaux) do
		Util.moveCard(self.stock, dst)
	end

	Util.moveCard(self.stock, self.waste)
	_G.BAIZE:setRecycles(0)
end

function Pyramid:isCardOverlapped(card)
	local src = card.parent
	local ax, ay, aw, ah = src:baizeRect()
	for _, pile in ipairs(self.tableaux) do
		if (src ~= pile) and (#pile.cards > 0) and (pile.slot.y > src.slot.y) then
			local bx, by, bw, bh = pile:baizeRect()
			local area = Util.overlapArea(ax, ay, aw, ah, bx, by, bw, bh)
			if area > 0 then
				-- log.info('Card', tostring(card), 'is overlapped by', tostring(pile.cards[1]))
				return true
			end
		end
	end
	return false
end

function Pyramid:afterMove()

	for _, tab in ipairs(self.tableaux) do
		if #tab.cards > 1 then
			while #tab.cards > 0 do
				local c = table.remove(tab.cards, 1)
				self.foundation:push(c)
			end
		end
	end

		-- The top card of the waste pile can be matched at any time with the next card drawn from the stock
	if #self.waste.cards > 1 then
		if CC.Thirteen({self.waste.cards[#self.waste.cards], self.waste.cards[#self.waste.cards - 1]}) == nil then
			local c = self.waste:pop()
			self.foundation:push(c)
			c = self.waste:pop()
			self.foundation:push(c)
		end
	end
end

function Pyramid:moveTailError(tail)
	return nil
end

function Pyramid:tailAppendError(dst, tail)

	if #tail > 1 then
		return 'Cannot move more than one card'
	end

	if tail[1].prone then
		return 'Cannot move a face down card'
	end

	if self:isCardOverlapped(tail[1]) then
		return 'Cannot move an overlapped card'
	end

	if dst.category == 'Foundation' then
		if tail[1].ord == 13 then
			return nil
		else
			return 'Can only move a King there'
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return 'Cannot move a card there'
		elseif self:isCardOverlapped(dst.cards[1]) then
			return 'Cannot match with an overlapped card'
		else
			return CC.Thirteen({dst:peek(), tail[1]})
		end
	end
	log.error('What are we doing here?')
	return nil
end

-- function Pyramid:unsortedPairs(pile)
-- 	return #pile.cards
-- end

function Pyramid:percentComplete()
	if self.relaxed then
		local cards = tableauxCards()
		return 100 - Util.mapValue(28 - cards, 0, 28, 100, 0)
	else
		return Util.mapValue(52 - #self.foundation.cards, 0, 52, 100, 0)
	end
end

function Pyramid:complete()
	if self.relaxed then
		return tableauxCards() == 0
	else
		return #self.foundation.cards == 52
	end
end

-- function Pyramid:pileTapped(pile)
-- 	-- no recycles
-- end

function Pyramid:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == self.stock and #tail == 1 then
		Util.moveCard(self.stock, self.waste)
	else
		pile:tailTapped(tail)
	end
end

return Pyramid
