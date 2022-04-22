-- blackhole

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'

local Util = require 'util'

local BlackHole = {}
BlackHole.__index = BlackHole
setmetatable(BlackHole, {__index = Variant})

function BlackHole.new(o)
	o.tabCompareFn = CC.UpOrDownWrap
	o.wikipedia = 'https://en.wikipedia.org/wiki/Black_Hole_(solitaire)'
	return setmetatable(o, BlackHole)
end

function BlackHole:buildPiles()

	self.stock = Stock.new({x=-5, y=-5})

	self.foundation = Foundation.new({x=5 + 2, y=2.5 + 1, fanType='FAN_NONE'})

	local locations = {
		-- David Partlett's screenshot shows the cards in a sort of oval around the black hole
		-- but that takes up too much screen space
		-- hence the boxy thing we have here
		{x=2, y=1, f='FAN_LEFT'}, {x=4, y=1, f='FAN_LEFT'}, {x=6, y=1, f='FAN_RIGHT'}, {x=8, y=1, f='FAN_RIGHT'},
		{x=1, y=2, f='FAN_LEFT'}, {x=3, y=2, f='FAN_LEFT'}, {x=7, y=2, f='FAN_RIGHT'}, {x=9, y=2, f='FAN_RIGHT'},
		{x=1, y=3, f='FAN_LEFT'}, {x=3, y=3, f='FAN_LEFT'}, {x=7, y=3, f='FAN_RIGHT'}, {x=9, y=3, f='FAN_RIGHT'},
		{x=1.5, y=4, f='FAN_LEFT'}, {x=3.5, y=4, f='FAN_LEFT'}, {x=5, y=4, f='FAN_DOWN'}, {x=6.5, y=4, f='FAN_RIGHT'}, {x=8.5, y=4, f='FAN_RIGHT'}
	}
	if #locations ~= 17 then
		log.error("There are " .. #locations .. " when there should be 17")
	end

	for _, location in ipairs(locations) do
		Reserve.new({x=location.x + 2, y=location.y + 1, fanType=location.f})
	end

end

function BlackHole:startGame()

	-- "Put the Ace of spades in the middle of the board as the base or "black hole"."
	Util.moveCardByOrdAndSuit(_G.BAIZE.stock, self.foundation, 1, '♠')

	for _, dst in ipairs(_G.BAIZE.reserves) do
		for _ = 1, 3 do
			Util.moveCard(self.stock, dst)
		end
	end

	if #_G.BAIZE.stock.cards ~= 0 then
		log.error('Cards remaining in Stock', #_G.BAIZE.stock.cards)
	end

	_G.BAIZE:setRecycles(0)

end

function BlackHole:tailAppendError(dst, tail)

	if dst.category == 'Foundation' then
		return CC.UpOrDownWrap({dst:peek(), tail[1]})
	end
	return nil
end

-- function BlackHole:unsortedPairs(pile)
-- 	return #pile.cards
-- end

-- function BlackHole:pileTapped(pile)
-- 	-- no recycles
-- end

return BlackHole
