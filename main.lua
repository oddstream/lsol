-- main.lua

local json = require 'json'
local log = require 'log'

local Card = require 'card'
local Baize = require 'baize'
local Stats = require 'stats'
local UI = require 'ui'
local Util = require 'util'

_G.LSOL_VERSION = '14'
_G.LSOL_VERSION_DATE = '2022-05-26'

if not _G.table.contains then
  function _G.table.contains(tab, val)
    for index, value in ipairs(tab) do
      if value == val then
        return true, index
      end
    end
    return false, 0
  end
end

_G.LSOL_DEFAULT_SETTINGS = {
	debug = false,
	lastVersion = 0,
	variantName = 'Klondike',
	highlightMovable = true,
	cardTransitionStep = 0.02,
	simpleCards = false,
	powerMoves = true,
	muteSounds = false,
	mirrorBaize = false,
	baizeColor = 'DarkGreen',
	cardBackColor = 'CornflowerBlue',
	cardFaceColor = 'Ivory',
	clubColor = 'DarkGreen',
	diamondColor = 'MediumBlue',
	heartColor = 'Crimson',
	spadeColor = 'Black',
	oneColorCards = false,
	twoColorCards = true,
	fourColorCards = false,
	autoColorCards = false,
}

_G.LSOL_VARIANTS = {
	Accordian = {file='accordian.lua', cc=4},
	['Agnes Bernauer'] = {file='agnes.lua', cc=2, bernauer=true},
	['Agnes Sorel'] = {file='agnes.lua', cc=4, sorel=true},
	Algerian = {file='algerian.lua', easy=true, cc=4},
	Alhambra = {file='alhambra.lua', cc=2},
	['American Toad'] = {file='amtoad.lua', cc=4},
	Athena = {file='klondike.lua', athena=true, cc=2},
	Assembly = {file='assembly.lua', cc=1},
	Australian = {file='australian.lua', cc=4},
	['Baker\'s Dozen'] = {file='bakers.lua', cc=1},
	['Baker\'s Dozen (Wide)'] = {file='bakers.lua', wide=true, cc=1, statsName='Baker\'s Dozen'},
	['Beleaguered Castle'] = {file='castle.lua', cc=1},
	['Busy Aces'] = {file='forty.lua', cc=4, tabs=12, cardsPerTab=1, dealAces=false},
	['Flat Castle'] = {file='castle.lua', cc=1, flat=true, statsName='Beleaguered Castle'},
	Bisley = {file='bisley.lua', cc=4},
	['Black Hole'] = {file='blackhole.lua', cc=1},
	Blockade = {file='blockade.lua', cc=4},
	-- ['Bisley Debug'] = {file='bisley.lua', cc=4, debug=true},
	Canfield = {file='canfield.lua', cc=2},
	Cruel = {file='cruel.lua', cc=4},
	['Rainbow Canfield'] = {file='canfield.lua', cc=1, rainbow=true},
	['Storehouse Canfield'] = {file='canfield.lua', cc=4, storehouse=true},
	Duchess = {file='duchess.lua', cc=2},
	-- ['Debug Klon'] = {file='debug.lua', cc=4, spiderLike=false},
	-- ['Debug Spid'] = {file='debug.lua', cc=4, spiderLike=true},
	['Eight Off'] = {file='eightoff.lua', cc=4},
	['Eight Off Relaxed'] = {file='eightoff.lua', cc=4, relaxed=true},
	Freecell = {file='freecell.lua', cc=2, bakers=false, relaxed=true},
	['Sea Haven Towers'] = {file='seahaven.lua', cc=4},
	['Baker\'s Game'] = {file='freecell.lua', bakers=true, cc=4, relaxed=false},
	['Baker\'s Game Relaxed'] = {file='freecell.lua', bakers=true, cc=4, relaxed=true},
	Gate = {file='gate.lua', cc=2},
	Klondike = {file='klondike.lua', cc=2},
	Thoughtful = {file='klondike.lua', cc=2, thoughtful=true},
	Gargantua = {file='klondike.lua', cc=2, gargantua=true},
	['Klondike (Turn Three)']  = {file='klondike.lua', cc=2, turn=3},
	['Forty Thieves'] = {file='forty.lua', cc=4, tabs=10, cardsPerTab=4},
	['Forty and Eight'] = {file='forty.lua', cc=4, tabs=10, cardsPerTab=5, recycles=1},
	Josephine = {file='forty.lua', cc=4, tabs=10, cardsPerTab=4, josephine=true},
	Limited = {file='forty.lua', cc=4, tabs=12, cardsPerTab=3},
	['Little Spider'] = {file='littlespider.lua', cc=2},
	Lucas = {file='forty.lua', cc=4, tabs=13, cardsPerTab=3, dealAces=true},
	Martha = {file='martha.lua', cc=2},
	['Miss Milligan'] = {file='miss milligan.lua', cc=2},
	['Mount Olympus'] = {file='mount olympus.lua', cc=4},
	Giant = {file='miss milligan.lua', giant=true, cc=2},
	Penguin = {file='penguin.lua', cc=4},
	['Red and Black'] = {file='redandblack.lua', cc=2},
	['Royal Cotillion'] = {file='royal cotillion.lua', cc=4},
	Pyramid = {file='pyramid.lua', relaxed=false, cc=2},
	['Pyramid Relaxed'] = {file='pyramid.lua', relaxed=true, cc=2},
	Rosamund = {file='rosamund.lua', cc=2},
	Scorpion = {file='scorpion.lua', cc=4},
	Wasp = {file='scorpion.lua', cc=4, relaxed=true},
	['Simple Simon'] = {file='simplesimon.lua', cc=4},
	Spider = {file='spider.lua', packs=2, cc=4, suitFilter={'♣','♦','♥','♠'}},
	['Spider One Suit'] = {file='spider.lua', cc=1, packs=8, suitFilter={'♠'}},
	['Spider Two Suits'] = {file='spider.lua', cc=2, packs=4, suitFilter={'♥', '♠'}},
	Spiderette = {file='spider.lua', spiderette=true, cc=4, packs=1},
	['Spiderette One Suit'] = {file='spider.lua', spiderette=true, cc=1, packs=4, suitFilter={'♠'}},
	['Spiderette Two Suits'] = {file='spider.lua', spiderette=true, cc=2, packs=2, suitFilter={'♥', '♠'}},
	['Good Thirteen'] = {file='thirteens.lua', packs=1, cc=1},
	['Classic Westcliff'] = {file='westcliff.lua', cc=2, classic=true},
	['American Westcliff'] = {file='westcliff.lua', cc=2, american=true},
	Easthaven = {file='westcliff.lua', cc=2, easthaven=true},
	['Tri Peaks'] = {file='tripeaks.lua', cc=2},
	['Tri Peaks Open'] = {file='tripeaks.lua', open=true, cc=2},
	Yukon = {file='yukon.lua', cc=2},
	['Yukon Relaxed'] = {file='yukon.lua', cc=2, relaxed=true},
	['Yukon Cells'] = {file='yukon.lua', cc=2, cells=true},
	['Russian'] = {file='yukon.lua', cc=4, russian=true},
	['Crimean'] = {file='crimean.lua', cc=4, crimean=true},
	['Ukrainian'] = {file='crimean.lua', cc=4, ukrainian=true},
}

_G.VARIANT_TYPES = {
	-- '> All' and maybe '> Favorites' will automatically be added
	['> Animals'] = {'Scorpion','Wasp','Spider One Suit','Spider Two Suits','Spider','Little Spider','Penguin'},
	['> Canfields'] = {'American Toad','Canfield','Duchess','Gate','Rainbow Canfield','Storehouse Canfield'},
	['> Easier'] = {'Accordian','American Toad','American Westcliff','Blockade','Classic Westcliff','Lucas','Martha','Spider One Suit','Red and Black','Tri Peaks','Tri Peaks Open'},
	['> Forty Thieves'] = {'Forty Thieves','Josephine','Limited','Lucas','Forty and Eight','Busy Aces','Red and Black'},
	['> Freecells'] = {'Eight Off', 'Eight Off Relaxed', 'Freecell', 'Baker\'s Game', 'Baker\'s Game Relaxed','Sea Haven Towers'},
	['> Klondikes'] = {'Athena', 'Gargantua', 'Klondike', 'Klondike (Turn Three)', 'Easthaven', 'Classic Westcliff', 'American Westcliff','Agnes Bernauer','Thoughtful'},
	['> People'] = {'Agnes Bernauer','Agnes Sorel','Josephine','Martha','Miss Milligan','Rosamund'},
	['> Places'] = {'Algerian','Alhambra','Australian','Mount Olympus','Yukon','Yukon Relaxed','Russian','Crimean','Ukrainian'},
	['> Popular'] = {'Klondike', 'Forty Thieves', 'Freecell', 'Spider', 'Yukon', 'Tri Peaks'},
	['> Puzzlers'] = {'Eight Off', 'Freecell', 'Penguin', 'Simple Simon','Baker\'s Dozen','Baker\'s Dozen (Wide)'},
	['> Spiders'] = {'Spider One Suit', 'Spider Two Suits', 'Spider','Little Spider','Spiderette','Spiderette One Suit','Spiderette Two Suits'},
}

local function createAllVariants()

	local lst = {}
	for k,_ in pairs(_G.LSOL_VARIANTS) do
		table.insert(lst, k)
	end
	-- sorting happens after widgets are added to types/variants drawers
	_G.VARIANT_TYPES['> All'] = lst
	-- for k,_ in pairs(_G.VARIANT_TYPES) do
	-- 	print(k)
	-- 	for k2,v2 in pairs(v) do
	-- 		print(k2, v2)
	-- 	end
	-- end
end

local function createFavoriteVariants(stats)

	-- can only sort a table of keys with numeric indexes, not an associative array
	local tab = {}
	for k, _ in pairs(stats) do
		if stats[k].won and stats[k].lost then
			table.insert(tab, {vname=k, played=stats[k].won + stats[k].lost})
		end
	end

	if #tab > 2 then
		-- log.info('presort', #tab)
		-- for i, v in ipairs(tab) do
		-- 	log.info(i, v.vname, v.played)
		-- end

		-- compare function receives two arguments
		-- and must return true if the first argument should come first in the sorted array
		table.sort(tab, function(a,b) return a.played > b.played end)

		-- log.info('postsort', #tab)
		-- for i, v in ipairs(tab) do
		-- 	log.info(i, v.vname, v.played)
		-- end

		local lst = {}
		local num = math.min(7, #tab)
		for i = 1, num do
			table.insert(lst, tab[i].vname)
		end
		_G.VARIANT_TYPES['> Favorites'] = lst
		-- beware - this short list will be alpha sorted before it's displayed
	end
end

_G.LSOL_COLORS = {
	-- Basic colors
	White = {1,1,1},
	Silver = {192,192,192},
	Gray = {128,128,128},
	Black = {0,0,0},
	-- Red colors
	Maroon = {128,0,0},
	Yellow = {255,255,0},
	Olive = {128,128,0},
	Lime = {0,255,0},
	Green = {0,128,0},
	Aqua = {0,255,255},
	Teal = {0,128,128},
	Blue = {0,0,255},
	Navy = {0,0,128},
	Fushsia = {255,0,255},
	Purple = {128,0,128},

	-- Pink colors
	DeepPink = {255,20,147},
	HotPink = {255,105,180},
	LightPink = {255,182,203},
	Pink = {255,192,203},

	-- Red colors
	DarkRed = {139,0,0},
	Red = {255,0,0},
	Firebrick = {178,34,34},
	Crimson = {220,20,60},
	IndianRed = {205,92,92},
	LightCoral = {240,128,128},
	Salmon = {250,128,114},
	DarkSalmon = {233,150,122},
	LightSalmon = {255,160,122},

	-- Orange colors
	OrangeRed = {255,69,0},

	-- Yellow colors
	Gold = {255,215,0},

	-- Brown colors

	-- Green colors
	DarkGreen = {0,100,0},

	-- Cyan colors

	-- Blue colors
	DarkBlue = {0,0,139},
	MediumBlue = {0,0,205},
	CornflowerBlue = {100,149,237},
	LightSkyBlue = {135, 206, 250},

	-- Purple, violet, and magenta colors
	Indigo = {75,0,130},

	-- White colors
	Ivory = {255,255,240},

	-- Gray and black colors
	-- Black
	DarkSlateGray = {47,79,79},
	DimGray = {105,105,105},
	-- Gray
	-- Silver

	UiBackground = {0x32,0x32,0x32},
	UiForeground = {0xff,0xff,0xff},
	UiGrayedOut = {0x80,0x80,0x80},
}

_G.ORD_FONT = 'assets/fonts/Acme-Regular.ttf'
_G.SUIT_FONT = 'assets/fonts/DejaVuSans.ttf'
_G.UI_MEDIUM_FONT = 'assets/fonts/Roboto-Medium.ttf'
_G.UI_REGULAR_FONT = 'assets/fonts/Roboto-Regular.ttf'

_G.LSOL_SOUNDS = {
	deal = love.audio.newSource('assets/sounds/cardFan1.wav', 'static'),
	load = love.audio.newSource('assets/sounds/cardFan2.wav', 'static'),
	move1 = love.audio.newSource('assets/sounds/cardPlace3.wav', 'static'),
	move2 = love.audio.newSource('assets/sounds/cardPlace4.wav', 'static'),
	move3 = love.audio.newSource('assets/sounds/cardPlace1.wav', 'static'),
	move4 = love.audio.newSource('assets/sounds/cardPlace2.wav', 'static'),
	undo = love.audio.newSource('assets/sounds/cardOpenPackage2.wav', 'static'),
	menushow = love.audio.newSource('assets/sounds/cardSlide1.wav', 'static'),
	menuhide = love.audio.newSource('assets/sounds/cardSlide2.wav', 'static'),
	uitap =  love.audio.newSource('assets/sounds/cardSlide8.wav', 'static'),
	complete = love.audio.newSource('assets/sounds/complete.wav', 'static'),
	blip = love.audio.newSource('assets/sounds/249895__alienxxx__blip2.wav', 'static'),
	fail = love.audio.newSource('assets/sounds/237422__plasterbrain__hover-1.ogg', 'static'),
}

_G.ORD2STRING = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

local settingsFname = 'settings.json'

local function loadSettings()
	local settings
	local info = love.filesystem.getInfo(settingsFname)
	if type(info) == 'table' and type(info.type) == 'string' and info.type == 'file' then
		local contents, size = love.filesystem.read(settingsFname)
		if not contents then
			log.error(size)
		else
			-- log.info('loaded', size, 'bytes from', settingsFname)
			local ok
			ok, settings = pcall(json.decode, contents)
			if not ok then
				log.error('error decoding', settingsFname, settings)
				settings = nil
			end
		end
	else
		log.info('not loading', settingsFname)
	end
	return settings or _G.LSOL_DEFAULT_SETTINGS
end

function _G.saveSettings()
	_G.SETTINGS.lastVersion = _G.LSOL_VERSION
	if love.system.getOS() ~= 'Android' then
		local x, y, i = love.window.getPosition()
		local w, h = love.window.getMode()
		_G.SETTINGS.windowX = x
		_G.SETTINGS.windowY = y
		_G.SETTINGS.windowWidth = w
		_G.SETTINGS.windowHeight = h
		_G.SETTINGS.displayIndex = i
	end
	local success, message = love.filesystem.write(settingsFname, json.encode(_G.SETTINGS))
	if success then
		-- log.info('wrote to', settingsFname)
	else
		log.error(message)
	end
end

local function createWindowIcon()
	local size = 32	-- small size let the OS fuzz it up
	local heart = '♥'

	local canvas = love.graphics.newCanvas(size, size)
	love.graphics.setCanvas(canvas)	-- direct drawing operations to the canvas

	love.graphics.setColor(love.math.colorFromBytes(unpack(_G.LSOL_COLORS['HotPink'])))
	local fnt = love.graphics.newFont(_G.SUIT_FONT, size)
	love.graphics.setFont(fnt)
	local w = fnt:getWidth(heart)
	local h = fnt:getHeight()

	love.graphics.print(heart, size/2 - w/2, size/2 - h/2)

	love.graphics.setCanvas()	-- reset render target to the screen
	return canvas:newImageData()
end

function love.load(args)
--[[
Lua (and some engines based on it, like LÖVE) has output buffered by default,
so if you only print a small number of bytes,
you may see the results only after the script is completed.

If you want to see the print output immediately,
add io.stdout:setvbuf("no") to your script,
which will turn the buffering off.

There may be a small performance penalty as the output will be flushed after each print.
]]

	-- required for ZeroBrane
	--[[
	io.stdout:setvbuf('no')	-- 'no', 'full' or 'line'

	if args then
		for k, v in pairs(args) do
			print(k, v)
		end
		if arg[#arg] == "-debug" then require("mobdebug").start() end
	end
	]]

	math.randomseed(os.time())

	--[[
		Lenovo Tab M10 HD Gen 2		800 x 1280 pixels, 16:10 ratio (~149 ppi density)
		https://www.gsmarena.com/lenovo_tab_m10_hd_gen_2-10406.php

		Motorola Moto G4			1080 x 1920 pixels, 16:9 ratio (~401 ppi density)
		https://www.gsmarena.com/motorola_moto_g4-8103.php
	]]

	_G.UI_SCALE = 1
	local DPIScale = love.window.getDPIScale()
	if DPIScale > 1 then
		_G.UI_SCALE = 1 - (DPIScale/10)	-- so a DPIScale of 3 would scale the UI from 1.0 to 0.7
	end

	do
		local imageData = love.image.newImageData('assets/gradient_img.png')
		_G.BACKGROUND_X = imageData:getWidth()
		_G.BACKGROUND_Y = imageData:getHeight()
		_G.BACKGROUND = love.graphics.newImage(imageData)
	end

	-- https://love2d.org/forums/viewtopic.php?f=3&t=84348&p=215242&hilit=rounded+rectangle#p215242
	local limits = love.graphics.getSystemLimits( )
	-- log.info(limits.canvasmsaa)	-- 16
	-- log.info(limits.texturesize)	-- 16384
	-- log.info(limits.multicanvas)	-- 8

	_G.SETTINGS = loadSettings()

	if love.system.getOS() == 'Android' then
		-- force portrait mode
		-- do not use dpi scale (which would be 3 on Moto G4)
		love.window.setMode(1080, 1920, {resizable=true, msaa=limits.canvasmsaa, usedpiscale=true})
	else
		love.window.setIcon(createWindowIcon())

		local s = _G.SETTINGS
		if s.windowWidth and s.windowHeight then
			love.window.setMode(s.windowWidth, s.windowHeight, {resizable=true,  msaa=limits.canvasmsaa, minwidth=640, minheight=500})
		else
			love.window.setMode(1080/2, 1920/2, {resizable=true,  msaa=limits.canvasmsaa, minwidth=640, minheight=500})
		end
		if s.windowX and s.windowY and s.displayIndex then
			love.window.setPosition(s.windowX, s.windowY, s.displayIndex)
		end
	end

	_G.TITLEBARHEIGHT = 48 * _G.UI_SCALE
	_G.STATUSBARHEIGHT = 24 * _G.UI_SCALE
	_G.UIFONTSIZE = 24 * _G.UI_SCALE
	_G.UIFONTSIZE_SMALL = 14  * _G.UI_SCALE

	love.graphics.setLineStyle('smooth')	-- just in case default is 'rough', which is isn't

	_G.UI_SAFEX,
	_G.UI_SAFEY,
	_G.UI_SAFEW,
	_G.UI_SAFEH = love.window.getSafeArea()

	_G.BAIZE = Baize.new()

	-- love.handlers['permissionButton'] = function(text)
	-- 	log.trace('event handler', text)
	-- end

	_G.BAIZE.stats = Stats.new()
	createAllVariants()
	createFavoriteVariants(_G.BAIZE.stats)
	_G.BAIZE.ui = UI.new()

	love.graphics.setBackgroundColor(Util.getColorFromSetting('baizeColor'))
	_G.BAIZE.ui:updateWidget('title', _G.SETTINGS.variantName)

	_G.BAIZE:loadUndoStack()
	if _G.BAIZE.undoStack then
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			if _G.SETTINGS.mirrorBaize then
				_G.BAIZE:mirrorSlots()
			end
			_G.BAIZE:layout()
			-- don't reset
			-- don't startGame
			_G.BAIZE.ui:toast('Resuming a saved game of ' .. _G.SETTINGS.variantName, 'load')
			_G.BAIZE:undo()	-- pop extra state written when saved, will updateUI
		else
			os.exit()
		end
	else
		_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		if not _G.BAIZE.script then
			_G.SETTINGS.variantName = 'Klondike'	-- TODO save settings
			_G.BAIZE.script = _G.BAIZE:loadScript(_G.SETTINGS.variantName)
		end
		if _G.BAIZE.script then
			_G.BAIZE:resetPiles()
			_G.BAIZE.script:buildPiles()
			if _G.SETTINGS.mirrorBaize then
				_G.BAIZE:mirrorSlots()
			end
			_G.BAIZE:layout()
			_G.BAIZE:resetState()
			_G.BAIZE.ui:toast('Starting a new game of ' .. _G.SETTINGS.variantName, 'deal')
			_G.BAIZE.script:startGame()
			_G.BAIZE:undoPush()
			_G.BAIZE:updateUI()
		else
			os.exit()
		end
	end

	if _G.SETTINGS.lastVersion == 0 then
		_G.BAIZE.ui:toast(string.format('Welcome to %s', love.filesystem.getIdentity()))
	elseif _G.SETTINGS.lastVersion ~= _G.LSOL_VERSION then
		_G.BAIZE.ui:toast(string.format('%s version updated from %d to %d', love.filesystem.getIdentity(), _G.SETTINGS.lastVersion, _G.LSOL_VERSION))
	end

	-- _G.BAIZE.ui:toast(string.format('safe x=%d y=%d w=%d h=%d', love.window.getSafeArea()))
	--[[
	print(love.filesystem.getAppdataDirectory())	-- /home/gilbert/.local/share/
	print(love.filesystem.getSourceBaseDirectory())	-- /home/gilbert
	print(love.filesystem.getUserDirectory())	-- /home/gilbert/
	print(love.filesystem.getWorkingDirectory())	-- /home/gilbert/patience
	print(love.filesystem.getSaveDirectory())	-- /home/gilbert/.local/share/love/patience
]]
end

function love.update(dt_seconds)
	_G.BAIZE:update(dt_seconds)
end

function love.draw()
	_G.BAIZE:draw()
end

function love.resize(w,h)
	-- if _G.SETTINGS.debug then
		-- log.trace('resize', w, h)
	-- end
	_G.BAIZE:layout()
	for _, pile in ipairs(_G.BAIZE.piles) do
		pile:refan(Card.setBaizePos)
	end
	_G.BAIZE.ui:layout()
end

function love.keyreleased(key)
	-- log.info(key)
	if key == 'u' then
		_G.BAIZE:undo()
	elseif key == 'c' then
		_G.BAIZE:collect()
	elseif key == 'n' then
		_G.BAIZE:newDeal()
		-- _G.BAIZE.ui:showFAB{icon='star', baizeCmd='newDeal'}
	elseif key == 'r' then
		_G.BAIZE:restartDeal()
	elseif key == 'b' then
		if love.keyboard.isDown('lshift') or love.keyboard.isDown('lctrl') then
			_G.BAIZE:gotoBookmark()
		else
			_G.BAIZE:setBookmark()
		end
	elseif key == '1' then
		_G.SETTINGS.oneColorCards = true
		_G.SETTINGS.twoColorCards = false
		_G.SETTINGS.fourColorCards = false
		_G.SETTINGS.autoColorCards = false
		_G.BAIZE:createCardTextures()
	elseif key == '2' then
		_G.SETTINGS.oneColorCards = false
		_G.SETTINGS.twoColorCards = true
		_G.SETTINGS.fourColorCards = false
		_G.SETTINGS.autoColorCards = false
		_G.BAIZE:createCardTextures()
	elseif key == '4' then
		_G.SETTINGS.oneColorCards = false
		_G.SETTINGS.twoColorCards = false
		_G.SETTINGS.fourColorCards = true
		_G.SETTINGS.autoColorCards = false
		_G.BAIZE:createCardTextures()
	elseif key == 'd' and love.keyboard.isDown('lctrl') then
		_G.SETTINGS.debug = not _G.SETTINGS.debug
		for _, c in ipairs(_G.BAIZE.deck) do
			c.movable = false
		end
		_G.BAIZE:countMoves()	-- mark/unmark movable cards
	end

	if love.system.getOS() == 'Android' then
		if key == 'escape' then		-- Android return/back?
			love.event.quit(0)
		elseif key == 'home' then
			love.event.quit(0)
		elseif key == 'menu' then
			_G.BAIZE.ui:toggleMenuDrawer()
		elseif key == 'search' then
			_G.BAIZE.ui:showVariantTypesDrawer()
		end
	else
		if key == 'escape' then
			_G.BAIZE.ui:hideDrawers()
			_G.BAIZE.ui:cancelModalDialog()
		end
	end

	if _G.SETTINGS.debug then
		if key == 't' then
			_G.BAIZE.ui:toast(string.format('Toast %f', math.random()))
		elseif key == 'up' then
			_G.BAIZE:startSpinning()
		elseif key == 'down' then
			_G.BAIZE:stopSpinning()
		elseif key == 'f' then
			_G.BAIZE.ui:showFAB{icon='star', baizeCmd='newDeal'}
		-- elseif key == 'm' then
		-- 	local result = _G.BAIZE:getPermission('This game will count as a loss. Continue?')
		-- 	log.trace(result)
		end
	end

	_G.BAIZE.lastInput = love.timer.getTime()
end

function love.mousepressed(x, y, button, istouch, presses)
	_G.BAIZE:mousePressed(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
	_G.BAIZE:mouseMoved(x, y, dx, dy)
end

function love.mousereleased(x, y, button, istouch, presses)
	_G.BAIZE:mouseReleased(x, y, button)
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

function love.displayrotated(index, orientation)
	-- Due to a bug in LOVE 11.3, the orientation value is boolean true instead. A workaround is as follows:
	-- orientation = love.window.getDisplayOrientation(index)
	_G.BAIZE:layout()
	if _G.SETTINGS.debug then
		_G.BAIZE.ui:toast('displayrotated ' .. tostring(orientation))
		_G.BAIZE.ui:toast(string.format('safe x=%d y=%d w=%d h=%d', love.window.getSafeArea()))
	end
end

function love.quit()
	-- no args
	-- don't save stats here (with _G.BAIZE.stats:save()) because never quite sure when app quits
	-- or is forced-stopped; instead, save stats when they change

	-- don't save settings either, for the same reason

	-- don't save completed game, to stop win being recorded when it's reloaded
	if _G.BAIZE.status ~= 'complete' then
		_G.BAIZE:saveUndoStack()
	end
	return false	-- allow app to quit
end
