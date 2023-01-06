-- class Discard, derived from Pile

local Pile = require 'pile'
local Util = require 'util'
local CC = require 'cc'

local Discard = {}
Discard.__index = Discard
setmetatable(Discard, {__index = Pile})

function Discard.new(o)
	o.category = 'Discard'
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_NONE'
	o = Pile.prepare(o)
	table.insert(_G.BAIZE.piles, o)
	table.insert(_G.BAIZE.discards, o)
	return setmetatable(o, Discard)
end

function Discard:push(c)
	Pile.push(self, c)
	-- Discard cards are always prone
	c:flipDown()
end

function Discard:acceptTailError(tail)
	if #self.cards ~= 0 then
		return 'Can only move cards to an empty Discard'
	end
	for _, c in ipairs(tail) do
		if c.prone then
			return 'Cannot move a face down card to a Discard'
		end
	end
	if #tail ~= #_G.BAIZE.deck / #_G.BAIZE.discards then
		return 'Can only move a full set of cards to a Discard'
	end
	-- added 2023-01
	if Util.unsortedPairs(tail, CC.DownSuit) > 0 then
		return 'Cards must the the same suit and go down in rank'
	end
	-- Scorpion tails can always be moved, but Mrs Mop/Simple Simon tails
	-- must be conformant to be moved
	return _G.BAIZE.script:moveTailError(tail)
end

function Discard:tailTapped(tail)
	-- do nothing
end

function Discard:unsortedPairs()
	-- you can only put a sorted sequence into a Discard, so this will always be zero
	return 0
end

function Discard:draw()
	local b = _G.BAIZE
	local x, y = self:screenPos()

	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.setLineWidth(1)
	love.graphics.rectangle('fill', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
end

return Discard
