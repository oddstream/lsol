-- main.lua

local Baize = require 'baize'

function love.load()
	_G.BAIZE = Baize.new()
	_G.BAIZE.script = _G.BAIZE:loadScript()
	if _G.BAIZE.script then
		_G.BAIZE:resetPiles()
		_G.BAIZE.script.buildPiles()
		print(#_G.BAIZE.piles, 'piles built')
		_G.BAIZE:layoutPiles()
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
	for _, pile in ipairs(_G.BAIZE.piles) do
		pile:update(dt)
	end
end

function love.draw()
	love.graphics.setBackgroundColor(0, 0.3, 0)
	for _, pile in ipairs(_G.BAIZE.piles) do
		pile:draw()
	end
end
