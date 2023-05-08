-- Bisley

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Bisley = {}
Bisley.__index = Bisley
setmetatable(Bisley, {__index = Variant})

function Bisley.new(o)
	o = o or {}
	o.tabCompareFn = CC.UpOrDownSuit
	o.wikipedia='https://en.wikipedia.org/wiki/Bisley_(card_game)'
	return setmetatable(o, Bisley)
end

function Bisley:buildPiles()
	Stock.new({x=6, y=-4})

	self.downFoundations = {}
	for x = 1, 4 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'K'
		table.insert(self.downFoundations, pile)
	end

	self.upFoundations = {}
	for x = 1, 4 do
		local pile = Foundation.new({x=x, y=2})
		pile.label = 'A'
		table.insert(self.upFoundations, pile)
	end

	-- assert(#self.upFoundations==4)
	-- assert(#self.downFoundations==4)

	for x = 1, 13 do
		local pile = Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ONE', nodraw=true})
		if not self.debug then
			pile.label = 'X'
		end
	end
end

function Bisley:startGame()
	-- assert(#self.upFoundations==4)
	-- assert(#self.downFoundations==4)

	local src = _G.BAIZE.stock

	for _, dst in ipairs(self.upFoundations) do
		Util.moveCardByOrd(src, dst, 1)
	end
	for i = 1, 4 do
		local dst = _G.BAIZE.tableaux[i]
		for _ = 1, 3 do
			Util.moveCard(src, dst)
		end
	end
	for i = 5, 13 do
		local dst = _G.BAIZE.tableaux[i]
		for _ = 1, 4 do
			Util.moveCard(src, dst)
		end
	end
	-- assert(#src.cards ~= 0)
end

-- function Bisley:afterMove()
-- end

function Bisley:moveTailError(tail)
	return nil
end

function Bisley:tailAppendError(dst, tail)
	if dst.category == 'Foundation' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			if table.contains(self.upFoundations, dst) then
				return CC.UpSuit({dst:peek(), tail[1]})
			else
				return CC.DownSuit({dst:peek(), tail[1]})
			end
		end
	elseif dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return CC.Empty(dst, tail[1])
		else
			if self.debug then
				return nil
			else
				return CC.UpOrDownSuit({dst:peek(), tail[1]})
			end
		end
	end
	return nil
end

-- function Bisley:pileTapped(pile)
-- end

-- function Bisley:tailTapped(tail)
-- 	local card = tail[1]
-- 	local pile = card.parent
-- 	pile:tailTapped(tail)
-- end

return Bisley
