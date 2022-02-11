-- freecell

local log = require 'log'

local Cell = require 'cell'
local Foundation = require 'foundation'
local Stock = require 'stock'
local Tableau = require 'tableau'

local Util = require 'util'

local Freecell = {}
Freecell.__index = Freecell

function Freecell.new(params)
	local o = {}
	setmetatable(o, Freecell)
	return o
end

function Freecell.buildPiles()
	Stock.new({x=1, y=1})
	for x = 1, 4 do
		Cell.new({x=x, y=2})
	end
	for x = 5, 8 do
		Foundation.new({x=x, y=2})
	end
	for x = 1, 8 do
		Tableau.new({x=x, y=3, fanType='FAN_DOWN', moveType='MOVE_ONE_PLUS'})
	end
end

function Freecell.startGame()
	local src, dst
	src = _G.BAIZE.stock
	for i = 1, 4 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 7 do
			Util.moveCard(src, dst)
		end
	end
	for i = 5, 8 do
		dst = _G.BAIZE.tableaux[i]
		for j = 1, 6 do
			Util.moveCard(src, dst)
		end
	end
	if #src.cards > 0 then
		log.error('still', #src.cards, 'cards in Stock')
	end
end

function Freecell.afterMove()
end

return Freecell
