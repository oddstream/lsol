-- main.lua

local log = require 'log'

local Card = require 'card'
local Baize = require 'baize'
local Stats = require 'stats'
local Util = require 'util'

_G.LSOL_VERSION = '1'

_G.LSOL_DEFAULT_SETTINGS = {
	lastVersion = 0,
	variantName = 'Klondike',
	highlightMovable = true,
	cardTransitionStep = 0.02,
	cardRatio = 1.444, --1.357,
	simpleCards = true,
	powerMoves = true,
	muteSounds = false,
	mirrorBaize = false,
	baizeColor = 'DarkGreen',
	cardBackColor = 'CornflowerBlue',
	cardFaceColor = 'Ivory',
	cardFaceHighlightColor = 'Gold',
	clubColor = 'Indigo',
	diamondColor = 'OrangeRed',
	heartColor = 'Crimson',
	spadeColor = 'Black',
	fourColorCards = true,
}

_G.LSOL_VARIANTS = {
	Australian = {file='australian.lua', params={}},
	Duchess = {file='duchess.lua', params={}},
	['Debug Klon'] = {file='debug.lua', params={spiderLike=false}},
	['Debug Spid'] = {file='debug.lua', params={spiderLike=true}},
	['Eight Off'] = {file='eightoff.lua'},
	['Eight Off Relaxed'] = {file='eightoff.lua', params={relaxed=true}},
	Freecell = {file='freecell.lua', params={}},
	Gate = {file='gate.lua', params={}},
	Klondike = {file='klondike.lua', params={}},
	['Klondike (Turn Three)']  = {file='klondike.lua', params={turn=3}},
	['Forty Thieves'] = {file='forty.lua', params={tabs=10, cardsPerTab=4}},
	Limited = {file='forty.lua', params={tabs=12, cardsPerTab=3}},
	Lucas = {file='forty.lua', params={tabs=13, cardsPerTab=3, dealAces=true}},
	Penguin = {file='penguin.lua'},
	['Simple Simon'] = {file='simplesimon.lua', params={}},
	Spider = {file='spider.lua', params={packs=2, suitFilter={'♣','♦','♥','♠'}}},
	['Spider One Suit'] = {file='spider.lua', params={packs=8, suitFilter={'♠'}}},
	['Spider Two Suits'] = {file='spider.lua', params={packs=4, suitFilter={'♥', '♠'}}},
	Yukon = {file='yukon.lua', params={}},
	['Yukon Relaxed'] = {file='yukon.lua', params={relaxed=true}},
	['Yukon Cells'] = {file='yukon.lua', params={cells=true}},
}

_G.VARIANT_TYPES = {
	-- '> All' will automatically be added
	['> Canfield'] = {'Duchess', 'Gate'},
	['> Forty Thieves'] = {'Forty Thieves', 'Limited', 'Lucas'},
	['> Freecell'] = {'Eight Off', 'Eight Off Relaxed', 'Freecell'},
	['> Klondike'] = {'Klondike', 'Klondike (Turn Three)'},
	['> Places'] = {'Australian', 'Yukon', 'Yukon Relaxed'},
	['> Puzzlers'] = {'Freecell', 'Penguin', 'Simple Simon'},
	['> Spiders'] = {'Spider One Suit', 'Spider Two Suits', 'Spider'},
}

do
	local lst = {}
	for k,_ in pairs(_G._G.LSOL_VARIANTS) do
		table.insert(lst, k)
	end
	-- table.sort(lst)
	_G.VARIANT_TYPES['> All'] = lst
	-- table.sort(_G.VARIANT_TYPES)
	-- for k,_ in pairs(_G.VARIANT_TYPES) do
	-- 	print(k)
	-- 	for k2,v2 in pairs(v) do
	-- 		print(k2, v2)
	-- 	end
	-- end
end

_G.LSOL_COLORS = {
	Black = {0,0,0},
	White = {1,1,1},
	Red = {255,0,0},
	Teal = {0,128,128},
	OrangeRed = {255,69,0},
	DarkGreen = {0,100,0},
	Ivory = {255,255,240},
	Crimson = {220,20,60},
	Salmon = {250,128,114},
	DarkBlue = {0,0,139},
	Silver = {192,192,192},
	Indigo = {75,0,130},
	Gold = {255,215,0},
	CornflowerBlue = {100,149,237},
	LightSkyBlue = {135, 206, 250},
	DarkSlateGray = {47,79,79},

	UiBackground = {0x32,0x32,0x32,0xff},
	UiForeground = {1,1,1,1},
	UiHover = {255,215,0},	-- Gold
}

_G.LSOL_SOUNDS = {
	deal = love.audio.newSource('assets/sounds/cardFan1.wav', 'static'),
	load = love.audio.newSource('assets/sounds/cardFan2.wav', 'static'),
	move1 = love.audio.newSource('assets/sounds/cardPlace3.wav', 'static'),
	move2 = love.audio.newSource('assets/sounds/cardPlace4.wav', 'static'),
	move3 = love.audio.newSource('assets/sounds/cardPlace1.wav', 'static'),
	move4 = love.audio.newSource('assets/sounds/cardPlace2.wav', 'static'),
	undo = love.audio.newSource('assets/sounds/cardOpenPackage2.wav', 'static'),
	menuopen = love.audio.newSource('assets/sounds/cardSlide1.wav', 'static'),
	menuclose = love.audio.newSource('assets/sounds/cardSlide2.wav', 'static'),
	uitap =  love.audio.newSource('assets/sounds/cardSlide8.wav', 'static'),
	complete = love.audio.newSource('assets/sounds/complete.wav', 'static'),
	blip = love.audio.newSource('assets/sounds/249895__alienxxx__blip2.wav', 'static'),
}

_G.ORD2STRING = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

function love.load(args)
	-- if args then
	-- 	print('args')
	-- 	for k, v in pairs(args) do
	-- 		print(k, v)
	-- 	end
	-- end

	math.randomseed(os.time())

	-- love.graphics.setLineStyle('smooth')

	_G.BAIZE = Baize.new()
	_G.BAIZE:loadSettings()
	_G.BAIZE.stats = Stats.new()
	_G.BAIZE:loadUndoStack()
	if _G.BAIZE.undoStack then
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.BAIZE.settings.variantName)
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			_G.BAIZE:layout()
			-- don't reset
			-- don't startGame
			_G.BAIZE.ui:toast('Resuming a saved game of ' .. _G.BAIZE.settings.variantName, 'load')
			_G.BAIZE:undo()	-- pop extra state written when saved
		else
			os.exit()
		end
	else
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.BAIZE.settings.variantName)
		if not _G.BAIZE.script then
			_G.BAIZE.settings.variantName = 'Klondike'
			_G.BAIZE.script = _G.BAIZE:loadScript(_G.BAIZE.settings.variantName)
		end
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			_G.BAIZE:layout()
			_G.BAIZE:resetState()
			_G.BAIZE.ui:toast('Starting a new game of ' .. _G.BAIZE.settings.variantName, 'deal')
			_G.BAIZE.script:startGame()
			_G.BAIZE:undoPush()
		else
			os.exit()
		end
	end
	love.graphics.setBackgroundColor(Util.colorBytes('baizeColor'))
	_G.BAIZE.ui:updateWidget('title', _G.BAIZE.settings.variantName)
	--[[
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/patience
	print(love.filesystem.getSaveDirectory())	-- /home/gilbert/.local/share/love/patience
]]
end

function love.update(dt)
	_G.BAIZE:update(dt)
end

function love.draw()
	_G.BAIZE:draw()
end

function love.resize(w,h)
	-- log.trace('resize', w, h)
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
	elseif key == 'd' then
		_G.BAIZE:resetSettings()
		_G.BAIZE.ui:toast('Settings reset to defaults')
	elseif key == 't' then
		_G.BAIZE.ui:toast(string.format('Toast %f', math.random()))
	elseif key == 'up' then
		_G.BAIZE:startSpinning()
	elseif key == 'down' then
		_G.BAIZE:stopSpinning()
	elseif key == 'f' then
		_G.BAIZE.ui:showFAB{icon='star', baizeCmd='newDeal'}
	elseif key == '2' then
		_G.BAIZE:twoColorCards()
	elseif key == '4' then
		_G.BAIZE:fourColorCards()
	elseif key == 'x' then
		for _, p in ipairs(_G.BAIZE.piles) do
			if p.category == 'Tableau' or p.category == 'Reserve' then
				p:calcStackFactors()
			end
		end
	end
	_G.BAIZE.lastInput = love.timer.getTime()
end

function love.wheelmoved(x, y)
	local drw = _G.BAIZE.ui:findOpenDrawer()
	if drw then
		drw:startDrag()
		drw:dragBy(0, y*24)
		drw:stopDrag()
	else
		_G.BAIZE:startDrag()
		_G.BAIZE:dragBy(x*24, y*24)
		_G.BAIZE:stopDrag()
	end
	_G.BAIZE.lastInput = love.timer.getTime()
end

function love.quit()
	-- no args
	_G.BAIZE.stats:save()
	_G.BAIZE:saveSettings()
	_G.BAIZE:saveUndoStack()
end
