-- main.lua

local json = require 'json'
local log = require 'log'

local Card = require 'card'
local Baize = require 'baize'
local Util = require 'util'

_G.PATIENCE_VERSION = '1'

_G.PATIENCE_DEFAULT_SETTINGS = {
	lastVersion = 0,
	variantName = 'Klondike',
	highlightMovable = true,
	cardTransitionStep = 0.02,
	cardRatio = 1.357,
	cardDesign = 'Simple',
	powerMoves = true,
	muteSound = false,
	mirrorBaize = false,
	baizeColor = 'DarkGreen',
	cardBackColor = 'CornflowerBlue',
	cardFaceColor = 'Ivory',
	cardFaceHighlightColor = 'Gold',
	clubColor = 'DarkBlue',
	diamondColor = 'DarkGreen',
	heartColor = 'Crimson',
	spadeColor = 'Black',
	fourColorCards = true,
}

_G.PATIENCE_VARIANTS = {
	Australian = {file='australian.lua'},
	['Debug K'] = {file='debug.lua', params={spiderLike=false}},
	['Debug S'] = {file='debug.lua', params={spiderLike=true}},
	Freecell = {file='freecell.lua', params={}},
	Klondike = {file='klondike.lua', params={}},
	['Klondike (Turn Three)']  = {file='klondike.lua', params={turn=3}},
	['Simple Simon'] = {file='simplesimon.lua', params={}},
	Spider = {file='spider.lua', params={packs=2, suitFilter={'♣','♦','♥','♠'}}},
	['Spider One Suit'] = {file='spider.lua', params={packs=8, suitFilter={'♠'}}},
	['Spider Two Suits'] = {file='spider.lua', params={packs=4, suitFilter={'♥', '♠'}}},
}

_G.VARIANT_TYPES = {
	-- All will automatically be added
	['Forty Thieves'] = {'Forty Thieves', 'Limited'},
	Freecell = {'Eight Off', 'Freecell'},
	Klondike = {'Klondike', 'Klondike (Turn Three)'},
	Places = {'Australian', 'Yukon'},
	Puzzlers = {'Freecell', 'Penguin', 'Simple Simon'},
	Spiders = {'Spider One Suit', 'Spider Two Suits', 'Spider'},
}

do
	local lst = {}
	for k,_ in pairs(_G._G.PATIENCE_VARIANTS) do
		table.insert(lst, k)
	end
	-- table.sort(lst)
	_G.VARIANT_TYPES['All'] = lst
	-- table.sort(_G.VARIANT_TYPES)
	-- for k,_ in pairs(_G.VARIANT_TYPES) do
	-- 	print(k)
	-- 	for k2,v2 in pairs(v) do
	-- 		print(k2, v2)
	-- 	end
	-- end
end

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

_G.ORD2STRING = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

local savedFname = 'savedstate.json'

local function loadJSON()
	local contents, size = love.filesystem.read(savedFname)
	if contents then
		local decoded = json.decode(contents)
		if not decoded then
			log.error(savedFname, 'not decoded')
		else
			if decoded.settings and decoded.undoStack then
				log.info('loaded saved from', savedFname)
				return decoded
			end
		end
	else
		if type(size) == 'string' then
			log.error(size)
		end
	end
	return nil
end

local function saveJSON()
	local savable = {settings=_G.BAIZE.settings, undoStack=_G.BAIZE.undoStack}
	local data = json.encode(savable)
	local success, message = love.filesystem.write(savedFname, data)
	if success then
		log.info('game written to', savedFname)
	else
		log.error(message)
	end
end

function love.load(args)
	-- if args then
	-- 	print('args')
	-- 	for k, v in pairs(args) do
	-- 		print(k, v)
	-- 	end
	-- end

	math.randomseed(os.time())

	love.graphics.setLineStyle('smooth')

	local imageData = love.image.newImageData('assets/appicon.png')
	if not imageData then
		log.error('could load assets/appicon.png')
	else
		local success = love.window.setIcon(imageData)
		if not success then
			log.error('could set icon assets/appicon.png')
		end
	end

	local saved = loadJSON()
	if not saved then
		saved = {settings=_G.PATIENCE_DEFAULT_SETTINGS}
	end

	_G.BAIZE = Baize.new()
	_G.BAIZE.settings = saved.settings
	_G.BAIZE.undoStack = saved.undoStack
	if _G.BAIZE.undoStack then
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.BAIZE.settings.variantName)
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			_G.BAIZE:layout()
			-- don't reset
			-- don't startGame
			_G.BAIZE:undo()	-- pop extra state written when saved
		else
			os.exit()
		end
	else
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.BAIZE.settings.variantName)
		if not _G.BAIZE.script then
			_G.BAIZE.script = _G.BAIZE:loadScript('Klondike')
		end
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			_G.BAIZE:layout()
			_G.BAIZE:resetState()
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
	end
end

function love.quit()
	-- no args
	_G.BAIZE:undoPush()	-- push extra state, removed when reloaded
	saveJSON()
end
