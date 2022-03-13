-- main.lua

local log = require 'log'

local Card = require 'card'
local Baize = require 'baize'
local Stats = require 'stats'
local Util = require 'util'

_G.LSOL_VERSION = '1'

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
	oneColorCards = false,
	twoColorCards = true,
	fourColorCards = false,
}

_G.LSOL_VARIANTS = {
	Accordian = {file='accordian.lua', cc=1},
	['American Toad'] = {file='amtoad.lua'},
	Athena = {file='klondike.lua', athena=true},
	Australian = {file='australian.lua', cc=4},
	['Beleaguered Castle'] = {file='castle.lua', cc=1},
	Bisley = {file='bisley.lua'},
	['Bisley Debug'] = {file='bisley.lua', debug=true},
	['Flat Castle'] = {file='castle.lua', cc=1, flat=true},
	Duchess = {file='duchess.lua'},
	['Debug Klon'] = {file='debug.lua', cc=4, spiderLike=false},
	['Debug Spid'] = {file='debug.lua', cc=4, spiderLike=true},
	['Eight Off'] = {file='eightoff.lua', cc=4},
	['Eight Off Relaxed'] = {file='eightoff.lua', relaxed=true},
	Freecell = {file='freecell.lua', bakers=false, relaxed=true},
	['Baker\'s Game'] = {file='freecell.lua', bakers=true, relaxed=false},
	['Baker\'s Game Relaxed'] = {file='freecell.lua', bakers=true, relaxed=true},
	Gate = {file='gate.lua'},
	Klondike = {file='klondike.lua'},
	['Klondike (Turn Three)']  = {file='klondike.lua', turn=3},
	['Forty Thieves'] = {file='forty.lua', cc=4, tabs=10, cardsPerTab=4},
	Limited = {file='forty.lua', cc=4, tabs=12, cardsPerTab=3},
	Lucas = {file='forty.lua', cc=4, tabs=13, cardsPerTab=3, dealAces=true},
	Penguin = {file='penguin.lua'},
	['Simple Simon'] = {file='simplesimon.lua', cc=4},
	Spider = {file='spider.lua', packs=2, suitFilter={'♣','♦','♥','♠'}},
	['Spider One Suit'] = {file='spider.lua', packs=8, suitFilter={'♠'}},
	['Spider Two Suits'] = {file='spider.lua', packs=4, suitFilter={'♥', '♠'}},
	Thirteens = {file='thirteens.lua'},
	['Classic Westcliff'] = {file='westcliff.lua', classic=true},
	['American Westcliff'] = {file='westcliff.lua', american=true},
	Easthaven = {file='westcliff.lua', easthaven=true},
	Yukon = {file='yukon.lua'},
	['Yukon Relaxed'] = {file='yukon.lua', relaxed=true},
	['Yukon Cells'] = {file='yukon.lua', cells=true},
}

_G.VARIANT_TYPES = {
	-- '> All' will automatically be added
	['> Canfield'] = {'Duchess', 'Gate'},
	['> Forty Thieves'] = {'Forty Thieves', 'Limited', 'Lucas'},
	['> Freecell'] = {'Eight Off', 'Eight Off Relaxed', 'Freecell', 'Baker\'s Game', 'Baker\'s Game Relaxed'},
	['> Klondike'] = {'Athena', 'Klondike', 'Klondike (Turn Three)', 'Easthaven', 'Classic Westcliff', 'American Westcliff'},
	['> Places'] = {'Australian', 'Yukon', 'Yukon Relaxed'},
	['> Puzzlers'] = {'Eight Off', 'Freecell', 'Penguin', 'Simple Simon'},
	['> Spiders'] = {'Spider One Suit', 'Spider Two Suits', 'Spider'},
}

do
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

do
	local stats = Stats.new()
	local function played(v)
		return stats[v].won + stats[v].lost
	end

	-- can only sort a table of keys with numeric indexes, not an associative array
	local tab = {}
	for k,_ in pairs(stats) do
		table.insert(tab, {vname=k, played=played(k)})
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
		for i=1, 3 do
			table.insert(lst, tab[i].vname)
		end
		_G.VARIANT_TYPES['> Favorites'] = lst
		-- beware - this short list will be alpha sorted before it's displayed
	end
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
	menuopen = love.audio.newSource('assets/sounds/cardSlide1.wav', 'static'),
	menuclose = love.audio.newSource('assets/sounds/cardSlide2.wav', 'static'),
	uitap =  love.audio.newSource('assets/sounds/cardSlide8.wav', 'static'),
	complete = love.audio.newSource('assets/sounds/complete.wav', 'static'),
	blip = love.audio.newSource('assets/sounds/249895__alienxxx__blip2.wav', 'static'),
}

_G.ORD2STRING = {'A','2','3','4','5','6','7','8','9','10','J','Q','K'}

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

	io.stdout:setvbuf('no')	-- 'no', 'full' or 'line'

	if args then
		for k, v in pairs(args) do
			print(k, v)
		end
		if arg[#arg] == "-debug" then require("mobdebug").start() end
	end

	math.randomseed(os.time())

	-- love.graphics.setLineStyle('smooth')

	_G.BAIZE = Baize.new()

	_G.BAIZE.stats = Stats.new()
	_G.BAIZE:loadSettings()
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
	-- log.info(key)
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
	elseif key == '1' then
		_G.BAIZE.settings.oneColorCards = true
		_G.BAIZE.settings.twoColorCards = false
		_G.BAIZE.settings.fourColorCards = false
		_G.BAIZE:createCardTextures()
	elseif key == '2' then
		_G.BAIZE.settings.oneColorCards = false
		_G.BAIZE.settings.twoColorCards = true
		_G.BAIZE.settings.fourColorCards = false
		_G.BAIZE:createCardTextures()
	elseif key == '4' then
		_G.BAIZE.settings.oneColorCards = false
		_G.BAIZE.settings.twoColorCards = false
		_G.BAIZE.settings.fourColorCards = true
		_G.BAIZE:createCardTextures()
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

function love.quit()
	-- no args
	_G.BAIZE.stats:save()
	_G.BAIZE:saveSettings()
	-- don't save completed game, to stop win being recorded when it's reloaded
	if _G.BAIZE.status ~= 'complete' then
		_G.BAIZE:saveUndoStack()
	end
end
