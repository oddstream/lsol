-- stock, derived from pile

local Card = require 'card'
local Pile = require 'pile'
local Util = require 'util'

local Stock = {}
Stock.__index = Stock   -- Stock's own __index looks in Stock for methods
setmetatable(Stock, {__index = Pile}) -- failing that, Stock's metatable then looks in base class for methods

function Stock.new(o)
	o.category = 'Stock'
	o.ordFilter = o.ordFilter or {1,2,3,4,5,6,7,8,9,10,11,12,13}
	o.suitFilter = o.suitFilter or {'♣','♦','♥','♠'}
	o.packs = o.packs or 1
	o.fanType = 'FAN_NONE'
	o.moveType = 'MOVE_ONE'

	o = Pile.prepare(o)
	setmetatable(o, Stock)

	for pack = 1, o.packs do
		for _, ord in ipairs(o.ordFilter) do
			for _, suit in ipairs(o.suitFilter) do
				Pile.push(o, Card.new({pack=pack, ord=ord, suit=suit, prone=true}))
				-- card parent is assigned in Pile.push
			end
		end
	end
	-- log.info('made', #o.cards, 'cards')

	o:shuffle()

	-- register the new pile with the baize
	table.insert(_G.BAIZE.piles, o)
	_G.BAIZE.stock = o

	-- create a shadow copy of all the cards
	-- so that when restoring the piles from a saved baize
	-- all the cards can be found in one place
	_G.BAIZE.deck = {}
	for _, c in ipairs(o.cards) do
		table.insert(_G.BAIZE.deck, c)
	end
	-- assert(#o.cards == #_G.BAIZE.deck)

	return o
end

function Stock:shuffle()
	-- used to run this 6 times, but, honestly, I can't tell the difference between 6 and 1
	for i = #self.cards, 2, -1 do
		local j = math.random(i)
		if i ~= j then
			self.cards[i], self.cards[j] = self.cards[j], self.cards[i]
		end
	end
end

function Stock:push(c)
	Pile.push(self, c)
	-- Stock cards are always prone
	c:flipDown()
end

function Stock:pop()
	local c = Pile.pop(self)
	if c then
		c:flipUp()
	end
	return c
end

-- vtable functions

function Stock:acceptCardError(c)
	return 'Cannot move cards to the Stock'
end

function Stock:acceptTailError(tail)
	return 'Cannot move cards to the Stock'
end

function Stock:tailTapped(tail)
	-- do nothing, handled by script, which had first dibs
end

function Stock:unsortedPairs()
	-- they're all unsorted, even if they aren't
	if #self.cards == 0 then
		return 0
	end
	return #self.cards - 1
end

function Stock:draw()

	if self:hidden() then
		return
	end

	local b = _G.BAIZE
	local x, y = self:screenPos()

	if b.showMovable and b.recycles > 0 then
		Util.setColorFromSetting('hintColor')
		love.graphics.setLineWidth(3)
		love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius, 20)
	else
		love.graphics.setColor(1, 1, 1, 0.1)
		love.graphics.rectangle('line', x, y, b.cardWidth, b.cardHeight, b.cardRadius, b.cardRadius)
	end
--[[
	if self.rune then
		love.graphics.setColor(1, 1, 1, 0.1)
		love.graphics.setFont(b.runeFont)
		love.graphics.print(self.rune,
			x + b.cardWidth / 2,
			y + b.cardHeight / 2,
			0,	-- orientation
			1,	-- x scale
			1,	-- y scale
			b.runeFont:getWidth(self.rune) / 2,		-- origin offset
			b.runeFont:getHeight() / 2)				-- origin offset
	end
]]
	local icon
	if b.recycles == 0 then
		icon = _G.LSOL_ICON_RESTART_OFF
	else
		icon = _G.LSOL_ICON_RESTART
	end
	-- icons are currently 48x48
	-- scale so icon width,height is half of pile/card width
	local iw, ih = icon:getWidth(), icon:getHeight()
	local scale = b.cardWidth / iw / 2
	x = x + (b.cardWidth - (iw*scale)) / 2
	y = y + (b.cardHeight - (ih*scale)) / 2

	local mx, my = love.mouse.getPosition()
	if Util.inRect(mx, my, self:screenRect()) then
		if love.mouse.isDown(1) then
			x = x + 2
			y = y + 2
		end
	end

	love.graphics.setColor(1, 1, 1, 0.1)
	love.graphics.draw(icon,
		x, y,
		0,	-- rotation
		scale, scale
	)
end

return Stock
