-- frog

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Frog = {}
Frog.__index = Frog
setmetatable(Frog, {__index = Variant})

function Frog.new(o)
	o = o or {}
	o.tabCompareFn = CC.Any
	o.wikipedia = 'https://en.wikipedia.org/wiki/Frog_(patience)'
	return setmetatable(o, Frog)
end

function Frog:buildPiles()
	self.stock = Stock.new({x=1, y=1, packs=2, faceUpStock=true, nodraw=true})
	for x = 2.5, 9.5 do
		local f = Foundation.new({x=x, y=1})
		f.label = 'A'
	end
	for x = 4, 8 do
		Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ONE'})
	end
	self.reserve = Reserve.new({x=1, y=2, fanType='FAN_DOWN'})
end

function Frog:startGame()
	local src = _G.BAIZE.stock

	if self.dealAllAces then
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[1], 1, '♣')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[2], 1, '♦')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[3], 1, '♥')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[4], 1, '♠')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[5], 1, '♣')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[6], 1, '♦')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[7], 1, '♥')
		Util.moveCardByOrdAndSuit(src, _G.BAIZE.foundations[8], 1, '♠')

		for _ = 1, 13 do
			Util.moveCard(src, self.reserve)
		end
	else
		local nextFound = 1
		while #self.reserve.cards ~= 13 do
			local c = src:pop()
			if c.ord == 1 then
				_G.BAIZE.foundations[nextFound]:push(c)
				nextFound = nextFound + 1
			else
				self.reserve:push(c)
			end
		end
		-- "In case there is no ace segregated in making the reserve,
		-- an ace is removed from the stock to become the first foundation"
		if #_G.BAIZE.foundations[1].cards == 0 then
			Util.moveCardByOrd(src, _G.BAIZE.foundations[8], 1)
		end
	end

	_G.BAIZE:setRecycles(0)
end

-- function Frog:afterMove()
-- end

function Frog:moveTailError(tail)
	return nil
end

function Frog:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			-- "The foundations are built up regardless of suit up to kings."
			return CC.Up({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		-- "once a card is in a wastepile [tableau], it stays there until it can be built on the foundations"
		-- cannot move tab to tab or reserve to tab
		local src = tail[1].parent
		if src.category == 'Tableau' then
			return 'Cannot move a card from Tableau to Tableau'
		end
		if src == self.reserve then
			return 'Cannot move a card from the Reserve to a Tableau'
		end
	end
	return nil
end

-- function Frog:pileTapped(pile)
-- end

function Frog:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == self.stock and #tail == 1 then
		local homes = Util.findHomesForTail(tail)
		if homes and #homes > 0 then
			if #homes > 1 then
				-- put card in the emptiest pile (sort < instead of >)
				table.sort(homes, function(a,b) return a.weight < b.weight end)
			end
			if homes[#homes].dst.category == 'Foundation' then
				-- unless one of the homes is a foundation
				Util.moveCard(self.stock, homes[#homes].dst)
			else
				Util.moveCard(self.stock, homes[1].dst)
			end
		end
	else
		pile:tailTapped(tail)
	end
end

return Frog
