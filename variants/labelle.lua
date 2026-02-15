-- la belle lucie

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local LaBelleLucie = {}
LaBelleLucie.__index = LaBelleLucie
setmetatable(LaBelleLucie, {__index = Variant})

function LaBelleLucie.new(o)
	o = o or {}
	o.wikipedia = 'https://en.wikipedia.org/wiki/La_Belle_Lucie'
	o.tabCompareFn = CC.DownSuit
	o.moveType = 'MOVE_TOP_ONLY'
	o.merciUsed = false	-- TODO will not survive undo
	return setmetatable(o, LaBelleLucie)
end

function LaBelleLucie:buildPiles()
	Stock.new({x=1, y=1})
	if Util.orientation() == 'landscape' then
		for x = 6, 9 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 9 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
			t.label = 'X'
		end
		for x = 1, 9 do
			local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
			t.label = 'X'
		end
		for i = 1, 9 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+9]
		end
	else	-- portrait
		for x = 3, 6 do
			local pile = Foundation.new({x=x, y=1})
			pile.label = 'A'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
			t.label = 'X'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=4, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
			t.label = 'X'
		end
		for x = 1, 6 do
			local t = Tableau.new({x=x, y=6, fanType='FAN_DOWN', moveType=self.moveType, nodraw=true})
			t.label = 'X'
		end
		for i = 1, 6 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+6]
		end
		for i = 7, 12 do
			_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.tableaux[i+6]
		end
	end
end

function LaBelleLucie:startGame()
	local src = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 3 do
			Util.moveCard(src, t)
		end
	end
	_G.BAIZE:setRecycles(2)
	self.merciUsed = false
end

function LaBelleLucie:afterMove()
	assert(self.merciAllowed~=nil)
	assert(self.merciUsed~=nil)

	-- if self.merciAllowed and (not self.merciUsed) and (_G.BAIZE.status == 'stuck') then
	if self.merciAllowed and (not self.merciUsed) and (_G.BAIZE.recycles == 0) then
		_G.BAIZE.ui:toast('Merci move can be used')
	end
end

function LaBelleLucie:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = self.tabCompareFn(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function LaBelleLucie:tailAppendError(dst, tail)
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
			return self.tabCompareFn({dst:peek(), tail[1]})
		end
	end
	return nil
end

function LaBelleLucie:pileTapped(pile)
	if pile.category ~= 'Stock' then
		return
	end
	if _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more reshuffles', 'blip')
		return
	end
	local stock = _G.BAIZE.stock
	-- collect cards
	for _, tab in ipairs(_G.BAIZE.tableaux) do
		for i = 1, #tab.cards do
			table.insert(stock.cards, tab.cards[i])
		end
		tab.cards = {}
	end
	-- shuffle stock
	stock:shuffle()
	-- redeal cards
	for _, t in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, 3 do
			Util.moveCard(stock, t)
		end
	end
	_G.BAIZE:setRecycles(_G.BAIZE.recycles - 1)
	if _G.BAIZE.recycles == 0 then
		_G.BAIZE.ui:toast('No more reshuffles')
	elseif _G.BAIZE.recycles == 1 then	-- bug fix for version 31
		_G.BAIZE.ui:toast('One more reshuffle')
	end
end

--[[
function LaBelleLucie:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
end
]]

function LaBelleLucie:cardSelected(card)
	assert(self.merciAllowed~=nil)
	assert(self.merciUsed~=nil)

	if not self.merciAllowed then
		return false
	end
	if self.merciUsed then
		return false
	end
	-- if _G.BAIZE.status ~= 'stuck' then
	if _G.BAIZE.recycles > 0 then
		return false
	end

	local pile = card.parent
	-- can't move the top card to the top of this pile
	if card == pile:peek() then
		return false
	end

	-- move card to the top of the pile
	for i, c in ipairs(pile.cards) do
		if c == card then
			table.remove(pile.cards, i)
			break
		end
	end
	table.insert(pile.cards, card)

	-- refan the pile
	do
		local tmp = {}
		while #pile.cards > 0 do
			table.insert(tmp, table.remove(pile.cards))
		end
		while #tmp > 0 do
			pile:push(table.remove(tmp))
		end
	end

	self.merciUsed = true
	_G.BAIZE.ui:toast('Merci!')
	_G.BAIZE:afterUserMove()
	_G.BAIZE:afterAfterUserMove()
	return true
end

return LaBelleLucie
