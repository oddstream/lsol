-- main.lua

local log = require 'log'

local Card = require 'card'
local Baize = require 'baize'
local Settings = require 'settings'

_G.PATIENCE_VERSION = '1'

_G.PATIENCE_VARIANTS = {
	Debug = {file='debug.lua', params={}},
	Freecell = {file='freecell.lua', params={}},
	Klondike = {file='klondike.lua', params={}},
	['Klondike (Turn Three)']  = {file='klondike.lua', params={turn=3}},
	['Simple Simon'] = {file='simplesimon.lua', params={}},
}

_G.VARIANT_TYPES = {
	-- All will automatically be added
	Freecell = {'Eight Off','Freecell'},
	Klondike = {'Klondike'},
	Places = {'Australian', 'Yukon'},
	Puzzlers = {'Freecell', 'Penguin', 'Simple Simon'},
	Spiders = {'Spider One Suit', 'Spider Two Suits', 'Spider'},
}

_G.PATIENCE_COLORS = {
	Black = {0,0,0},
	White = {1,1,1},
	DarkGreen = {0,100,0},
	Ivory = {255,255,240},
	Crimson = {220,20,60},
	DarkBlue = {0,0,139},
	Silver = {192,192,192},
	Indigo = {75,0,130},
	Gold = {255,215,0},
	CornflowerBlue = {100,149,237},
	LightSkyBlue = {135, 206, 250},
}

function love.load(args)
	-- if args then
	-- 	print('args')
	-- 	for k, v in pairs(args) do
	-- 		print(k, v)
	-- 	end
	-- end

	math.randomseed(os.time())

	_G.PATIENCE_SETTINGS = Settings.new()

	love.graphics.setBackgroundColor(_G.PATIENCE_SETTINGS:colorBytes('baizeColor'))
	love.graphics.setDefaultFilter = 'nearest'

	_G.BAIZE = Baize.new()
	_G.BAIZE.script = _G.BAIZE:loadScript()
	if _G.BAIZE.script then
		_G.BAIZE:resetPiles()
		_G.BAIZE.script:buildPiles()
		log.info(#_G.BAIZE.piles, 'piles built')
		_G.BAIZE:layout()
		log.info('card width, height', _G.BAIZE.cardWidth, _G.BAIZE.cardHeight)
		_G.BAIZE:resetState()
		_G.BAIZE.script:startGame()
		_G.BAIZE:undoPush()
		_G.BAIZE.ui:setTitle(_G.BAIZE.variantName)
	end
--[[
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/patience
]]
end

function love.update(dt)
	_G.BAIZE:update(dt)
end

function love.draw()
	_G.BAIZE:draw()
end

function love.resize(w,h)
	log.trace('resize', w, h)
	_G.BAIZE:layout()
	for _, pile in ipairs(_G.BAIZE.piles) do
		pile:refan(Card.setBaizePos)
	end
	_G.BAIZE.ui:layout()
end

function love.keyreleased(key)
	log.info(key)
	if key == 'u' then
		_G.BAIZE:undo()
	elseif key == 'c' then
		_G.BAIZE:collect()
	elseif key == 'n' then
		_G.BAIZE:newDeal()
	elseif key == 'r' then
		_G.BAIZE:restartDeal()
	elseif key == 'b' then
		if love.keyboard.isDown('lshift') or love.keyboard.isDown('lctrl') then
			_G.BAIZE:gotoBookmark()
		else
			_G.BAIZE:setBookmark()
		end
	elseif key == 't' then
		_G.BAIZE.ui:toast(string.format('Toast %f', math.random()))
	elseif key == 's' then
		_G.PATIENCE_SETTINGS:save()
	end
end
