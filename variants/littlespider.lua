-- little spider

-- local log = require 'log'

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
	for x = 3, 6 do
		Tableau.new({x=x, y=1, fanType='FAN_NONE', moveType='MOVE_ONE'})
	end
	for x = 3, 4 do
		local f = Foundation.new({x=x, y=2})
		f.label = 'A'
	end
	for x = 5, 6 do
		local f = Foundation.new({x=x, y=2})
		f.label = 'K'
	end
	for x = 3, 6 do
		Tableau.new({x=x, y=3, fanType='FAN_NONE', moveType='MOVE_ONE'})
	end
end

function LittleSpider:startGame()
	local stock = _G.BAIZE.stock
	for _, t in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(stock, t)
	end
	_G.BAIZE:setRecycles(0)
end

local function IsAceFoundation(f)
	return f.label == 'A'
end

local function IsKingFoundation(f)
	return f.label == 'K'
end

local function IsTopTableau(t)
	return t.category == 'Tableau' and t.slot.y == 1
end

local function IsBottomTableau(t)
	return t.category == 'Tableau' and t.slot.y == 3
end

local function IsFoundationAbove(f, t)
	return f.slot.x == t.slot.x
end

function LittleSpider:afterMove()
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
			if IsBottomTableau(src) then
				if src.slot.x ~= dst.slot.x then
					return 'Cards from the lower row can only be placed on the foundation directly above'
				end
			end
		end

		if #dst.cards == 0 then
			-- be lazy for the moment, and only allow red aces and black kings
			local card = tail[1]
			if card.ord == 1 and card.black == true then
				return 'Expecting a red A'
			elseif card.ord == 13 and card.black ~= true then
				return 'Expecting a black K'
			end
			return CC.Empty(dst, tail[1])
		else
			if dst == _G.BAIZE.foundations[1] or dst == _G.BAIZE.foundations[2] then
				return CC.UpSuit({dst:peek(), tail[1]})
			else
				return CC.DownSuit({dst:peek(), tail[1]})
			end
		end
	elseif dst.category == 'Tableau' then
		if #_G.BAIZE.stock.cards > 0 then
			return 'Cannot move cards there'
		end
		return CC.UpOrDownWrap({dst:peek(), tail[1]})
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
