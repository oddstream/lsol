-- main.lua

local Baize = require 'baize'

-- Load some default values for our rectangle.
function love.load()
	_G.BAIZE = Baize.new()
	_G.BAIZE.script = _G.BAIZE:loadScript()
	if _G.BAIZE.script then
		_G.BAIZE.script.BuildPiles()
	end
	x, y, w, h = 20, 20, 60, 20
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/solvi
end

-- Increase the size of the rectangle every frame.
function love.update(dt)
	w = w + dt
	h = h + dt
end

-- Draw a coloured rectangle.
function love.draw()
	love.graphics.setBackgroundColor(0, 0.3, 0)
	love.graphics.setColor(0, 0.4, 0.4)
	love.graphics.rectangle("fill", x, y, w, h)
end
