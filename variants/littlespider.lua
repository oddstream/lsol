-- little spider

local log = require 'log'

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local LittleSpider = {}
LittleSpider.__index = LittleSpider
setmetatable(LittleSpider, {__index = Variant})

function LittleSpider.new(o)
	o.wikipedia = 'https://en.wikipedia.org/wiki/Little_Spider'
	o.tabCompareFn = CC.None
	return setmetatable(o, LittleSpider)
end

function LittleSpider:buildPiles()
	Stock.new({x=1, y=1})
	if self.fanned then
		self.topTabY = 1
		self.foundY = 3.5
		self.bottomTabY = 6
		self.fanFanType = 'FAN_DOWN'
	else
		self.topTabY = 1
		self.foundY = 2
		self.bottomTabY = 3
		self.fanFanType = 'FAN_NONE'
	end
	for x = 2.5, 5.5 do
		Tableau.new({x=x, y=self.topTabY, fanType=self.tabFanType, moveType='MOVE_ONE'})
	end
	for x = 2.5, 3.5 do
		local f = Foundation.new({x=x, y=self.foundY})
		f.label = 'A'
	end
	for x = 4.5, 5.5 do
		local f = Foundation.new({x=x, y=self.foundY})
		f.label = 'K'
	end
	for x = 2.5, 5.5 do
		Tableau.new({x=x, y=self.bottomTabY, fanType=self.tabFanType, moveType='MOVE_ONE'})
	end

	for i = 1, 4 do
		_G.BAIZE.tableaux[i].boundaryPile = _G.BAIZE.foundations[i]
	end
end

local function placedAceColor()
	local founds = _G.BAIZE.foundations
	if #founds[1].cards > 0 then
		return founds[1].cards[1].twoColor
	end
	if #founds[2].cards > 0 then
		return founds[2].cards[1].twoColor
	end
	return 'none'
end

local function placedKingColor()
	local founds = _G.BAIZE.foundations
	if #founds[3].cards > 0 then
		return founds[3].cards[1].twoColor
	end
	if #founds[4].cards > 0 then
		return founds[4].cards[1].twoColor
	end
	return 'none'
end

function LittleSpider:startGame()
	local stock = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(stock, t)
	end
	_G.BAIZE:setRecycles(0)
end

function LittleSpider:afterMove()
	log.trace('ace =', placedAceColor(), 'king =', placedKingColor())
end

function LittleSpider:moveTailError(tail)
	local pile = tail[1].parent
	if pile.category == 'Tableau' then
		local cpairs = Util.makeCardPairs(tail)
		for _, cpair in ipairs(cpairs) do
			local err = CC.DownSuit(cpair)
			if err then
				return err
			end
		end
	end
	return nil
end

function LittleSpider:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		-- during phase #1 (when stock has cards)
		-- Cards from the upper row can be placed on any of the foundations,
		-- while cards from the lower row can only be placed on the foundations directly on top of [above] it.
		if #_G.BAIZE.stock.cards > 0 then
			local src = tail[1].parent
			if src.category == 'Tableau' and src.slot.y == self.bottomTabY then
				if src.slot.x ~= dst.slot.x then
					return 'Cards from the lower row can only be placed on the foundation directly above'
				end
			end
		end

		if #dst.cards == 0 then
			local pac = placedAceColor()
			local pkc = placedKingColor()
			local card = tail[1]
			local cc = card.twoColor

			if dst.label == 'A' and card.ord == 1 then
				if not (pac == 'none' or pac == cc) then
					return 'Expecting a ' .. pac .. ' A'
				end
				if pkc == cc then
					return 'Already placed a ' .. pkc .. ' K'
				end
			elseif dst.label == 'K' and card.ord == 13 then
				if not (pkc == 'none' or pkc == cc) then
					return 'Expecting a ' .. pkc .. ' K'
				end
				if pac == cc then
					return 'Already placed a ' .. pac .. ' A'
				end
			end
			return CC.Empty(dst, card)
		else
			if dst == _G.BAIZE.foundations[1] or dst == _G.BAIZE.foundations[2] then
				return CC.UpSuit({dst:peek(), tail[1]})
			else
				return CC.DownSuit({dst:peek(), tail[1]})
			end
		end
	elseif dst.category == 'Tableau' then
		if #_G.BAIZE.stock.cards > 0 then
			return 'Cannot move cards there until stock is dealt'
		end
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpOrDownWrap({dst:peek(), tail[1]})
		end
	end
	return nil
end

function LittleSpider:pileTapped(pile)
	if pile.category == 'Stock' then
		_G.BAIZE.ui:toast('No more cards in Stock', 'blip')
	end
end

function LittleSpider:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock then
		for _, tab in ipairs(_G.BAIZE.tableaux) do
			Util.moveCard(_G.BAIZE.stock, tab)
		end
	else
		pile:tailTapped(tail)
	end
end

return LittleSpider
