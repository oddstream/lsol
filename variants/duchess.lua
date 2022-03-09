-- duchess

--[[
    Duchess (also Dutchess) is a patience or solitaire card game which uses a deck of 52 playing cards.
    It has all four typical features of a traditional solitaire game: a tableau, a reserve, a stock and a waste pile, and is quite easy to win.
    It is closely related to Canfield.
]]

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Duchess = {}
Duchess.__index = Duchess
setmetatable(Duchess, {__index = Variant})

function Duchess.new(o)
	o = o or {}
	o.wikipedia='https://en.wikipedia.org/wiki/Duchess_(solitaire)'
	return setmetatable(o, Duchess)
end

function Duchess:buildPiles()
	log.trace('Duchess.buildPiles')
	Stock.new{x=1, y=2}

	for i = 1, 4 do
		Reserve.new{x=(i*2)-1, y=1, fanType='FAN_RIGHT3'}
	end

	Waste.new{x=1, y=3, fanType='FAN_DOWN3'}

	assert(#_G.BAIZE.foundations == 0)
	for x = 3, 6 do
		local f = Foundation.new{x=x, y=2}
		assert(not f.label)
	end

	for x = 3, 6 do
		Tableau.new{x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ANY'}
	end
end

function Duchess:startGame()
	log.trace('Duchess.startGame')

	_G.BAIZE:setRecycles(1)

	local src = _G.BAIZE.stock

	for _, pile in ipairs(_G.BAIZE.foundations) do
		pile.label = nil
	end

	for _, pile in ipairs(_G.BAIZE.reserves) do
		Util.moveCard(src, pile)
		Util.moveCard(src, pile)
		Util.moveCard(src, pile)
	end

	for _, pile in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(src, pile)
	end

	_G.BAIZE.ui:toast('Choose a Reserve card and move it to a Foundation')
end

function Duchess:afterMove()
	local f1 = _G.BAIZE.foundations[1]
	if not f1.label then
		-- To start the game, the player will choose among the top cards of the reserve fans which will start the first foundation pile.
		-- Once he/she makes that decision and picks a card, the three other cards with the same rank,
		-- whenever they become available, will start the other three foundations.
		for _, f in ipairs(_G.BAIZE.foundations) do
			-- find where the first card landed
			if #f.cards > 0 then
				local c = f:peek()
				-- grab it's ordinal and apply it to all the foundations
				for _, pile in ipairs(_G.BAIZE.foundations) do
					pile.label = _G.ORD2STRING[c.ord]
				end
				break
			end
		end
	end
end

function Duchess:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownAltColorWrap(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function Duchess:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			if not dst.label then
				if tail[1].parent.category ~= 'Reserve' then
					return 'The first Foundation card must come from a Reserve'
				end
			end
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuitWrap({dst:peek(), tail[1]})
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			-- Spaces that occur on the tableau are filled with any top card in the reserve.
			-- If the entire reserve is exhausted however, it is not replenished;
			-- spaces that occur after this point have to be filled with cards from the waste pile or,
			-- if a wastepile has not been made yet, the stock.
			if tail[1].parent.category == 'Waste' then
				for _, res in ipairs(_G.BAIZE.reserves) do
					if #res.cards > 0 then
						return 'An empty Tableau must be filled from a Reserve'
					end
				end
			end
		else
			return CC.DownAltColorWrap({dst:peek(), tail[1]})
		end
	end
	return nil
end

function Duchess:unsortedPairs(pile)
	return Util.unsortedPairs(pile, CC.DownAltColorWrap)
end

function Duchess:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE:recycleWasteToStock()
	end
end

function Duchess:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Duchess
