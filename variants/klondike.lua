-- klondike

local Foundation = require 'foundation'
local Stock = require 'stock'
local Tableau = require 'tableau'
local Waste = require 'waste'

local Util = require 'util'

local Klondike = {}
Klondike.__index = Klondike

function Klondike.new(params)
	local o = {}
	setmetatable(o, Klondike)
	return o
end

function Klondike.buildPiles()
	print('TRACE Klondike.buildPiles')

	Stock.new({x=1, y=1})
	Waste.new({x=2, y=1, fanType='FAN_RIGHT3'})
	for x = 5, 8 do
		local pile = Foundation.new({x=x, y=1})
		pile.label = 'A'
	end
	for x = 1, 8 do
		local pile = Tableau.new({x=x, y=2, fanType='FAN_DOWN', moveType='MOVE_ANY'})
		pile.label = 'K'
	end
	_G.BAIZE:setRecycles(32767)
end

function Klondike.startGame()
	print('TRACE Klondike.startGame')

	local src = _G.BAIZE.stock
	local dealDown = 0
	for _, dst in ipairs(_G.BAIZE.tableaux) do
		for _ = 1, dealDown do
			local card = Util.MoveCard(src, dst)
			card.prone = true
		end
		dealDown = dealDown + 1
		Util.MoveCard(src, dst)
	end
end

function Klondike.afterMove()
	print('TRACE Klondike.afterMove')
end

function Klondike.tailTapped(tail)
	local card = tail[1]
	local pile = card.parent
	if pile == _G.BAIZE.stock and #tail == 1 then
		Util.MoveCard(pile, _G.BAIZE.waste)
	else
		print('TRACE tap on card from pile', pile.category)
		pile:tailTapped(tail)
	end
end

return Klondike
