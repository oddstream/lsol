-- agnes

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Reserve = require 'pile_reserve'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Agnes = {}
Agnes.__index = Agnes
setmetatable(Agnes, {__index = Variant})

function Agnes.new(o)
	if o.sorel then
		o.tabCompareFn = CC.DownSuitWrap
	elseif o.bernauer then
		o.tabCompareFn = CC.DownAltColorWrap
	end
	o.wikipedia = 'https://en.wikipedia.org/wiki/Agnes_(card_game)'
	return setmetatable(o, Agnes)
end

function Agnes:buildPiles()
	Stock.new({x=1, y=1})
	for x = 4, 7 do
		Foundation.new({x=x, y=1})
	end
	if self.bernauer then
		for x = 1, 7 do
			Reserve.new({x=x, y=2, fanType='FAN_NONE', moveType='MOVE_ANY'})
		end
		for x = 1, 7 do
			Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		end
	elseif self.sorel then
		for x = 1, 7 do
			Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		end
	end
end

function Agnes:startGame()
	local src = _G.BAIZE.stock
	if self.bernauer then
		local dealDown = 0
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, dealDown do
				local card = Util.moveCard(src, dst)
				card.prone = true
			end
			dealDown = dealDown + 1
			Util.moveCard(src, dst)
		end
		for _, dst in ipairs(_G.BAIZE.reserves) do
			Util.moveCard(src, dst)
		end
	elseif self.sorel then
		local dealDown = 6
		for _, dst in ipairs(_G.BAIZE.tableaux) do
			for _ = 1, dealDown do
				local card = Util.moveCard(src, dst)
				card.prone = true
			end
			dealDown = dealDown - 1
			Util.moveCard(src, dst)
		end
	end
	local card = Util.moveCard(src, _G.BAIZE.foundations[1])
	for _, f in ipairs(_G.BAIZE.foundations) do
		f.label =  _G.ORD2STRING[card.ord]
	end
	if self.bernauer then
		-- A tableau vacancy may only be filled by a card of the next lower rank as the base.
		local ord = card.ord - 1
		if ord == 0 then ord = 13 end
		for _, f in ipairs(_G.BAIZE.tableaux) do
			f.label =  _G.ORD2STRING[ord]
		end
	end
end

function Agnes:afterMove()
end

function Agnes:moveTailError(tail)
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

function Agnes:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			return CC.UpSuitWrap({dst:peek(), tail[1]})
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

function Agnes:pileTapped(pile)
end

function Agnes:tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		if self.sorel then
			for _, dst in ipairs(_G.BAIZE.tableaux) do
				Util.moveCard(_G.BAIZE.stock, dst)
			end
		elseif self.bernauer then
			for _, dst in ipairs(_G.BAIZE.reserves) do
				Util.moveCard(_G.BAIZE.stock, dst)
			end
		end
	else
		pile:tailTapped(tail)
	end
end

return Agnes
