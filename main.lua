-- main.lua

local Card = require 'card'
local Baize = require 'baize'

function love.load(args)
	-- if args then
	-- 	print('args')
	-- 	for k, v in pairs(args) do
	-- 		print(k, v)
	-- 	end
	-- end

	love.graphics.setBackgroundColor(0, 0.3, 0)

	_G.BAIZE = Baize.new()
	_G.BAIZE.script = _G.BAIZE:loadScript()
	if _G.BAIZE.script then
		_G.BAIZE:resetPiles()
		_G.BAIZE.script.buildPiles()
		print(#_G.BAIZE.piles, 'piles built')
		_G.BAIZE:layout()
		print('card width, height', _G.BAIZE.cardWidth, _G.BAIZE.cardHeight)
		_G.BAIZE.script.startGame()
	end
--[[
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/solvi
]]
end

function love.update(dt)
	_G.BAIZE:update(dt)
end

function love.draw()
	_G.BAIZE:draw()
end

function love.resize()
	print('resize')
	_G.BAIZE:layout()
	for _, pile in ipairs(_G.BAIZE.piles) do
		pile:refan(Card.setBaizePos)
	end
end
