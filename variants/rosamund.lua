-- rosamund's bower

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'
local Waste = require 'pile_waste'

local Util = require 'util'

local Rosamund = {}
Rosamund.__index = Rosamund
setmetatable(Rosamund, {__index = Variant})

function Rosamund.new(o)
	o.tabCompareFn = CC.None
	o.wikipedia = 'https://en.wikipedia.org/wiki/Rosamund%27s_Bower'
	return setmetatable(o, Rosamund)
end

function Rosamund:buildPiles()
	Stock.new({x=1, y=6})
	Waste.new({x=2, y=6, fanType='FAN_RIGHT3'})

	self.henry = Reserve.new({x=5, y=1, fanType='FAN_NONE'})		-- will contain K clubs
	self.extraGuards = Reserve.new({x=6, y=1, fanType='FAN_NONE'})	-- will contain 7 cards

	self.outerGuards = {}
	self.outerGuards[1] = Reserve.new({x=3,y=1, fanType = 'FAN_NONE'})	-- top
	self.outerGuards[2] = Reserve.new({x=3,y=5, fanType = 'FAN_NONE'})	-- bottom
	self.outerGuards[3] = Reserve.new({x=1,y=3, fanType = 'FAN_NONE'})	-- left
	self.outerGuards[4] = Reserve.new({x=5,y=3, fanType = 'FAN_NONE'})	-- right

	self.innerGuards = {}
	self.innerGuards[1] = Reserve.new({x=3,y=2, fanType = 'FAN_NONE'})	-- top
	self.innerGuards[2] = Reserve.new({x=3,y=4, fanType = 'FAN_NONE'})	-- bottom
	self.innerGuards[3] = Reserve.new({x=2,y=3, fanType = 'FAN_NONE'})	-- left
	self.innerGuards[4] = Reserve.new({x=4,y=3, fanType = 'FAN_NONE'})	-- right

	self.rosamund = Reserve.new({x=3,y=3, fanType='FAN_NONE'})

	self.foundation = Foundation.new({x=1, y=5})

	self.rubbish = {}
	self.rubbish[1] = Tableau.new({x=1,y=7, fanType='FAN_NONE', moveType='MOVE_TOP_ONLY'})	-- rubbish heap
	self.rubbish[2] = Tableau.new({x=2,y=7, fanType='FAN_NONE', moveType='MOVE_TOP_ONLY'})	-- rubbish heap
	self.rubbish[3] = Tableau.new({x=3,y=7, fanType='FAN_NONE', moveType='MOVE_TOP_ONLY'})	-- rubbish heap
end

function Rosamund:startGame()
	local stock = _G.BAIZE.stock
	Util.moveCardByOrdAndSuit(stock, self.rosamund, 12, '♥')
	Util.moveCardByOrdAndSuit(stock, self.henry, 13, '♣')
	Util.moveCardByOrdAndSuit(stock, self.foundation, 11, '♠')

	for _ = 1, 7 do
		local card = Util.moveCard(stock, self.extraGuards)
		card.prone = true
	end
	for _, pile in ipairs(self.innerGuards) do
		Util.moveCard(stock, pile)
	end
	for _, pile in ipairs(self.outerGuards) do
		Util.moveCard(stock, pile)
	end

	Util.moveCard(stock, _G.BAIZE.waste)

	_G.BAIZE:setRecycles(3)
end

function Rosamund:afterMove()
	-- replace empty outerGuards with a card from extraGuards
	if #self.extraGuards.cards > 0 then
		for _, guard in ipairs(self.outerGuards) do
			if #guard.cards == 0 then
				-- don't use Util.moveCard() because it flips up exposed card
				local card = self.extraGuards:pop()
				guard:push(card)
				card:flipUp()
			end
		end
	end
	if #_G.BAIZE.waste.cards == 0 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	end
end

function Rosamund:moveTailError(tail)
end

function Rosamund:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		-- if card is from innerGuards, it's corresponding outerGuard must be empty
		local src = tail[1].parent
		if src.category == 'Reserve' then
			local contains, index = _G.table.contains(self.innerGuards, src)
			if contains then
				if #self.outerGuards[index].cards ~= 0 then
					return 'Must use an outer guard before an inner guard'
				end
			end
		end
		if #tail == 1 then
			if src == self.henry and #self.foundation.cards ~= 50 then
				return 'Henry must be the penultimate card placed'
			end
			if src == self.rosamund and #self.foundation.cards ~= 51 then
				return 'Rosamund must be the last card placed'
			end
		end
		-- self.foundation will never be empty
		return CC.DownWrap({dst:peek(), tail[1]})
	elseif dst.category == 'Tableau' then
		local src = tail[1].parent
		if src.category == 'Tableau' then
			return 'Cards cannot be moved between rubbish heaps'
		end
		if src.category == 'Reserve' then
			return 'Cards cannot be moved from a guard to a rubbish heap'
		end
	end
	return nil
end

function Rosamund:pileTapped(pile)
	if pile.category == 'Stock' then
		local stock = pile
		local waste = _G.BAIZE.waste
		if _G.BAIZE.recycles > 0 then
			while #waste.cards > 0 do
				Util.moveCard(waste, stock)
			end
			for _, rub in ipairs(self.rubbish) do
				while #rub.cards > 0 do
					Util.moveCard(rub, stock)
				end
			end
			_G.BAIZE:setRecycles(_G.BAIZE.recycles - 1)
			if _G.BAIZE.recycles == 0 then
				_G.BAIZE.ui:toast('No more recycles', 'blip')
			elseif _G.BAIZE.recycles == 1 then
				_G.BAIZE.ui:toast('One more recycle')
			elseif _G.BAIZE.recycles < 10 then
				_G.BAIZE.ui:toast(string.format('%d recycles remaining', _G.BAIZE.recycles))
			end
		else
			_G.BAIZE.ui:toast('No more recycles', 'blip')
		end
	end
end

function Rosamund:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.moveCard(_G.BAIZE.stock, _G.BAIZE.waste)
	else
		pile:tailTapped(tail)
	end
end

return Rosamund
