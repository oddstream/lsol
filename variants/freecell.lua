-- freecell

local Cell = require 'cell'
local Foundation = require 'foundation'
local Stock = require 'stock'
local Tableau = require 'tableau'

local Freecell = {}
Freecell.__index = Freecell

function Freecell.new(params)
	local o = {}
	setmetatable(o, Freecell)
	return o
end

function Freecell:buildPiles()
	print('TRACE building freecell piles')

	Stock.new({x=1, y=1})
	for x = 1, 4 do
		Cell.new({x=x, y=2})
	end
	for x = 5, 8 do
		Foundation.new({x=x, y=2})
	end
	for x = 1, 8 do
		Tableau.new({x=x, y=3})
	end
end

function Freecell:startGame()
	print('TRACE starting a game of freecell')
end

function Freecell:afterMove()
end

return Freecell
