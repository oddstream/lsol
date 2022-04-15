-- accordian

local Variant = require 'variant'
local CC = require 'cc'

local Foundation = require 'pile_foundation'
local Stock = require 'pile_stock'
local Tableau = require 'pile_tableau'

local Util = require 'util'

local Accordian = {}
Accordian.__index = Accordian
setmetatable(Accordian, {__index = Variant})

function Accordian.new(o)
	o.tabCompareFn = CC.Accordian
	o.wikipedia='https://en.wikipedia.org/wiki/Accordion_(card_game)'
	return setmetatable(o, Accordian)
end

function Accordian:buildPiles()
	-- log.trace('Accordian.buildPiles')
	Stock.new({x=7, y=-5})

	for y = 1, 4 do
		for x = 1, 13 do
			Tableau.new({x=x, y=y, fanType='FAN_NONE', moveType='MOVE_ONE'})
		end
	end

	Foundation.new({x=7, y=-5})
end

function Accordian:startGame()
	-- log.trace('Accordian.startGame')
	local src = _G.BAIZE.stock
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		Util.moveCard(src, dst)
	end
end

function Accordian:afterMove()
	local tabs = _G.BAIZE.tableaux
	-- find a tab with >1 cards, move the bottom one to foundation
	for _, tab in ipairs(tabs) do
		while #tab.cards > 1 do
			local c = table.remove(tab.cards, 1)
			_G.BAIZE.foundations[1]:push(c)
		end
	end

	repeat
		local moved = false
		for i = 1, #tabs - 1 do
			if #tabs[i].cards == 0 and #tabs[i+1].cards > 0 then
				local c = tabs[i+1]:pop()
				tabs[i]:push(c)
				moved = true
				break
			end
		end
	until not moved
--[[
	local dst = 1
	-- find a tab with cards where next tab has no cards
	while #tabs[dst].cards ~= 0 do
		dst = dst + 1
		if dst > #tabs then
			break
		end
	end
]]
end

function Accordian:moveTailError(tail)
	return nil
end

function Accordian:tailAppendError(dst, tail)
	if dst.category == 'Tableau' then
		if #dst.cards == 0 then
			return 'Cannot move cards to an empty pile'
		else
			return CC.Accordian({dst:peek(), tail[1]})
		end
	end
	return nil
end

-- function Accordian:unsortedPairs(pile)
-- 	return #pile.cards
-- end

function Accordian:percentComplete()
	local empty = 0
	for _, p in ipairs(_G.BAIZE.tableaux) do
		if #p.cards == 0 then
			empty = empty + 1
		end
	end
	return 100 - Util.mapValue(52 - empty, 0, 52, 1, 100)
end

function Accordian:complete()
	local occupied = 0
	for _, p in ipairs(_G.BAIZE.tableaux) do
		if #p.cards ~= 0 then
			occupied = occupied + 1
		end
	end
	return occupied == 1
end

-- function Accordian:pileTapped(pile)
-- 	-- no recycles
-- end

function Accordian:tailTapped(tail)
	-- do nothing
end

return Accordian
